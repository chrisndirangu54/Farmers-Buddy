import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { onRequest } from 'firebase-functions/v2/https';
import { createHmac, timingSafeEqual } from 'node:crypto';

const db = getFirestore();

function valid(secret: string, body: string, signature: string) {
  const expected = createHmac('sha256', secret).update(body).digest('hex');
  const a = Buffer.from(expected);
  const b = Buffer.from(signature || '');
  return a.length === b.length && timingSafeEqual(a, b);
}

async function ingest(req: any, res: any, collection: string, secretEnv: string, source: string) {
  if (req.method !== 'POST') return res.status(405).send('POST only');
  const secret = process.env[secretEnv] ?? '';
  const raw = JSON.stringify(req.body ?? {});
  const signature = String(req.get('x-source-signature') ?? '');
  if (!secret || !valid(secret, raw, signature)) {
    return res.status(401).json({ok:false});
  }

  const farmId = String(req.body?.farmId ?? '');
  if (!farmId) return res.status(400).json({ok:false, reason:'farmId required'});

  const ref = await db.collection(collection).add({
    ...req.body,
    source,
    receivedAt: FieldValue.serverTimestamp(),
  });
  return res.json({ok:true, id:ref.id});
}

export const ingestWeatherSnapshot = onRequest((req, res) =>
  ingest(req, res, 'weather_snapshots', 'WEATHER_INGEST_SECRET', 'weather_provider')
);

export const ingestSatelliteObservation = onRequest((req, res) =>
  ingest(req, res, 'satellite_observations', 'SATELLITE_INGEST_SECRET', 'eo_worker')
);

export const ingestCropScanResult = onRequest((req, res) =>
  ingest(req, res, 'crop_scans', 'CROP_SCAN_INGEST_SECRET', 'crop_ai_worker')
);
