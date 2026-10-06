import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'rpg_service.dart';

class FarmRpgGate extends StatelessWidget {
  const FarmRpgGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Sign in to load your live Farm RPG profile.'),
      ));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('farms')
          .where('memberUids', arrayContains: user.uid)
          .limit(1)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return Center(child: Text('Unable to load farm: ' + snap.error.toString()));
        final docs = snap.data?.docs ?? const [];
        if (docs.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No farm is linked to this account yet.'),
          ));
        }
        return LiveFarmRpgPage(farmId: docs.first.id);
      },
    );
  }
}

class LiveFarmRpgPage extends StatefulWidget {
  final String farmId;
  const LiveFarmRpgPage({super.key, required this.farmId});

  @override
  State<LiveFarmRpgPage> createState() => _LiveFarmRpgPageState();
}

class _LiveFarmRpgPageState extends State<LiveFarmRpgPage> {
  int tab = 0;
  late final RpgService service;

  @override
  void initState() {
    super.initState();
    service = RpgService(FirebaseFirestore.instance);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FarmRpgProfile?>(
      stream: service.profile(widget.farmId),
      builder: (context, profileSnap) {
        final profile = profileSnap.data;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Farm RPG', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                SizedBox(height: 3),
                Text('Live progression driven by verified farm data.'),
              ])),
              Chip(avatar: Icon(Icons.cloud_done_outlined, size: 18), label: Text('Firebase Live')),
            ]),
            const SizedBox(height: 14),
            _ProfileHero(profile: profile),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value:0, icon:Icon(Icons.landscape_outlined), label:Text('Farm')),
                  ButtonSegment(value:1, icon:Icon(Icons.pets_outlined), label:Text('Companions')),
                  ButtonSegment(value:2, icon:Icon(Icons.flag_outlined), label:Text('Season')),
                  ButtonSegment(value:3, icon:Icon(Icons.emoji_events_outlined), label:Text('League')),
                  ButtonSegment(value:4, icon:Icon(Icons.redeem_outlined), label:Text('Rewards')),
                ],
                selected: {tab},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => tab = s.first),
              ),
            ),
            const SizedBox(height: 16),
            if (tab == 0) _FieldsTab(service: service, farmId: widget.farmId, profile: profile),
            if (tab == 1) _CompanionsTab(service: service, farmId: widget.farmId),
            if (tab == 2) _SeasonTab(service: service, farmId: widget.farmId),
            if (tab == 3) _LeagueTab(service: service),
            if (tab == 4) _RewardsTab(service: service, farmId: widget.farmId),
            const SizedBox(height: 18),
            const Card(child: Padding(
              padding: EdgeInsets.all(14),
              child: Text('XP, field levels, companion bonds, league scores and reward eligibility come from trusted backend verification events. The client is read-only for progression.'),
            )),
          ],
        );
      },
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final FarmRpgProfile? profile;
  const _ProfileHero({required this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Card(child: Padding(
        padding: EdgeInsets.all(18),
        child: Text('RPG profile initializes when the first verified farm event is processed.'),
      ));
    }
    final nextBase = profile!.level * 500;
    final currentBase = (profile!.level - 1) * 500;
    final progress = ((profile!.xp - currentBase) / (nextBase - currentBase)).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F3C24), Color(0xFF2E7D32)]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Level ' + profile!.level.toString() + ' • ' + profile!.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
        ),
        const SizedBox(height: 4),
        Text(
          profile!.xp.toString() + ' XP • ' + profile!.streakDays.toString() + '-day verified streak',
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 14),
        LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.white24),
      ]),
    );
  }
}

class _FieldsTab extends StatelessWidget {
  final RpgService service;
  final String farmId;
  final FarmRpgProfile? profile;
  const _FieldsTab({required this.service, required this.farmId, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Evolving fields', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      StreamBuilder<List<FieldRpgState>>(
        stream: service.fields(farmId),
        builder: (context, snap) {
          if (!snap.hasData) return const CircularProgressIndicator();
          if (snap.data!.isEmpty) return const Text('No field RPG records yet.');
          return Column(children: snap.data!.map((f) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(f.level.toString())),
              title: Text(f.name + ' • ' + f.crop, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(f.stage + ' • ' + f.health + ' • Trait: ' + f.trait),
              trailing: Text(f.xp.toString() + '/' + f.xpToNextLevel.toString()),
            ),
          )).toList());
        },
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        Chip(label: Text('Vitality ' + (profile?.vitality ?? 0).toString())),
        Chip(label: Text('Water ' + (((profile?.waterEfficiencyScore ?? 0) * 100).round()).toString() + '%')),
        Chip(label: Text('Scout ' + (((profile?.scoutCoverage ?? 0) * 100).round()).toString() + '%')),
        Chip(label: Text('Devices ' + (((profile?.deviceReliability ?? 0) * 100).round()).toString() + '%')),
      ]),
    ]);
  }
}

class _CompanionsTab extends StatelessWidget {
  final RpgService service;
  final String farmId;
  const _CompanionsTab({required this.service, required this.farmId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CompanionState>>(
      stream: service.companions(farmId),
      builder: (context, snap) {
        if (!snap.hasData) return const CircularProgressIndicator();
        if (snap.data!.isEmpty) return const Text('No companions connected yet.');
        return Column(children: snap.data!.map((c) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(c.icon)),
            title: Text(c.name + ' • ' + c.type, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(c.status + ' • ' + (c.uptime * 100).round().toString() + '% uptime\nPerk: ' + c.perk),
            isThreeLine: true,
            trailing: Chip(label: Text('Lv. ' + c.bondLevel.toString())),
          ),
        )).toList());
      },
    );
  }
}

class _SeasonTab extends StatelessWidget {
  final RpgService service;
  final String farmId;
  const _SeasonTab({required this.service, required this.farmId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SeasonMission>>(
      stream: service.missions(farmId),
      builder: (context, snap) {
        if (!snap.hasData) return const CircularProgressIndicator();
        if (snap.data!.isEmpty) return const Text('No active seasonal missions.');
        return Column(children: snap.data!.map((m) => Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.title, style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(m.cropStage + ' • +' + m.rewardXp.toString() + ' XP'),
              const SizedBox(height: 5),
              Text(m.detail),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: m.progress.clamp(0.0, 1.0), minHeight: 8),
            ]),
          ),
        )).toList());
      },
    );
  }
}

class _LeagueTab extends StatelessWidget {
  final RpgService service;
  const _LeagueTab({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LeagueEntry>>(
      stream: service.league('current'),
      builder: (context, snap) {
        if (!snap.hasData) return const CircularProgressIndicator();
        if (snap.data!.isEmpty) return const Text('No league entries yet.');
        return Column(children: snap.data!.map((e) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(e.rank.toString())),
            title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(e.badge),
            trailing: Text(e.score.toString(), style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        )).toList());
      },
    );
  }
}

class _RewardsTab extends StatelessWidget {
  final RpgService service;
  final String farmId;
  const _RewardsTab({required this.service, required this.farmId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<RewardItem>>(
      stream: service.rewards(farmId),
      builder: (context, snap) {
        if (!snap.hasData) return const CircularProgressIndicator();
        if (snap.data!.isEmpty) return const Text('No rewards configured yet.');
        return Column(children: snap.data!.map((r) => Card(
          child: ListTile(
            leading: Icon(r.type == 'practical' ? Icons.card_giftcard : Icons.workspace_premium_outlined),
            title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(r.detail),
            trailing: Chip(label: Text(r.status)),
          ),
        )).toList());
      },
    );
  }
}
