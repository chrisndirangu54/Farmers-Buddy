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


## Farm RPG system

The gamification layer is structured as a farm role-playing system tied to real agronomic state.

### Evolving fields

Each real field has a persistent RPG profile with:
- field level
- XP
- crop stage
- crop-health state
- water-efficiency state
- scouting coverage
- device reliability
- unlocked traits
- seasonal history
- harvest-quality history

Field progression should be driven by verified outcomes such as healthy crop development, efficient water use, successful early intervention, sensor reliability, completion of crop-stage tasks and harvest quality.

### Crop health states

Crops can expose game-friendly states such as Thriving, Stable, Watch, Stressed, Recovering, At Risk and Harvest Ready. These labels should be derived from real agronomic signals and must never hide the underlying measurements or confidence.

### Sensor companions

Connected devices can appear as companion characters while retaining their engineering identity. Examples include Maji the Soil Scout, Jua the Climate Sentinel, Nyuki the Crop Watcher and Mlinzi the Gateway Guardian. Companion bond levels rise through verified uptime, useful observations and successful decisions. Perks are motivational UI effects and should not bypass safety rules or alter raw sensor data.

### Seasonal missions

Missions follow the actual crop cycle: establishment, vegetative growth, flowering, fruiting/grain filling, maturity and harvest. Mission generation can use crop type, planting date, phenology, weather, satellite health, sensor events, scouting history and unresolved risks.

### Cooperative leagues

Players can compete individually or through cooperatives. Ranking inputs should emphasize verified outcomes such as water efficiency, crop health, early pest detection, learning, regenerative practices, harvest quality and data reliability rather than farm size alone.

### Unlocks and rewards

Verified improvement can unlock:
- farm titles
- equipment skins
- sensor/greenhouse themes
- seasonal trophies
- cooperative ranking badges
- completion certificates
- sponsor-funded practical rewards such as seed discounts, sensor credits, soil tests, agronomy sessions, insurance incentives or input vouchers

Practical rewards should be partner-funded and verified server-side.

### Recommended RPG collections

Recommended additional collections include:
`farm_rpg_profiles`, `field_levels`, `field_traits`, `crop_state_history`, `companions`, `companion_bonds`, `season_campaigns`, `season_missions`, `mission_progress`, `league_entries`, `league_seasons`, `cosmetics`, `unlocks`, `reward_catalog`, `reward_claims`, and `verification_events`.

### Anti-cheat and integrity

All XP, level, league and reward events should be created by trusted backend logic. Evidence should reference source events such as telemetry IDs, satellite observations, timestamped images, verified harvests, agronomist review or learning completion. Client-side taps must never directly mint XP or practical rewards.

## Live Firebase RPG

The Farm RPG is now wired for live Firebase state.

### Live client streams

The Flutter RPG screen listens to:

- `farm_rpg_profiles/{farmId}`
- `field_levels`
- `companions`
- `season_missions`
- `league_entries`
- `rewards`

The app resolves the signed-in user's first accessible farm from the `farms` collection and streams RPG updates in real time.

### Server-authoritative progression

XP and progression are processed in Firebase Cloud Functions from `verification_events`. The client cannot write directly to XP, levels, companion bonds, league scores or reward state.

Current verified event types include:

- `water_efficiency`
- `crop_health_improvement`
- `verified_scout_observation`
- `device_uptime`
- `harvest_quality`
- `learning_completion`

The server updates farm XP/levels, selected field progression, companion bond state and cooperative league scores transactionally.

### Required deployment

After running `flutterfire configure`, deploy the backend with:

`cd functions && npm install && npm run build`

then from the repository root:

`firebase deploy --only functions,firestore:rules,firestore:indexes`

Production ingestion services should create verified events only after validating their source, such as signed IoT telemetry, trusted satellite processing, verified crop scans, harvest records, agronomist/cooperative review or authenticated learning completion.


## Physical farm → RPG verification pipelines

Farmers Buddy now includes a normalized pipeline for turning physical-farm observations into trusted `verification_events`.

### 1. ESP32 / IoT telemetry

`ingestIotTelemetry` accepts signed telemetry from field gateways. It rejects stale payloads and invalid HMAC signatures, stores raw telemetry, and can emit:

- `device_uptime`
- `water_efficiency`

Water-efficiency scoring no longer trusts a target supplied by the device. It reads the current server-generated target from `field_water_targets/{fieldId}`.

### 2. Weather-derived irrigation target

`deriveWeatherWaterTarget` converts trusted `weather_snapshots` into a field water target using:

- ET0
- crop coefficient
- effective rainfall
- field area
- soil-moisture correction
- forecast confidence

The target is stored in `field_water_targets` and is used by IoT scoring.

### 3. Satellite processing

External EO workers can post signed results through `ingestSatelliteObservation`. The resulting `satellite_observations` are quality-gated by cloud fraction and provider quality flags before `processSatelliteObservation` can emit a `crop_health_improvement` event.

### 4. Camera crop diagnosis

The mobile app can create a scan job through `submitCropScan` using a Firebase Storage path. `dispatchCropScan` sends that job to a configured external crop-diagnosis worker. The worker returns signed normalized results through `ingestCropScanResult`.

A crop result only becomes `verified_scout_observation` when confidence and review/model-trust conditions are satisfied.

### 5. Harvest records

Farm members submit harvests through `submitHarvestRecord`. Harvests start as `pending`. An authenticated user with the `agronomist` role can verify them through `verifyHarvestRecord`. Verified harvests emit `harvest_quality` events.

### 6. Agronomist verification

`submitAgronomistVerification` checks Firebase Authentication and the verifier's `agronomist` role before creating an approval record. Approved records are converted into trusted verification events by `processAgronomistVerification`.

### 7. Trusted weather, satellite and AI ingestion

The backend exposes HMAC-protected normalized ingestion endpoints for:

- weather snapshots
- satellite observations
- crop-diagnosis results

These adapters allow any provider or worker to integrate without giving it direct access to RPG collections.

### Required backend environment variables

Configure these with your Firebase/Google Cloud secret-management workflow:

- `IOT_SHARED_SECRET`
- `WEATHER_INGEST_SECRET`
- `SATELLITE_INGEST_SECRET`
- `CROP_SCAN_INGEST_SECRET`
- `CROP_DIAGNOSIS_ENDPOINT`
- `CROP_DIAGNOSIS_TOKEN`

Do not store these values in Flutter, GitHub, firmware source or public configuration files.

### Event flow

```text
ESP32 / Weather / Satellite / Camera / Harvest / Agronomist
                       ↓
              trusted source adapter
                       ↓
            normalized source document
                       ↓
           validation / quality gating
                       ↓
              verification_events
                       ↓
             processVerificationEvent
                       ↓
 farm XP + field levels + companions + league + rewards
```

This design preserves source provenance through `source`, `sourceRef`, timestamps, confidence/quality fields and verifier identifiers.
