import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

const db = getFirestore();

export const submitHarvestRecord = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required.');
  const uid = request.auth.uid;
  const d = request.data ?? {};
  const farmId = String(d.farmId ?? '');
  if (!farmId) throw new HttpsError('invalid-argument', 'farmId required');

  const farm = await db.collection('farms').doc(farmId).get();
  const members = farm.data()?.memberUids ?? [];
  if (!farm.exists || !Array.isArray(members) || !members.includes(uid)) {
    throw new HttpsError('permission-denied', 'Farm membership required.');
  }

  const ref = await db.collection('harvests').add({
    farmId,
    fieldId: d.fieldId ?? null,
    crop: d.crop ?? null,
    yieldKg: Number(d.yieldKg ?? 0),
    grade: d.grade ?? null,
    qualityScore: Number(d.qualityScore ?? 0),
    evidenceRefs: Array.isArray(d.evidenceRefs) ? d.evidenceRefs : [],
    createdBy: uid,
    verificationStatus: 'pending',
    createdAt: FieldValue.serverTimestamp(),
  });

  return {ok:true, harvestId:ref.id};
});

export const verifyHarvestRecord = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required.');

  const verifier = await db.collection('users').doc(request.auth.uid).get();
  const roles = verifier.data()?.roles ?? [];
  if (!Array.isArray(roles) || !roles.includes('agronomist')) {
    throw new HttpsError('permission-denied', 'Agronomist role required.');
  }

  const harvestId = String(request.data?.harvestId ?? '');
  if (!harvestId) throw new HttpsError('invalid-argument', 'harvestId required');

  const ref = db.collection('harvests').doc(harvestId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError('not-found', 'Harvest not found.');

  await ref.set({
    verificationStatus: 'verified',
    verifiedBy: request.auth.uid,
    verifiedAt: FieldValue.serverTimestamp(),
  }, {merge:true});

  return {ok:true};
});
