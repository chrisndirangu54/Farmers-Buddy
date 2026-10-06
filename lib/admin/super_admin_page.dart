import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SuperAdminGate extends StatelessWidget {
  const SuperAdminGate({super.key});

  Future<bool> _isSuperAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final result = await user.getIdTokenResult(true);
    return result.claims?['superAdmin'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isSuperAdmin(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.data != true) {
          return const Scaffold(body: Center(child: Text('Super admin access required.')));
        }
        return const SuperAdminDashboard();
      },
    );
  }
}

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final functions = FirebaseFunctions.instance;
  final db = FirebaseFirestore.instance;
  final providerCtrl = TextEditingController();
  final keyNameCtrl = TextEditingController(text: 'API_KEY');
  final secretCtrl = TextEditingController();
  final capabilityCtrl = TextEditingController(text: 'crop_diagnosis');
  final modelProviderCtrl = TextEditingController(text: 'openai');
  final modelCtrl = TextEditingController();
  bool busy = false;

  Future<void> _call(String name, Map<String,dynamic> data) async {
    setState(()=>busy=true);
    try {
      await functions.httpsCallable(name).call(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
      }
    } on FirebaseFunctionsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
      }
    } finally {
      if (mounted) setState(()=>busy=false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmers Buddy • Super Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _AdminSectionTitle('API keys / provider secrets'),
          const Text('Secrets are written through Cloud Functions to Google Secret Manager. The client never reads plaintext values back.'),
          const SizedBox(height: 10),
          TextField(controller: providerCtrl, decoration: const InputDecoration(labelText:'Provider, e.g. openai')),
          const SizedBox(height: 8),
          TextField(controller: keyNameCtrl, decoration: const InputDecoration(labelText:'Secret key name')),
          const SizedBox(height: 8),
          TextField(controller: secretCtrl, obscureText:true, decoration: const InputDecoration(labelText:'New secret value')),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: busy ? null : ()=>_call('upsertApiSecret',{
              'provider':providerCtrl.text,
              'keyName':keyNameCtrl.text,
              'value':secretCtrl.text,
            }),
            icon: const Icon(Icons.key),
            label: const Text('Save / rotate secret'),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
            stream: db.collection('api_secret_metadata').orderBy('provider').snapshots(),
            builder: (context,snap) {
              final docs=snap.data?.docs ?? [];
              return Column(children: docs.map((d){
                final x=d.data();
                return Card(child: ListTile(
                  leading: const Icon(Icons.vpn_key_outlined),
                  title: Text('\${x['provider'] ?? ''} • \${x['keyName'] ?? ''}'),
                  subtitle: Text('Configured: \${x['configured'] == true ? 'Yes' : 'No'} • Fingerprint: \${x['fingerprint'] ?? '—'}'),
                ));
              }).toList());
            },
          ),
          const SizedBox(height: 18),
          const _AdminSectionTitle('AI / model configuration'),
          TextField(controller: capabilityCtrl, decoration: const InputDecoration(labelText:'Capability')),
          const SizedBox(height: 8),
          TextField(controller: modelProviderCtrl, decoration: const InputDecoration(labelText:'Provider')),
          const SizedBox(height: 8),
          TextField(controller: modelCtrl, decoration: const InputDecoration(labelText:'Model')),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: busy ? null : ()=>_call('updateModelConfig',{
              'capability':capabilityCtrl.text,
              'provider':modelProviderCtrl.text,
              'model':modelCtrl.text,
              'temperature':0.2,
              'maxTokens':1200,
              'enabled':true,
            }),
            icon: const Icon(Icons.psychology_alt),
            label: const Text('Update model'),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
            stream: db.collection('model_configs').snapshots(),
            builder:(context,snap){
              final docs=snap.data?.docs ?? [];
              return Column(children:docs.map((d){
                final x=d.data();
                return Card(child:ListTile(
                  leading:const Icon(Icons.smart_toy_outlined),
                  title:Text('\${x['capability'] ?? d.id}'),
                  subtitle:Text('\${x['provider'] ?? ''} • \${x['model'] ?? ''}'),
                  trailing:Text(x['enabled']==false?'Off':'On'),
                ));
              }).toList());
            },
          ),
          const SizedBox(height: 18),
          const _AdminSectionTitle('Admin roles'),
          _RoleManager(call:_call),
          const SizedBox(height: 18),
          const _AdminSectionTitle('Audit log'),
          StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
            stream: db.collection('admin_audit_logs').orderBy('createdAt',descending:true).limit(50).snapshots(),
            builder:(context,snap){
              final docs=snap.data?.docs ?? [];
              return Column(children:docs.map((d){
                final x=d.data();
                return Card(child:ListTile(
                  title:Text('\${x['action'] ?? ''}'),
                  subtitle:Text('Target: \${x['target'] ?? ''} • Actor: \${x['actorUid'] ?? ''}'),
                ));
              }).toList());
            },
          ),
        ],
      ),
    );
  }
}

class _RoleManager extends StatefulWidget {
  final Future<void> Function(String,Map<String,dynamic>) call;
  const _RoleManager({required this.call});
  @override
  State<_RoleManager> createState()=>_RoleManagerState();
}

class _RoleManagerState extends State<_RoleManager> {
  final email=TextEditingController();
  String role='admin';
  @override
  Widget build(BuildContext context)=>Column(children:[
    TextField(controller:email,decoration:const InputDecoration(labelText:'User email')),
    const SizedBox(height:8),
    DropdownButtonFormField<String>(
      value:role,
      items:const [
        DropdownMenuItem(value:'super_admin',child:Text('Super admin')),
        DropdownMenuItem(value:'admin',child:Text('Admin')),
        DropdownMenuItem(value:'viewer',child:Text('Viewer')),
        DropdownMenuItem(value:'none',child:Text('Remove admin access')),
      ],
      onChanged:(v)=>setState(()=>role=v ?? 'admin'),
    ),
    const SizedBox(height:8),
    OutlinedButton.icon(
      onPressed:()=>widget.call('setUserAdminRole',{'email':email.text,'role':role}),
      icon:const Icon(Icons.admin_panel_settings),
      label:const Text('Apply role'),
    )
  ]);
}

class _AdminSectionTitle extends StatelessWidget {
  final String text;
  const _AdminSectionTitle(this.text);
  @override
  Widget build(BuildContext context)=>Padding(
    padding:const EdgeInsets.only(bottom:8),
    child:Text(text,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),
  );
}
