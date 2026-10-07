import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'service.dart';

class FarmAutonomyPage extends StatefulWidget {
  final String farmId;
  const FarmAutonomyPage({super.key,required this.farmId});
  @override State<FarmAutonomyPage> createState()=>_FarmAutonomyPageState();
}
class _FarmAutonomyPageState extends State<FarmAutonomyPage>{
  late final AutonomyService service;
  int tab=0;
  @override void initState(){super.initState();service=AutonomyService(FirebaseFirestore.instance);}
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(16),children:[
    const Text('Farm Autonomy',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900)),
    const Text('Autonomous drone monitoring, reporting, spraying and farm-operations planning.'),
    const SizedBox(height:12),
    SegmentedButton<int>(segments:const[ButtonSegment(value:0,label:Text('Drones')),ButtonSegment(value:1,label:Text('Operations')),ButtonSegment(value:2,label:Text('Reports'))],selected:{tab},showSelectedIcon:false,onSelectionChanged:(s)=>setState(()=>tab=s.first)),
    const SizedBox(height:12),
    if(tab==0)_Drones(service:service,farmId:widget.farmId),
    if(tab==1)_Ops(service:service,farmId:widget.farmId),
    if(tab==2)_Reports(farmId:widget.farmId),
  ]);
}

class _Drones extends StatelessWidget{
  final AutonomyService service; final String farmId;
  const _Drones({required this.service,required this.farmId});
  @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Card(child:Padding(padding:EdgeInsets.all(12),child:Text('Monitoring can cover crop health, irrigation anomalies, livestock, fences, water points and infrastructure. Spraying missions require human authorization and geofence/safety review before execution.'))),
    Wrap(spacing:8,children:[
      FilledButton(onPressed:()=>service.createMonitoringMission(farmId,'field-1','Autonomous crop scouting and mapping'),child:const Text('Plan monitoring run')),
      FilledButton(onPressed:()=>service.createSprayingMission(farmId,'field-1','Targeted autonomous spraying',1.0),child:const Text('Plan spraying run')),
    ]),
    const SizedBox(height:10),
    StreamBuilder<List<DroneMission>>(stream:service.droneMissions(farmId),builder:(context,snap){
      if(!snap.hasData)return const CircularProgressIndicator();
      return Column(children:snap.data!.map((m)=>Card(child:ListTile(leading:const Icon(Icons.flight_takeoff),title:Text(m.objective),subtitle:Text(m.type+' • '+m.status+' • '+m.safetyState),trailing:m.areaHa==null?null:Text(m.areaHa!.toStringAsFixed(1)+' ha')))).toList());
    })
  ]);
}

class _Ops extends StatelessWidget{
  final AutonomyService service; final String farmId;
  const _Ops({required this.service,required this.farmId});
  @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const Wrap(spacing:8,runSpacing:8,children:[Chip(label:Text('Spraying')),Chip(label:Text('Milking')),Chip(label:Text('Feeding')),Chip(label:Text('Supply monitoring')),Chip(label:Text('Irrigation')),Chip(label:Text('Harvest')),Chip(label:Text('Maintenance'))]),
    const SizedBox(height:8),
    FilledButton(onPressed:()=>service.scheduleOperation(farmId,'feeding','Automated feeding round','assisted','Livestock Zone A'),child:const Text('Add sample operation')),
    const SizedBox(height:10),
    StreamBuilder<List<FarmOperation>>(stream:service.operations(farmId),builder:(context,snap){
      if(!snap.hasData)return const CircularProgressIndicator();
      return Column(children:snap.data!.map((o)=>Card(child:ListTile(leading:const Icon(Icons.precision_manufacturing_outlined),title:Text(o.title),subtitle:Text(o.type+' • '+o.automationMode+' • '+o.status),trailing:o.targetZone==null?null:Text(o.targetZone!)))).toList());
    })
  ]);
}

class _Reports extends StatelessWidget{
  final String farmId; const _Reports({required this.farmId});
  @override Widget build(BuildContext context)=>StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:FirebaseFirestore.instance.collection('drone_reports').where('farmId',isEqualTo:farmId).orderBy('createdAt',descending:true).snapshots(),builder:(context,snap){
    if(!snap.hasData)return const CircularProgressIndicator();
    final docs=snap.data!.docs;
    if(docs.isEmpty)return const Text('No drone reports yet.');
    return Column(children:docs.map((d){final x=d.data();return Card(child:ListTile(leading:const Icon(Icons.description_outlined),title:Text((x['title']??'Drone report').toString()),subtitle:Text((x['summary']??'').toString())));}).toList());
  });
}