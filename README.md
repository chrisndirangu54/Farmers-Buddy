# Farmers Buddy

Farmers Buddy is a Flutter + Firebase smart-farming application for field monitoring, controlled-environment agriculture, IoT/embedded systems, crop imagery, satellite observations, weather intelligence and farm automation.

## Product scope

- Satellite crop monitoring: NDVI, EVI, NDWI, vegetation anomalies, water stress and field boundaries.
- Crop images and camera monitoring: disease, pests, nutrient deficiency, canopy change, harvest maturity and intrusion/event detection.
- Weather and climate: rainfall, temperature, humidity, wind, solar radiation, UV, evapotranspiration, heat/frost risk and forecast-aware operations.
- IoT / edge: soil moisture, temperature, humidity, EC, pH, NPK, PAR/light, CO2, water level, pressure, flow meters and energy monitoring.
- Automation: irrigation, pumps, valves, fertigation, fans, vents, misting, heating, greenhouse lights, alarms and safe manual override.
- Controlled environment: greenhouse, hydroponic, aeroponic and aquaponic recipes and telemetry.
- AI agronomy: crop-photo diagnosis, anomaly detection, yield forecast, crop-stage inference, harvest readiness, farm copilot and farm digital twin.
- Market intelligence: farm-gate/wholesale price monitoring, buyer matching, expected harvest supply, price-risk alerts and profitability scenarios.
- Operations: tasks, crop calendar, input inventory, traceability, labor, equipment maintenance, water/energy use and reports.

## Architecture

```text
Flutter app
  ├─ Firebase Auth
  ├─ Firestore farm state / events
  ├─ Cloud Storage crop images
  ├─ FCM alerts
  ├─ HTTPS API gateway / Cloud Functions
  │   ├─ Weather provider
  │   ├─ Earth-observation provider
  │   ├─ Market-price provider
  │   └─ AI inference services
  └─ IoT gateway
      ├─ ESP32 / LoRa / Wi-Fi / BLE
      ├─ MQTT / HTTPS telemetry
      └─ relay/actuator safety controller
```

## Important safety model

Pump, valve, nutrient-dosing, lighting and greenhouse automation must use authenticated commands, device-level limits, watchdogs, fail-safe states and manual override. The mobile UI should request actions; safety-critical control remains on the edge/controller or a trusted backend.

## Firebase collections

Recommended collections: `users`, `farms`, `fields`, `crop_cycles`, `observations`, `satellite_scenes`, `weather_snapshots`, `devices`, `telemetry`, `automation_rules`, `actuation_commands`, `alerts`, `crop_scans`, `harvests`, `market_prices`, `tasks`, `inventories`, `audit_logs`.

## Run

1. Install Flutter 3.x.
2. Run `flutter pub get`.
3. Run `flutterfire configure` and add generated Firebase configuration files.
4. Configure server-side weather, satellite, AI and market integrations; do not put secret keys in the Flutter client.
5. Run `flutter run`.

The initial UI uses explicit demo-state values until verified data providers and devices are connected.


## Gamification

Farmers Buddy includes a gamification layer designed to reward real agronomic outcomes rather than simple app activity.

### Core mechanics

- XP and farmer levels
- Verified streaks
- Daily, weekly and seasonal quests
- Skill badges
- Farm-health milestones
- Water-efficiency challenges
- Crop-scanning and pest-scouting quests
- Device-maintenance quests
- Learning quests
- Harvest-quality achievements
- Community and county challenges
- Cooperative competitions
- Leaderboards based on verified performance
- Sponsor or cooperative rewards where appropriate

### Verification model

High-value XP should be awarded by trusted backend events rather than direct client actions. Evidence can come from:

- IoT telemetry
- satellite or remote-sensing observations
- timestamped/georeferenced crop photos
- verified field records
- sensor uptime
- irrigation and water-flow measurements
- completed agronomy lessons or quizzes
- harvest records
- cooperative or agronomist verification

Recommended additional Firestore collections: `player_profiles`, `xp_events`, `quests`, `quest_progress`, `badges`, `user_badges`, `streaks`, `community_challenges`, `challenge_progress`, `leaderboards`, `seasons`, `rewards`, and `reward_claims`.

### Anti-gaming and safety

Do not reward users for actions that could encourage excessive irrigation, unsafe chemical use, over-fertilization or fabricated field records. Reward efficiency, verified improvement, early detection, healthy crop outcomes, timely maintenance and evidence-backed learning instead.

Examples:

- **Water Guardian** — keep irrigation inside a crop-specific water budget.
- **Pest Scout** — submit verified pest or disease observations early.
- **Sensor Steward** — maintain reliable connected devices.
- **Soil Builder** — complete verified regenerative soil practices.
- **Healthy Harvest** — reach harvest readiness without unresolved critical alerts.
- **Climate-Smart Farmer** — adapt field decisions to weather and water data.
- **Community Water Challenge** — cooperatively reduce avoidable water use.
