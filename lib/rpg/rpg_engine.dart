import 'package:cloud_firestore/cloud_firestore.dart';

class RpgEngine {
  RpgEngine(this.db);
  final FirebaseFirestore db;

  Future<void> processVerificationEvent(String eventId) async {
    final ref = db.collection('verification_events').doc(eventId);

    await db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final event = snap.data()!;
      if (event['processedAt'] != null) return;
      if (event['verified'] != true) return;

      final farmId = event['farmId'] as String?;
      if (farmId == null) return;

      final kind = event['kind'] as String? ?? '';
      final value = ((event['value'] ?? 0) as num).toDouble();
      final profileRef = db.collection('farm_rpg_profiles').doc(farmId);
      final profile = await tx.get(profileRef);
      final existing = profile.data() ?? <String, dynamic>{};

      var xpAward = 0;
      if (kind == 'water_efficiency' && value >= 0.8) xpAward = 80;
      if (kind == 'crop_health_improvement' && value > 0) xpAward = 120;
      if (kind == 'verified_scout_observation') xpAward = 40;
      if (kind == 'device_uptime' && value >= 0.95) xpAward = 35;
      if (kind == 'harvest_quality') xpAward = 180;
      if (kind == 'learning_completion') xpAward = 30;

      if (xpAward <= 0) {
        tx.update(ref, {'processedAt': FieldValue.serverTimestamp(), 'xpAwarded': 0});
        return;
      }

      final oldXp = (existing['xp'] ?? 0) as int;
      final newXp = oldXp + xpAward;
      final newLevel = 1 + (newXp ~/ 500);

      tx.set(profileRef, {
        ...existing,
        'farmId': farmId,
        'xp': newXp,
        'level': newLevel,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      tx.update(ref, {
        'processedAt': FieldValue.serverTimestamp(),
        'xpAwarded': xpAward,
      });
    });
  }
}
