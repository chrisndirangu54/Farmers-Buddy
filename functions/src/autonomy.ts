import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { HttpsError, onCall, onRequest } from 'firebase-functions/v2/https';
import { createHmac, timingSafeEqual } from 'node:crypto';

const db=getFirestore();

async function requireFarmMember(uid:string,farmId:string){
  const farm=await db.collection('farms').doc(farmId).get();
  const members=farm.data()?.memberUids??[];
  if(!farm.exists||!Array.isArray(members)||!members.includes(uid)){
    throw new HttpsError('permission-denied','Farm membership required.');
  }
}

export const authorizeDroneMission=onCall(async(request)=>{
  if(!request.auth)throw new HttpsError('unauthenticated','Sign in required.');
  const missionId=String(request.data?.missionId??'');
  if(!missionId)throw new HttpsError('invalid-argument','missionId required');

  const ref=db.collection('drone_missions').doc(missionId);
  const snap=await ref.get();
  if(!snap.exists)throw new HttpsError('not-found','Mission not found.');
  const d=snap.data()!;
  await requireFarmMember(request.auth.uid,String(d.farmId));

  const safety=request.data?.safety??{};
  const checks=[
    safety.geofenceReviewed===true,
    safety.weatherReviewed===true,
    safety.peopleAndLivestockClear===true,
    safety.payloadVerified===true,
    safety.operatorAuthorization===true,
  ];
  if(checks.some(x=>!x))throw new HttpsError('failed-precondition','All safety checks must pass.');

  await ref.set({
    status:'authorized',
    safetyState:'authorized',
    safetyChecklist:safety,
    authorizedBy:request.auth.uid,
    authorizedAt:FieldValue.serverTimestamp(),
  },{merge:true});
  return {ok:true};
});

export const approveFarmOperation=onCall(async(request)=>{
  if(!request.auth)throw new HttpsError('unauthenticated','Sign in required.');
  const operationId=String(request.data?.operationId??'');
  if(!operationId)throw new HttpsError('invalid-argument','operationId required');
  const ref=db.collection('farm_operations').doc(operationId);
  const snap=await ref.get();
  if(!snap.exists)throw new HttpsError('not-found','Operation not found.');
  const d=snap.data()!;
  await requireFarmMember(request.auth.uid,String(d.farmId));
  await ref.set({status:'approved',approvedBy:request.auth.uid,approvedAt:FieldValue.serverTimestamp()},{merge:true});
  return {ok:true};
});

function valid(secret:string,body:string,signature:string){
  const expected=createHmac('sha256',secret).update(body).digest('hex');
  const a=Buffer.from(expected),b=Buffer.from(signature||'');
  return a.length===b.length&&timingSafeEqual(a,b);
}

export const ingestDroneReport=onRequest(async(req,res)=>{
  if(req.method!=='POST')return res.status(405).send('POST only');
  const secret=process.env.DRONE_INGEST_SECRET??'';
  const raw=JSON.stringify(req.body??{});
  const signature=String(req.get('x-drone-signature')??'');
  if(!secret||!valid(secret,raw,signature))return res.status(401).json({ok:false});

  const missionId=String(req.body?.missionId??'');
  const farmId=String(req.body?.farmId??'');
  if(!missionId||!farmId)return res.status(400).json({ok:false,reason:'missionId and farmId required'});

  const missionRef=db.collection('drone_missions').doc(missionId);
  const mission=await missionRef.get();
  if(!mission.exists||mission.data()?.farmId!==farmId)return res.status(404).json({ok:false});

  const reportRef=await db.collection('drone_reports').add({
    ...req.body,
    source:'autonomous_drone',
    verifiedSource:true,
    createdAt:FieldValue.serverTimestamp(),
  });

  await missionRef.set({
    status:'reported',
    reportRef:reportRef.id,
    completedAt:FieldValue.serverTimestamp(),
  },{merge:true});

  return res.json({ok:true,reportId:reportRef.id});
});
