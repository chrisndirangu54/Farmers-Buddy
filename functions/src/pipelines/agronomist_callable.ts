import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

const db = getFirestore();

export const submitAgronomistVerification = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required.');

  const verifierUid = request.auth.uid;
  const verifier = await db.collection('users').doc(verifierUid).get();
  const roles = verifier.data()?.roles ?? [];
  if (!Array.isArray(roles) || !roles.includes('agronomist')) {
    throw new HttpsError('permission-denied', 'Agronomist role required.');
  }

  const data = request.data ?? {};
  const farmId = String(data.farmId ?? '');
  const fieldId = data.fieldId ? String(data.fieldId) : null;
  const kind = String(data.kind ?? '');
  const allowedKinds = new Set([
    'verified_scout_observation',
    'crop_health_improvement',
    'harvest_quality',
    'learning_completion',
  ]);
  if (!farmId || !allowedKinds.has(kind)) {
    throw new HttpsError('invalid-argument', 'Invalid farm or verification kind.');
  }

  const farm = await db.collection('farms').doc(farmId).get();
  if (!farm.exists) throw new HttpsError('not-found', 'Farm not found.');

  const value = Math.max(0, Math.min(1, Number(data.value ?? 1)));
  const ref = await db.collection('agronomist_verifications').add({
    farmId,
    fieldId,
    kind,
    value,
    status: 'approved',
    verifierUid,
    evidenceRefs: Array.isArray(data.evidenceRefs) ? data.evidenceRefs : [],
    cropHealth: data.cropHealth ?? null,
    cropStage: data.cropStage ?? null,
    notes: data.notes ?? null,
    createdAt: FieldValue.serverTimestamp(),
  });

  return { ok: true, verificationId: ref.id };
});
