import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { SecretManagerServiceClient } from '@google-cloud/secret-manager';
import { createHash } from 'node:crypto';

const db = getFirestore();
const auth = getAuth();
const secrets = new SecretManagerServiceClient();
const BOOTSTRAP_SUPER_ADMIN = 'chrisndirangu54@gmail.com';

async function assertSuperAdmin(request: any) {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required.');
  if (request.auth.token.superAdmin !== true) {
    throw new HttpsError('permission-denied', 'Super admin privileges required.');
  }
  return request.auth.uid;
}

function cleanKeyName(value: string) {
  const v = value.toUpperCase().replace(/[^A-Z0-9_]/g, '_');
  if (!v || v.length > 120) throw new HttpsError('invalid-argument', 'Invalid secret name.');
  return v;
}

async function audit(uid: string, action: string, target: string, details: Record<string, unknown> = {}) {
  await db.collection('admin_audit_logs').add({
    actorUid: uid,
    action,
    target,
    details,
    createdAt: FieldValue.serverTimestamp(),
  });
}

export const bootstrapSuperAdmin = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required.');

  const tokenEmail = String(request.auth.token.email ?? '').toLowerCase();
  const verified = request.auth.token.email_verified === true;
  if (tokenEmail !== BOOTSTRAP_SUPER_ADMIN || !verified) {
    throw new HttpsError('permission-denied', 'Verified bootstrap account required.');
  }

  await auth.setCustomUserClaims(request.auth.uid, {
    ...(request.auth.token ?? {}),
    superAdmin: true,
    admin: true,
  });

  await db.collection('admin_users').doc(request.auth.uid).set({
    email: BOOTSTRAP_SUPER_ADMIN,
    role: 'super_admin',
    active: true,
    bootstrap: true,
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge:true});

  await audit(request.auth.uid, 'bootstrap_super_admin', request.auth.uid);
  return {ok:true, refreshToken:true};
});

export const setUserAdminRole = onCall(async (request) => {
  const actorUid = await assertSuperAdmin(request);
  const email = String(request.data?.email ?? '').trim().toLowerCase();
  const role = String(request.data?.role ?? '');
  if (!email || !['super_admin','admin','viewer','none'].includes(role)) {
    throw new HttpsError('invalid-argument', 'Valid email and role required.');
  }

  const user = await auth.getUserByEmail(email);
  if (email === BOOTSTRAP_SUPER_ADMIN && role !== 'super_admin') {
    throw new HttpsError('failed-precondition', 'Bootstrap super admin cannot be demoted.');
  }

  await auth.setCustomUserClaims(user.uid, {
    ...(user.customClaims ?? {}),
    superAdmin: role === 'super_admin',
    admin: role === 'super_admin' || role === 'admin',
  });

  await db.collection('admin_users').doc(user.uid).set({
    email,
    role,
    active: role !== 'none',
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge:true});

  await audit(actorUid, 'set_user_admin_role', user.uid, {email, role});
  return {ok:true};
});

export const updateSystemSetting = onCall(async (request) => {
  const actorUid = await assertSuperAdmin(request);
  const key = String(request.data?.key ?? '').trim();
  const value = request.data?.value;
  if (!key || key.length > 120) throw new HttpsError('invalid-argument', 'Invalid setting key.');

  await db.collection('system_settings').doc(key).set({
    value,
    updatedBy: actorUid,
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge:true});

  await audit(actorUid, 'update_system_setting', key, {value});
  return {ok:true};
});

export const updateModelConfig = onCall(async (request) => {
  const actorUid = await assertSuperAdmin(request);
  const capability = String(request.data?.capability ?? '').trim();
  const provider = String(request.data?.provider ?? '').trim();
  const model = String(request.data?.model ?? '').trim();
  if (!capability || !provider || !model) {
    throw new HttpsError('invalid-argument', 'capability, provider and model are required.');
  }

  await db.collection('model_configs').doc(capability).set({
    capability,
    provider,
    model,
    temperature: Number(request.data?.temperature ?? 0.2),
    maxTokens: Number(request.data?.maxTokens ?? 1200),
    enabled: request.data?.enabled !== false,
    updatedBy: actorUid,
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge:true});

  await audit(actorUid, 'update_model_config', capability, {provider, model});
  return {ok:true};
});

export const upsertApiSecret = onCall(async (request) => {
  const actorUid = await assertSuperAdmin(request);
  const provider = String(request.data?.provider ?? '').trim().toLowerCase();
  const keyName = cleanKeyName(String(request.data?.keyName ?? 'API_KEY'));
  const value = String(request.data?.value ?? '');
  if (!provider || !value) throw new HttpsError('invalid-argument', 'provider and secret value are required.');

  const projectId = process.env.GCLOUD_PROJECT;
  if (!projectId) throw new HttpsError('internal', 'GCLOUD_PROJECT is unavailable.');

  const secretId = cleanKeyName('FB_' + provider + '_' + keyName);
  const parent = 'projects/' + projectId;
  const secretName = parent + '/secrets/' + secretId;

  try {
    await secrets.getSecret({name: secretName});
  } catch {
    await secrets.createSecret({
      parent,
      secretId,
      secret: {replication:{automatic:{}}},
    });
  }

  await secrets.addSecretVersion({
    parent: secretName,
    payload: {data: Buffer.from(value, 'utf8')},
  });

  const fingerprint = createHash('sha256').update(value).digest('hex').slice(0, 12);
  await db.collection('api_secret_metadata').doc(provider + '__' + keyName).set({
    provider,
    keyName,
    secretId,
    configured: true,
    fingerprint,
    updatedBy: actorUid,
    updatedAt: FieldValue.serverTimestamp(),
  }, {merge:true});

  await audit(actorUid, 'upsert_api_secret', provider + ':' + keyName, {fingerprint});
  return {ok:true, configured:true, fingerprint};
});

export const disableApiSecret = onCall(async (request) => {
  const actorUid = await assertSuperAdmin(request);
  const provider = String(request.data?.provider ?? '').trim().toLowerCase();
  const keyName = cleanKeyName(String(request.data?.keyName ?? 'API_KEY'));

  await db.collection('api_secret_metadata').doc(provider + '__' + keyName).set({
    provider,
    keyName,
    configured: false,
    disabledAt: FieldValue.serverTimestamp(),
    updatedBy: actorUid,
  }, {merge:true});

  await audit(actorUid, 'disable_api_secret', provider + ':' + keyName);
  return {ok:true};
});
