import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';

const db = getFirestore();

export const processHarvestRecord = onDocumentWritten(
  'harvests/{harvestId}',
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;
    const d = after.data();

    if (d.verificationStatus !== 'verified' || !d.farmId) return;
    if (d.rpgProcessedAt) return;

    const qualityScore = Number(d.qualityScore ?? 0);
    if (qualityScore <= 0) return;

    const eventRef = await db.collection('verification_events').add({
      farmId: d.farmId,
      fieldId: d.fieldId ?? null,
      kind: 'harvest_quality',
      value: Math.max(0, Math.min(1, qualityScore)),
      verified: true,
      source: 'harvest_record',
      sourceRef: after.id,
      yieldKg: d.yieldKg ?? null,
      grade: d.grade ?? null,
      createdAt: FieldValue.serverTimestamp(),
    });

    await after.ref.set({
      rpgProcessedAt: FieldValue.serverTimestamp(),
      verificationEventId: eventRef.id,
    }, {merge:true});
  }
);
