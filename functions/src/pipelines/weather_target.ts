import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

const db = getFirestore();

export const deriveWeatherWaterTarget = onDocumentCreated(
  'weather_snapshots/{snapshotId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const d = snap.data();

    const fieldId = String(d.fieldId ?? '');
    const farmId = String(d.farmId ?? '');
    const areaM2 = Number(d.areaM2 ?? 0);
    const et0Mm = Number(d.et0Mm ?? 0);
    const cropCoefficient = Number(d.cropCoefficient ?? 1);
    const effectiveRainMm = Math.max(0, Number(d.effectiveRainMm ?? 0));
    const soilMoistureCorrection = Math.max(0, Math.min(1, Number(d.soilMoistureCorrection ?? 1)));
    const confidence = Math.max(0, Math.min(1, Number(d.confidence ?? 0)));

    if (!farmId || !fieldId || areaM2 <= 0 || et0Mm <= 0 || confidence < 0.6) return;

    // 1 mm over 1 m² = 1 liter.
    const cropEtMm = et0Mm * cropCoefficient;
    const netMm = Math.max(0, cropEtMm - effectiveRainMm);
    const targetLiters = netMm * areaM2 * soilMoistureCorrection;

    await db.collection('field_water_targets').doc(fieldId).set({
      farmId,
      fieldId,
      targetLiters,
      et0Mm,
      cropCoefficient,
      effectiveRainMm,
      soilMoistureCorrection,
      forecastProvider: d.provider ?? null,
      forecastIssuedAt: d.issuedAt ?? null,
      confidence,
      sourceSnapshotId: snap.id,
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge:true});
  }
);
