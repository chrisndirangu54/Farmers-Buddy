import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

const db = getFirestore();

export const processCropScan = onDocumentCreated(
  'crop_scans/{scanId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const d = snap.data();

    const confidence = Number(d.confidence ?? 0);
    if (!d.farmId || !d.fieldId || confidence < 0.80) return;
    if (d.reviewStatus === 'rejected') return;

    const trusted = d.reviewStatus === 'approved' || d.modelTier === 'validated';
    if (!trusted) return;

    await db.collection('verification_events').add({
      farmId: d.farmId,
      fieldId: d.fieldId,
      kind: 'verified_scout_observation',
      value: confidence,
      cropHealth: d.cropHealth ?? null,
      cropStage: d.cropStage ?? null,
      verified: true,
      source: 'crop_camera_ai',
      sourceRef: snap.id,
      diagnosis: d.diagnosis ?? null,
      createdAt: FieldValue.serverTimestamp(),
    });
  }
);
