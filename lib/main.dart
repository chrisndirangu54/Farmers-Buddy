import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'rpg/live_rpg_page.dart';
import 'admin/super_admin_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FarmersBuddyApp());
}

class FarmersBuddyApp extends StatelessWidget {
  const FarmersBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farmers Buddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6FAF5),
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
      ),
      home: const FarmShell(),
    );
  }
}

class FarmShell extends StatefulWidget {
  const FarmShell({super.key});
  @override
  State<FarmShell> createState() => _FarmShellState();
}

class _FarmShellState extends State<FarmShell> {
  int index = 0;
  final pages = const [
    OverviewPage(),
    FieldsPage(),
    AutomationPage(),
    IntelligencePage(),
    MarketPage(),
    const FarmRpgGate(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Farmers Buddy', style: TextStyle(fontWeight: FontWeight.w800)),
          Text('Satellite • AI • IoT • Smart irrigation', style: TextStyle(fontSize: 11)),
        ]),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          IconButton(
            tooltip: 'Super Admin',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SuperAdminGate())),
            icon: const Icon(Icons.admin_panel_settings_outlined),
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.satellite_alt_outlined), selectedIcon: Icon(Icons.satellite_alt), label: 'Fields'),
          NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Control'),
          NavigationDestination(icon: Icon(Icons.psychology_alt_outlined), selectedIcon: Icon(Icons.psychology_alt), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Play'),
        ],
      ),
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Farm command center', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(
        'Live operational picture across crops, weather, water, devices and harvest readiness.',
        style: TextStyle(color: Colors.grey.shade700),
      ),
      const SizedBox(height: 16),
      const Wrap(spacing: 10, runSpacing: 10, children: [
        MetricCard(icon: Icons.eco, label: 'Crop health', value: '82%', note: 'Demo state • connect EO service'),
        MetricCard(icon: Icons.water_drop, label: 'Soil moisture', value: '41%', note: 'Zone 2 below target'),
        MetricCard(icon: Icons.cloud, label: 'Rain risk', value: 'Low', note: 'Weather adapter ready'),
        MetricCard(icon: Icons.agriculture, label: 'Harvest readiness', value: '68%', note: '2 plots approaching window'),
      ]),
      const SizedBox(height: 18),
      const SectionTitle('Priority alerts'),
      const AlertTile(severity: 'High', title: 'Irrigation attention', detail: 'Zone 2 moisture is below the configured crop threshold.'),
      const AlertTile(severity: 'Medium', title: 'Disease scan requested', detail: 'Camera anomaly persisted across three observations. Capture close-up images.'),
      const AlertTile(severity: 'Info', title: 'Market signal', detail: 'Tomato price monitoring is enabled; connect a verified market feed for live quotes.'),
      const SizedBox(height: 18),
      const SectionTitle('System coverage'),
      const Wrap(spacing: 8, runSpacing: 8, children: [
        FeatureChip('Satellite NDVI/EVI/NDWI'),
        FeatureChip('Crop photo diagnosis'),
        FeatureChip('Weather + sunlight'),
        FeatureChip('Wind + evapotranspiration'),
        FeatureChip('Soil + NPK IoT'),
        FeatureChip('Cameras'),
        FeatureChip('Irrigation valves'),
        FeatureChip('Greenhouse lighting'),
        FeatureChip('Hydroponics'),
        FeatureChip('Aeroponics'),
        FeatureChip('Aquaponics'),
        FeatureChip('Yield forecast'),
        FeatureChip('Farm digital twin'),
      ]),
    ]);
  }
}

class FieldsPage extends StatelessWidget {
  const FieldsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Fields & remote sensing', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Container(
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(colors: [Color(0xFF163A24), Color(0xFF4D7D55)]),
        ),
        child: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.satellite_alt, color: Colors.white, size: 54),
            SizedBox(height: 8),
            Text('Satellite field layer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
            Text('Connect Sentinel/Landsat/Planet adapter', style: TextStyle(color: Colors.white70)),
          ]),
        ),
      ),
      const SizedBox(height: 14),
      const FieldTile(name: 'North Plot', crop: 'Maize', ndvi: '0.71', water: 'Moderate', readiness: '54%'),
      const FieldTile(name: 'Greenhouse A', crop: 'Tomato', ndvi: '0.79', water: 'Good', readiness: '76%'),
      const FieldTile(name: 'Hydroponics Bay', crop: 'Lettuce', ndvi: 'Camera', water: 'EC/pH controlled', readiness: '63%'),
      const SizedBox(height: 12),
      FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add_location_alt_outlined), label: const Text('Add / draw field boundary')),
    ]);
  }
}

class AutomationPage extends StatefulWidget {
  const AutomationPage({super.key});
  @override
  State<AutomationPage> createState() => _AutomationPageState();
}

class _AutomationPageState extends State<AutomationPage> {
  bool irrigation = true, lights = false, nutrient = true, climate = true;

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Automation & devices', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      const Text('Control logic should be executed by authenticated edge/cloud rules, not directly from the UI.'),
      const SizedBox(height: 12),
      SwitchListTile(value: irrigation, onChanged: (v) => setState(() => irrigation = v), title: const Text('Smart irrigation'), subtitle: const Text('Moisture + ET₀ + rain forecast + crop stage')),
      SwitchListTile(value: lights, onChanged: (v) => setState(() => lights = v), title: const Text('Greenhouse light control'), subtitle: const Text('PAR / photoperiod / sunrise-aware lighting')),
      SwitchListTile(value: nutrient, onChanged: (v) => setState(() => nutrient = v), title: const Text('Fertigation / nutrient dosing'), subtitle: const Text('EC, pH and recipe thresholds with safety limits')),
      SwitchListTile(value: climate, onChanged: (v) => setState(() => climate = v), title: const Text('Climate control'), subtitle: const Text('Fans, vents, misting, heating and humidity control')),
      const SizedBox(height: 12),
      const SectionTitle('Device gateways'),
      const DeviceTile(name: 'ESP32 Field Gateway', status: 'Demo', sensors: 'Soil moisture • temp • humidity • light • flow'),
      const DeviceTile(name: 'Greenhouse Controller', status: 'Demo', sensors: 'PAR • CO₂ • EC • pH • fan • pump • lighting'),
      const DeviceTile(name: 'Camera Node', status: 'Demo', sensors: 'Timelapse • pest traps • canopy health • intrusions'),
    ]);
  }
}

class IntelligencePage extends StatelessWidget {
  const IntelligencePage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: const [
      Text('AI agronomy', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
      SizedBox(height: 12),
      AiCard(icon: Icons.camera_alt_outlined, title: 'Crop image diagnosis', text: 'Detect disease, pests, nutrient deficiency and physical damage from farmer or camera images. Keep predictions confidence-scored and expert-reviewable.'),
      AiCard(icon: Icons.timeline, title: 'Yield & harvest readiness', text: 'Combine planting date, crop stage, weather, degree days, imagery and field observations to estimate harvest windows.'),
      AiCard(icon: Icons.water, title: 'Water intelligence', text: 'Estimate ET₀, crop coefficient, soil-water deficit, rainfall contribution and irrigation demand per zone.'),
      AiCard(icon: Icons.hub_outlined, title: 'Farm digital twin', text: 'Represent fields, crops, devices, tanks, pumps, nutrient recipes, greenhouse zones and operational history in one state model.'),
      AiCard(icon: Icons.auto_awesome, title: 'Farmer copilot', text: 'Natural-language advisory grounded in farm telemetry, crop records, images, weather and verified agronomic knowledge.'),
    ]);
  }
}

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: const [
      Text('Market & planning', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
      SizedBox(height: 12),
      AiCard(icon: Icons.price_check, title: 'AI price monitoring', text: 'Track verified wholesale, retail, farm-gate and buyer quotes; flag unusual spreads and expected harvest-period price risk.'),
      AiCard(icon: Icons.inventory_2_outlined, title: 'Harvest logistics', text: 'Plan expected volumes, labor, packaging, cold storage, transport, buyers and delivery windows.'),
      AiCard(icon: Icons.calculate_outlined, title: 'Profitability & scenarios', text: 'Estimate input cost, water/energy consumption, yield ranges, expected revenue and downside scenarios before planting.'),
      AiCard(icon: Icons.handshake_outlined, title: 'Buyer matching', text: 'Optional marketplace connector for contracted buyers, cooperatives, processors and institutional demand.'),
    ]);
  }
}

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String label, value, note;
  const MetricCard({super.key, required this.icon, required this.label, required this.value, required this.note});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 170,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text(note, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
  );
}

class FeatureChip extends StatelessWidget {
  final String text;
  const FeatureChip(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Chip(label: Text(text));
}

class AlertTile extends StatelessWidget {
  final String severity, title, detail;
  const AlertTile({super.key, required this.severity, required this.title, required this.detail});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.warning_amber_rounded),
      title: Text(title),
      subtitle: Text(detail),
      trailing: Text(severity),
    ),
  );
}

class FieldTile extends StatelessWidget {
  final String name, crop, ndvi, water, readiness;
  const FieldTile({super.key, required this.name, required this.crop, required this.ndvi, required this.water, required this.readiness});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.grass)),
      title: Text(name),
      subtitle: Text('$crop • NDVI $ndvi • Water $water'),
      trailing: Text(readiness, style: const TextStyle(fontWeight: FontWeight.w800)),
    ),
  );
}

class DeviceTile extends StatelessWidget {
  final String name, status, sensors;
  const DeviceTile({super.key, required this.name, required this.status, required this.sensors});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.memory),
      title: Text(name),
      subtitle: Text(sensors),
      trailing: Chip(label: Text(status)),
    ),
  );
}

class AiCard extends StatelessWidget {
  final IconData icon;
  final String title, text;
  const AiCard({super.key, required this.icon, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(text),
          ]),
        ),
      ]),
    ),
  );
}


class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int tab = 0;

  static const fields = [
    {'name':'North Plot', 'crop':'Maize', 'level':8, 'xp':'1,940 / 2,400', 'health':'Thriving', 'stage':'Tasseling', 'progress':0.81, 'trait':'Water Wise'},
    {'name':'Greenhouse A', 'crop':'Tomato', 'level':12, 'xp':'3,480 / 4,000', 'health':'Watch', 'stage':'Fruit Set', 'progress':0.87, 'trait':'Yield Hunter'},
    {'name':'Hydroponics Bay', 'crop':'Lettuce', 'level':6, 'xp':'980 / 1,400', 'health':'Stable', 'stage':'Leaf Expansion', 'progress':0.70, 'trait':'Precision Grower'},
  ];

  static const companions = [
    {'name':'Maji', 'type':'Soil Scout', 'icon':'💧', 'bond':'Lv. 7', 'status':'Moisture sensing', 'perk':'+5% Water Quest XP'},
    {'name':'Jua', 'type':'Climate Sentinel', 'icon':'☀️', 'bond':'Lv. 5', 'status':'Light + temperature', 'perk':'Early heat warning'},
    {'name':'Nyuki', 'type':'Crop Watcher', 'icon':'🐝', 'bond':'Lv. 9', 'status':'Camera + pest trap', 'perk':'Pest streak protection'},
    {'name':'Mlinzi', 'type':'Gateway Guardian', 'icon':'🤖', 'bond':'Lv. 4', 'status':'ESP32 online', 'perk':'Device uptime bonus'},
  ];

  static const missions = [
    {'title':'Establishment: Protect Emergence', 'detail':'Verify stand count, moisture stability and early pest pressure.', 'xp':'+220 XP', 'progress':0.80, 'stage':'Week 1–3'},
    {'title':'Vegetative Push', 'detail':'Keep crop health above target while minimizing unnecessary irrigation.', 'xp':'+300 XP', 'progress':0.55, 'stage':'Vegetative'},
    {'title':'Flower & Fruit Defense', 'detail':'Complete scouting, nutrition and heat-stress checks during the critical reproductive window.', 'xp':'+420 XP', 'progress':0.38, 'stage':'Flowering'},
    {'title':'Harvest Window', 'detail':'Confirm maturity, quality, buyer/logistics readiness and zero unresolved critical alerts.', 'xp':'+600 XP', 'progress':0.20, 'stage':'Harvest'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Farm RPG', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
            SizedBox(height: 3),
            Text('Your real farm evolves as verified agronomic performance improves.'),
          ])),
          Chip(
            avatar: const Icon(Icons.shield_moon_outlined, size: 18),
            label: const Text('Season 04'),
          ),
        ]),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0F3C24), Color(0xFF2E7D32)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.agriculture, color: Colors.white)),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Level 12 • Regenerative Grower', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                SizedBox(height: 3),
                Text('Title equipped: Water Steward', style: TextStyle(color: Colors.white70)),
              ])),
              Icon(Icons.local_fire_department, color: Colors.amberAccent),
            ]),
            SizedBox(height: 14),
            LinearProgressIndicator(value: 0.72, minHeight: 10, backgroundColor: Colors.white24),
            SizedBox(height: 6),
            Text('4,820 XP • 680 XP to Level 13 • 9-day verified streak', style: TextStyle(color: Colors.white70, fontSize: 11)),
          ]),
        ),

        const SizedBox(height: 14),
        SegmentedButton<int>(
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
        const SizedBox(height: 16),

        if (tab == 0) ...[
          const SectionTitle('Evolving fields'),
          ...fields.map((f) => FieldRpgCard(
            name:f['name'] as String,
            crop:f['crop'] as String,
            level:f['level'] as int,
            xp:f['xp'] as String,
            health:f['health'] as String,
            stage:f['stage'] as String,
            progress:f['progress'] as double,
            trait:f['trait'] as String,
          )),
          const SizedBox(height: 16),
          const SectionTitle('Farm stats'),
          const Wrap(spacing: 9, runSpacing: 9, children: [
            GameStat(icon: Icons.eco, value:'84', label:'Farm vitality'),
            GameStat(icon: Icons.water_drop, value:'A-', label:'Water efficiency'),
            GameStat(icon: Icons.bug_report_outlined, value:'92%', label:'Scout coverage'),
            GameStat(icon: Icons.memory, value:'96%', label:'Device reliability'),
          ]),
        ],

        if (tab == 1) ...[
          const SectionTitle('Sensor companions'),
          const Text('Real devices gain bond levels from reliable uptime, useful observations and successful farm decisions. Companion bonuses never override agronomic safety rules.'),
          const SizedBox(height: 10),
          ...companions.map((c) => CompanionCard(
            name:c['name'] as String,
            type:c['type'] as String,
            icon:c['icon'] as String,
            bond:c['bond'] as String,
            status:c['status'] as String,
            perk:c['perk'] as String,
          )),
        ],

        if (tab == 2) ...[
          const SectionTitle('Seasonal crop campaign'),
          const SeasonBanner(),
          const SizedBox(height: 10),
          ...missions.map((m) => SeasonalMissionCard(
            title:m['title'] as String,
            detail:m['detail'] as String,
            xp:m['xp'] as String,
            progress:m['progress'] as double,
            stage:m['stage'] as String,
          )),
          const SizedBox(height: 10),
          const Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.auto_awesome)),
              title: Text('Dynamic mission generation'),
              subtitle: Text('Missions can be generated from crop type, planting date, phenology, weather, satellite health, sensor events and unresolved field risks.'),
            ),
          ),
        ],

        if (tab == 3) ...[
          const SectionTitle('Cooperative rankings'),
          const LeagueRow(rank:'1', farm:'Green Valley Co-op', score:'9,840', badge:'Climate Champions'),
          const LeagueRow(rank:'2', farm:'Kijani Growers', score:'9,110', badge:'Water Guardians'),
          const LeagueRow(rank:'3', farm:'Your Cooperative', score:'8,760', badge:'Rising League'),
          const LeagueRow(rank:'4', farm:'Highland Harvest', score:'8,420', badge:'Scout Masters'),
          const SizedBox(height: 14),
          const CommunityChallenge(
            title:'County Water Challenge',
            detail:'Collectively reduce avoidable irrigation by 100,000 L this month.',
            progress:0.61,
            reward:'Co-op trophy + sponsor reward pool',
          ),
          const CommunityChallenge(
            title:'Pest Watch Network',
            detail:'Submit 500 verified pest observations to improve local early-warning coverage.',
            progress:0.43,
            reward:'Scout title + cooperative XP',
          ),
        ],

        if (tab == 4) ...[
          const SectionTitle('Unlocks & practical rewards'),
          const RewardCard(icon:Icons.title, title:'Farm titles', status:'Unlocked', detail:'Water Steward • Soil Builder • Climate-Smart Grower'),
          const RewardCard(icon:Icons.palette_outlined, title:'Equipment skins', status:'3 owned', detail:'Cosmetic tractor, pump, sensor and greenhouse themes tied to achievements.'),
          const RewardCard(icon:Icons.handyman_outlined, title:'Practical farm rewards', status:'Partner hook', detail:'Reward catalog can support seed discounts, sensor credits, soil tests, agronomy sessions, insurance or input vouchers.'),
          const RewardCard(icon:Icons.workspace_premium_outlined, title:'Verified certificates', status:'Eligible', detail:'Season-completion certificates can summarize verified water, crop-health and learning achievements.'),
          const SizedBox(height: 14),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text('Practical rewards should be funded by cooperatives, agribusinesses, insurers, NGOs, development programs or sponsors. Reward eligibility must be based on verified events, not self-reported button presses.'),
            ),
          ),
        ],

        const SizedBox(height: 18),
        const SectionTitle('RPG verification rules'),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'Field XP, companion bond, league score and reward eligibility are awarded by trusted backend events. Evidence can include satellite observations, IoT telemetry, timestamped crop images, crop-cycle records, sensor uptime, harvest outcomes, agronomist/cooperative verification and completed learning modules. The system must not reward excessive irrigation, unsafe chemical use, data fabrication or risky actuator behavior.',
            ),
          ),
        ),
      ],
    );
  }
}

class FieldRpgCard extends StatelessWidget {
  final String name, crop, xp, health, stage, trait;
  final int level;
  final double progress;
  const FieldRpgCard({super.key, required this.name, required this.crop, required this.level, required this.xp, required this.health, required this.stage, required this.progress, required this.trait});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(child: Text('$level')),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$name • $crop', style: const TextStyle(fontWeight: FontWeight.w900)),
            Text('Field Level $level • $stage', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ])),
          Chip(label: Text(health)),
        ]),
        const SizedBox(height: 9),
        LinearProgressIndicator(value: progress, minHeight: 8),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: Text(xp, style: const TextStyle(fontSize: 10))),
          Text('Trait: $trait', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        ]),
      ]),
    ),
  );
}

class CompanionCard extends StatelessWidget {
  final String name, type, icon, bond, status, perk;
  const CompanionCard({super.key, required this.name, required this.type, required this.icon, required this.bond, required this.status, required this.perk});

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Text(icon, style: const TextStyle(fontSize: 22))),
      title: Text('$name • $type', style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text('$status\nPerk: $perk'),
      isThreeLine: true,
      trailing: Chip(label: Text(bond)),
    ),
  );
}

class SeasonBanner extends StatelessWidget {
  const SeasonBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: const Color(0xFFE8F5E9),
    ),
    child: const Row(children: [
      CircleAvatar(child: Icon(Icons.calendar_month)),
      SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Long Rains Campaign • Maize + Tomato', style: TextStyle(fontWeight: FontWeight.w900)),
        SizedBox(height: 3),
        Text('Missions advance with real crop stages, not arbitrary calendar days.', style: TextStyle(fontSize: 11)),
      ])),
      Text('41%', style: TextStyle(fontWeight: FontWeight.w900)),
    ]),
  );
}

class SeasonalMissionCard extends StatelessWidget {
  final String title, detail, xp, stage;
  final double progress;
  const SeasonalMissionCard({super.key, required this.title, required this.detail, required this.xp, required this.progress, required this.stage});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.flag_circle_outlined),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900))),
          Text(xp, style: const TextStyle(fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 4),
        Text(stage, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(detail, style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 9),
        LinearProgressIndicator(value: progress, minHeight: 8),
      ]),
    ),
  );
}

class LeagueRow extends StatelessWidget {
  final String rank, farm, score, badge;
  const LeagueRow({super.key, required this.rank, required this.farm, required this.score, required this.badge});

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Text(rank)),
      title: Text(farm, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(badge),
      trailing: Text(score, style: const TextStyle(fontWeight: FontWeight.w900)),
    ),
  );
}

class RewardCard extends StatelessWidget {
  final IconData icon;
  final String title, status, detail;
  const RewardCard({super.key, required this.icon, required this.title, required this.status, required this.detail});

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(detail),
      trailing: Chip(label: Text(status)),
    ),
  );
}

class GameStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const GameStat({super.key, required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 155,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Icon(icon),
          const SizedBox(width: 9),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ]),
        ]),
      ),
    ),
  );
}

class QuestCard extends StatelessWidget {
  final String title, detail, xp;
  final double progress;
  const QuestCard({super.key, required this.title, required this.detail, required this.xp, required this.progress});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(child: Icon(Icons.flag_outlined)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(detail, style: const TextStyle(fontSize: 11)),
          ])),
          Text(xp, style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(value: progress, minHeight: 8),
        ),
      ]),
    ),
  );
}

class BadgeCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const BadgeCard({super.key, required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 165,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          CircleAvatar(radius: 22, child: Icon(icon)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}

class CommunityChallenge extends StatelessWidget {
  final String title, detail, reward;
  final double progress;
  const CommunityChallenge({super.key, required this.title, required this.detail, required this.progress, required this.reward});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.groups_2_outlined),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 6),
        Text(detail),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: progress, minHeight: 8),
        const SizedBox(height: 7),
        Text(reward, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}
