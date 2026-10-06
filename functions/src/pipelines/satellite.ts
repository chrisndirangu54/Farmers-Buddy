import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

const db = getFirestore();

export const processSatelliteObservation = onDocumentCreated(
  'satellite_observations/{observationId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const d = snap.data();

    if (!d.farmId || !d.fieldId || d.qualityAccepted !== true) return;
    if (Number(d.cloudFraction ?? 1) > 0.35) return;

    const previousNdvi = Number(d.previousNdvi ?? 0);
    const ndvi = Number(d.ndvi ?? 0);
    const delta = ndvi - previousNdvi;

    if (delta > 0.03) {
      await db.collection('verification_events').add({
        farmId: d.farmId,
        fieldId: d.fieldId,
        kind: 'crop_health_improvement',
        value: Math.min(1, delta),
        cropHealth: d.cropHealth ?? 'Improving',
        cropStage: d.cropStage ?? 'Unknown',
        verified: true,
        source: d.provider ?? 'satellite',
        sourceRef: snap.id,
        sceneId: d.sceneId ?? null,
        observedAt: d.observedAt ?? null,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
  }
);
