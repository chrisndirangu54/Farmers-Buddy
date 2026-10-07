import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class AutonomyService {
  final FirebaseFirestore db;
  AutonomyService(this.db);
  Stream<List<DroneMission>> droneMissions(String farmId)=>db.collection('drone_missions').where('farmId',isEqualTo:farmId).orderBy('scheduledAt',descending:true).snapshots().map((q)=>q.docs.map(DroneMission.fromDoc).toList());
  Stream<List<FarmOperation>> operations(String farmId)=>db.collection('farm_operations').where('farmId',isEqualTo:farmId).orderBy('scheduledAt').snapshots().map((q)=>q.docs.map(FarmOperation.fromDoc).toList());
  Future<void> createMonitoringMission(String farmId,String fieldId,String objective)=>db.collection('drone_missions').add({'farmId':farmId,'fieldId':fieldId,'type':'monitoring','objective':objective,'status':'planned','safetyState':'pending_review','scheduledAt':Timestamp.fromDate(DateTime.now().add(const Duration(hours:1))),'createdAt':FieldValue.serverTimestamp()});
  Future<void> createSprayingMission(String farmId,String fieldId,String objective,double areaHa)=>db.collection('drone_missions').add({'farmId':farmId,'fieldId':fieldId,'type':'spraying','objective':objective,'areaHa':areaHa,'status':'planned','safetyState':'requires_human_authorization','scheduledAt':Timestamp.fromDate(DateTime.now().add(const Duration(hours:1))),'createdAt':FieldValue.serverTimestamp()});
  Future<void> scheduleOperation(String farmId,String type,String title,String mode,String zone)=>db.collection('farm_operations').add({'farmId':farmId,'type':type,'title':title,'status':'planned','automationMode':mode,'targetZone':zone,'scheduledAt':Timestamp.fromDate(DateTime.now().add(const Duration(hours:1))),'createdAt':FieldValue.serverTimestamp()});
}