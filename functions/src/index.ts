import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { onDocumentCreated, onDocumentWritten } from 'firebase-functions/v2/firestore';

initializeApp();
const db = getFirestore();

function xpFor(kind: string, value: number): number {
  if (kind === 'water_efficiency' && value >= 0.8) return 80;
  if (kind === 'crop_health_improvement' && value > 0) return 120;
  if (kind === 'verified_scout_observation') return 40;
  if (kind === 'device_uptime' && value >= 0.95) return 35;
  if (kind === 'harvest_quality') return 180;
  if (kind === 'learning_completion') return 30;
  return 0;
}

export const processVerificationEvent = onDocumentCreated(
  'verification_events/{eventId}',
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    if (data.verified !== true || !data.farmId) return;

    const eventRef = snap.ref;
    const farmId = String(data.farmId);
    const kind = String(data.kind ?? '');
    const value = Number(data.value ?? 0);
    const fieldId = data.fieldId ? String(data.fieldId) : null;
    const deviceId = data.deviceId ? String(data.deviceId) : null;
    const xp = xpFor(kind, value);

    await db.runTransaction(async (tx) => {
      const fresh = await tx.get(eventRef);
      if (!fresh.exists || fresh.data()?.processedAt) return;

      const profileRef = db.collection('farm_rpg_profiles').doc(farmId);
      const profileSnap = await tx.get(profileRef);
      const old = profileSnap.data() ?? {};
      const oldXp = Number(old.xp ?? 0);
      const newXp = oldXp + xp;
      const level = 1 + Math.floor(newXp / 500);

      const patch: Record<string, unknown> = {
        farmId,
        ownerUid: old.ownerUid ?? data.ownerUid ?? '',
        xp: newXp,
        level,
        updatedAt: FieldValue.serverTimestamp(),
      };

      if (kind === 'water_efficiency') patch.waterEfficiencyScore = value;
      if (kind === 'verified_scout_observation') {
        patch.scoutCoverage = Math.min(1, Number(old.scoutCoverage ?? 0) + 0.05);
      }
      if (kind === 'device_uptime') patch.deviceReliability = value;
      if (kind === 'crop_health_improvement') {
        patch.vitality = Math.min(100, Number(old.vitality ?? 50) + Math.max(1, Math.round(value * 10)));
      }

      tx.set(profileRef, patch, { merge: true });

      if (fieldId && xp > 0) {
        const fieldRef = db.collection('field_levels').doc(fieldId);
        const fieldSnap = await tx.get(fieldRef);
        const current = fieldSnap.data() ?? {};
        const fieldXp = Number(current.xp ?? 0) + xp;
        const fieldLevel = 1 + Math.floor(fieldXp / 250);
        tx.set(fieldRef, {
          farmId,
          xp: fieldXp,
          level: fieldLevel,
          xpToNextLevel: fieldLevel * 250,
          health: data.cropHealth ?? current.health ?? 'Unknown',
          stage: data.cropStage ?? current.stage ?? 'Unknown',
          trait: current.trait ?? 'Unassigned',
          updatedAt: FieldValue.serverTimestamp(),
        }, { merge: true });
      }

      if (deviceId && kind === 'device_uptime') {
        const companionRef = db.collection('companions').doc(deviceId);
        const companionSnap = await tx.get(companionRef);
        const current = companionSnap.data() ?? {};
        const oldBond = Number(current.bondLevel ?? 1);
        const bond = value >= 0.99 ? oldBond + 1 : oldBond;
        tx.set(companionRef, {
          farmId,
          uptime: value,
          bondLevel: bond,
          status: value >= 0.95 ? 'Healthy' : 'Needs attention',
          updatedAt: FieldValue.serverTimestamp(),
        }, { merge: true });
      }

      tx.update(eventRef, {
        processedAt: FieldValue.serverTimestamp(),
        xpAwarded: xp,
      });
    });
  }
);

export const syncLeagueEntry = onDocumentWritten(
  'farm_rpg_profiles/{farmId}',
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;
    const farmId = event.params.farmId;
    const profile = after.data();
    const farmSnap = await db.collection('farms').doc(farmId).get();
    const farm = farmSnap.data() ?? {};

    const score =
      Number(profile.xp ?? 0)
      + Math.round(Number(profile.waterEfficiencyScore ?? 0) * 500)
      + Math.round(Number(profile.scoutCoverage ?? 0) * 300)
      + Math.round(Number(profile.deviceReliability ?? 0) * 200)
      + Math.round(Number(profile.vitality ?? 0) * 10);

    await db.collection('league_entries').doc(farmId).set({
      farmId,
      seasonId: 'current',
      name: farm.name ?? 'Farm',
      score,
      badge: profile.title ?? 'Grower',
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
  }
);


export { ingestIotTelemetry } from './pipelines/iot';
export { processSatelliteObservation } from './pipelines/satellite';
export { processCropScan } from './pipelines/crop_scan';
export { scoreWeatherAwareIrrigation } from './pipelines/weather_irrigation';
export { processHarvestRecord } from './pipelines/harvest';
export { processAgronomistVerification } from './pipelines/agronomist';
export { submitAgronomistVerification } from './pipelines/agronomist_callable';

export { deriveWeatherWaterTarget } from './pipelines/weather_target';
export { ingestWeatherSnapshot, ingestSatelliteObservation, ingestCropScanResult } from './pipelines/trusted_ingest';
export { submitHarvestRecord, verifyHarvestRecord } from './pipelines/harvest_callable';
export { submitCropScan, dispatchCropScan } from './pipelines/crop_scan_dispatch';
export { bootstrapSuperAdmin, setUserAdminRole, updateSystemSetting, updateModelConfig, upsertApiSecret, disableApiSecret } from './admin';
