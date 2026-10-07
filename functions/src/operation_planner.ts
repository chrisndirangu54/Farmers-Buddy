import { FieldValue, getFirestore, Timestamp } from 'firebase-admin/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';

const db=getFirestore();

export const materializeFarmOperations=onSchedule('every 30 minutes',async()=>{
  const now=Timestamp.now();
  const due=await db.collection('farm_operation_templates')
    .where('active','==',true)
    .where('nextRunAt','<=',now)
    .limit(200)
    .get();

  for(const doc of due.docs){
    const d=doc.data();
    const farmId=String(d.farmId??'');
    const type=String(d.type??'task');
    if(!farmId)continue;

    const highRisk=type==='spraying';
    await db.collection('farm_operations').add({
      farmId,
      type,
      title:d.title??type,
      targetZone:d.targetZone??null,
      assignedAsset:d.assignedAsset??null,
      automationMode:d.automationMode??'assisted',
      status:highRisk?'planned_requires_approval':'planned',
      sourceTemplateId:doc.id,
      scheduledAt:d.nextRunAt??now,
      createdAt:FieldValue.serverTimestamp(),
    });

    const intervalMinutes=Math.max(1,Number(d.intervalMinutes??1440));
    const next=Timestamp.fromMillis(now.toMillis()+intervalMinutes*60*1000);
    await doc.ref.set({nextRunAt:next,lastMaterializedAt:FieldValue.serverTimestamp()},{merge:true});
  }
});
