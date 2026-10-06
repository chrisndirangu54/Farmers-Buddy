import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

const db = getFirestore();

export const processAgronomistVerification = onDocumentCreated(
  'agronomist_verifications/{verificationId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const d = snap.data();

    if (!d.farmId || !d.verifierUid || d.status !== 'approved') return;

    const verifier = await db.collection('users').doc(String(d.verifierUid)).get();
    const roles = verifier.data()?.roles ?? [];
    if (!Array.isArray(roles) || !roles.includes('agronomist')) return;

    const allowedKinds = new Set([
      'verified_scout_observation',
      'crop_health_improvement',
      'harvest_quality',
      'learning_completion',
    ]);

    const kind = String(d.kind ?? '');
    if (!allowedKinds.has(kind)) return;

    await db.collection('verification_events').add({
      farmId: d.farmId,
      fieldId: d.fieldId ?? null,
      kind,
      value: Math.max(0, Math.min(1, Number(d.value ?? 1))),
      verified: true,
      source: 'agronomist_review',
      sourceRef: snap.id,
      verifiedBy: d.verifierUid,
      evidenceRefs: d.evidenceRefs ?? [],
      cropHealth: d.cropHealth ?? null,
      cropStage: d.cropStage ?? null,
      createdAt: FieldValue.serverTimestamp(),
    });
  }
);
