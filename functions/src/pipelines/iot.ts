import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { onRequest } from 'firebase-functions/v2/https';
import { createHmac, timingSafeEqual } from 'node:crypto';

const db = getFirestore();

function verifySignature(secret: string, body: string, signature: string) {
  const expected = createHmac('sha256', secret).update(body).digest('hex');
  const a = Buffer.from(expected);
  const b = Buffer.from(signature || '');
  return a.length === b.length && timingSafeEqual(a, b);
}

export const ingestIotTelemetry = onRequest(async (req, res) => {
  if (req.method !== 'POST') return res.status(405).send('POST only');

  const raw = JSON.stringify(req.body ?? {});
  const farmId = String(req.body?.farmId ?? '');
  const fieldId = String(req.body?.fieldId ?? '');
  const deviceId = String(req.body?.deviceId ?? '');
  const secret = process.env.IOT_SHARED_SECRET ?? '';
  const signature = String(req.get('x-device-signature') ?? '');

  if (!farmId || !deviceId || !secret || !verifySignature(secret, raw, signature)) {
    return res.status(401).json({ok:false});
  }

  const ts = Number(req.body?.timestamp ?? 0);
  if (!ts || Math.abs(Date.now() - ts) > 5 * 60 * 1000) {
    return res.status(400).json({ok:false, reason:'stale telemetry'});
  }

  const telemetryRef = await db.collection('telemetry').add({
    ...req.body,
    receivedAt: FieldValue.serverTimestamp(),
    source: 'esp32_iot',
    verifiedSource: true,
  });

  const uptime = Number(req.body?.uptimeRatio ?? 0);
  if (uptime > 0) {
    await db.collection('verification_events').add({
      farmId,
      deviceId,
      kind: 'device_uptime',
      value: Math.max(0, Math.min(1, uptime)),
      verified: true,
      source: 'esp32_iot',
      sourceRef: telemetryRef.id,
      createdAt: FieldValue.serverTimestamp(),
    });
  }

  const applied = Number(req.body?.waterAppliedLiters ?? 0);
  if (fieldId && applied >= 0) {
    const targetSnap = await db.collection('field_water_targets').doc(fieldId).get();
    const target = Number(targetSnap.data()?.targetLiters ?? 0);
    const targetFarmId = String(targetSnap.data()?.farmId ?? '');
    const confidence = Number(targetSnap.data()?.confidence ?? 0);

    if (target > 0 && targetFarmId === farmId && confidence >= 0.6) {
      const efficiency = Math.max(0, Math.min(1, 1 - Math.abs(applied - target) / target));
      await db.collection('verification_events').add({
        farmId,
        fieldId,
        deviceId,
        kind: 'water_efficiency',
        value: efficiency,
        verified: true,
        source: 'iot_plus_weather_target',
        sourceRef: telemetryRef.id,
        targetRef: fieldId,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
  }

  return res.json({ok:true, telemetryId:telemetryRef.id});
});
