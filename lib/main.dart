import 'package:flutter/material.dart';

void main() => runApp(const FarmersBuddyApp());

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
