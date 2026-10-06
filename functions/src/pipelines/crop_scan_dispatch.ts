import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

const db = getFirestore();

export const submitCropScan = onCall(async (request) => {
  if (!request.auth) throw new HttpsError('unauthenticated', 'Sign in required.');

  const data = request.data ?? {};
  const farmId = String(data.farmId ?? '');
  const fieldId = String(data.fieldId ?? '');
  const storagePath = String(data.storagePath ?? '');

  if (!farmId || !fieldId || !storagePath) {
    throw new HttpsError('invalid-argument', 'farmId, fieldId and storagePath are required.');
  }

  const farm = await db.collection('farms').doc(farmId).get();
  const members = farm.data()?.memberUids ?? [];
  if (!farm.exists || !Array.isArray(members) || !members.includes(request.auth.uid)) {
    throw new HttpsError('permission-denied', 'Farm membership required.');
  }

  const ref = await db.collection('crop_scan_requests').add({
    farmId,
    fieldId,
    storagePath,
    crop: data.crop ?? null,
    cropStage: data.cropStage ?? null,
    requestedBy: request.auth.uid,
    status: 'queued',
    createdAt: FieldValue.serverTimestamp(),
  });

  return {ok:true, requestId:ref.id};
});

export const dispatchCropScan = onDocumentCreated(
  'crop_scan_requests/{requestId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const d = snap.data();

    const endpoint = process.env.CROP_DIAGNOSIS_ENDPOINT ?? '';
    const token = process.env.CROP_DIAGNOSIS_TOKEN ?? '';
    if (!endpoint || !token) {
      await snap.ref.set({status:'waiting_for_worker_config'}, {merge:true});
      return;
    }

    const response = await fetch(endpoint, {
      method:'POST',
      headers:{
        'content-type':'application/json',
        'authorization':'Bearer ' + token,
      },
      body:JSON.stringify({
        requestId:snap.id,
        farmId:d.farmId,
        fieldId:d.fieldId,
        storagePath:d.storagePath,
        crop:d.crop ?? null,
        cropStage:d.cropStage ?? null,
      }),
    });

    await snap.ref.set({
      status: response.ok ? 'dispatched' : 'dispatch_failed',
      workerStatus: response.status,
      dispatchedAt: FieldValue.serverTimestamp(),
    }, {merge:true});
  }
);
