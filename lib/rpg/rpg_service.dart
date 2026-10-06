import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class RpgService {
  RpgService(this.db);
  final FirebaseFirestore db;

  Stream<FarmRpgProfile?> profile(String farmId) {
    return db.collection('farm_rpg_profiles').doc(farmId).snapshots().map(
      (doc) => doc.exists ? FarmRpgProfile.fromDoc(doc) : null,
    );
  }

  Stream<List<FieldRpgState>> fields(String farmId) {
    return db
        .collection('field_levels')
        .where('farmId', isEqualTo: farmId)
        .orderBy('level', descending: true)
        .snapshots()
        .map((q) => q.docs.map(FieldRpgState.fromDoc).toList());
  }

  Stream<List<CompanionState>> companions(String farmId) {
    return db
        .collection('companions')
        .where('farmId', isEqualTo: farmId)
        .snapshots()
        .map((q) => q.docs.map(CompanionState.fromDoc).toList());
  }

  Stream<List<SeasonMission>> missions(String farmId) {
    return db
        .collection('season_missions')
        .where('farmId', isEqualTo: farmId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((q) => q.docs.map(SeasonMission.fromDoc).toList());
  }

  Stream<List<LeagueEntry>> league(String seasonId) {
    return db
        .collection('league_entries')
        .where('seasonId', isEqualTo: seasonId)
        .orderBy('score', descending: true)
        .limit(50)
        .snapshots()
        .map((q) {
          var rank = 0;
          return q.docs.map((doc) {
            rank += 1;
            final d = doc.data();
            return LeagueEntry(
              id: doc.id,
              name: d['name'] ?? 'Farm',
              score: (d['score'] ?? 0) as int,
              badge: d['badge'] ?? '',
              rank: rank,
            );
          }).toList();
        });
  }

  Stream<List<RewardItem>> rewards(String farmId) {
    return db
        .collection('rewards')
        .where('farmId', isEqualTo: farmId)
        .snapshots()
        .map((q) => q.docs.map(RewardItem.fromDoc).toList());
  }

  Future<void> requestRewardClaim({
    required String farmId,
    required String rewardId,
    required String requestedBy,
  }) {
    return db.collection('reward_claims').add({
      'farmId': farmId,
      'rewardId': rewardId,
      'requestedBy': requestedBy,
      'status': 'pending_verification',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
