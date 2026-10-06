import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

const db = getFirestore();

export const scoreWeatherAwareIrrigation = onDocumentCreated(
  'irrigation_events/{eventId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const d = snap.data();

    if (!d.farmId || !d.fieldId || d.completed !== true) return;

    const applied = Number(d.appliedLiters ?? 0);
    const target = Number(d.weatherAdjustedTargetLiters ?? 0);
    const forecastAgeMinutes = Number(d.forecastAgeMinutes ?? 9999);
    const confidence = Number(d.weatherConfidence ?? 0);

    if (target <= 0 || forecastAgeMinutes > 180 || confidence < 0.6) return;

    const efficiency = Math.max(0, Math.min(1, 1 - Math.abs(applied - target) / target));

    await db.collection('verification_events').add({
      farmId: d.farmId,
      fieldId: d.fieldId,
      kind: 'water_efficiency',
      value: efficiency,
      verified: true,
      source: 'weather_irrigation',
      sourceRef: snap.id,
      forecastProvider: d.forecastProvider ?? null,
      createdAt: FieldValue.serverTimestamp(),
    });
  }
);
