import 'package:cloud_firestore/cloud_firestore.dart';

class DroneMission {
  final String id, farmId, type, status, fieldId, objective, safetyState;
  final DateTime? scheduledAt;
  final double? areaHa;
  DroneMission({required this.id,required this.farmId,required this.type,required this.status,required this.fieldId,required this.objective,required this.safetyState,this.scheduledAt,this.areaHa});
  factory DroneMission.fromDoc(DocumentSnapshot<Map<String,dynamic>> doc){
    final d=doc.data()??{};
    return DroneMission(id:doc.id,farmId:d['farmId']??'',type:d['type']??'monitoring',status:d['status']??'planned',fieldId:d['fieldId']??'',objective:d['objective']??'',safetyState:d['safetyState']??'pending_review',scheduledAt:(d['scheduledAt'] as Timestamp?)?.toDate(),areaHa:(d['areaHa'] as num?)?.toDouble());
  }
}

class FarmOperation {
  final String id,farmId,type,title,status,automationMode;
  final DateTime? scheduledAt;
  final String? targetZone;
  FarmOperation({required this.id,required this.farmId,required this.type,required this.title,required this.status,required this.automationMode,this.scheduledAt,this.targetZone});
  factory FarmOperation.fromDoc(DocumentSnapshot<Map<String,dynamic>> doc){
    final d=doc.data()??{};
    return FarmOperation(id:doc.id,farmId:d['farmId']??'',type:d['type']??'task',title:d['title']??'Farm operation',status:d['status']??'planned',automationMode:d['automationMode']??'manual',scheduledAt:(d['scheduledAt'] as Timestamp?)?.toDate(),targetZone:d['targetZone']);
  }
}