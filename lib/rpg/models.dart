import 'package:cloud_firestore/cloud_firestore.dart';

class FarmRpgProfile {
  final String farmId;
  final String ownerUid;
  final int level;
  final int xp;
  final int streakDays;
  final String title;
  final int vitality;
  final double waterEfficiencyScore;
  final double scoutCoverage;
  final double deviceReliability;

  const FarmRpgProfile({
    required this.farmId,
    required this.ownerUid,
    required this.level,
    required this.xp,
    required this.streakDays,
    required this.title,
    required this.vitality,
    required this.waterEfficiencyScore,
    required this.scoutCoverage,
    required this.deviceReliability,
  });

  factory FarmRpgProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return FarmRpgProfile(
      farmId: doc.id,
      ownerUid: d['ownerUid'] ?? '',
      level: (d['level'] ?? 1) as int,
      xp: (d['xp'] ?? 0) as int,
      streakDays: (d['streakDays'] ?? 0) as int,
      title: d['title'] ?? 'New Grower',
      vitality: (d['vitality'] ?? 0) as int,
      waterEfficiencyScore: ((d['waterEfficiencyScore'] ?? 0) as num).toDouble(),
      scoutCoverage: ((d['scoutCoverage'] ?? 0) as num).toDouble(),
      deviceReliability: ((d['deviceReliability'] ?? 0) as num).toDouble(),
    );
  }
}

class FieldRpgState {
  final String id;
  final String farmId;
  final String name;
  final String crop;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final String health;
  final String stage;
  final String trait;

  const FieldRpgState({
    required this.id,
    required this.farmId,
    required this.name,
    required this.crop,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.health,
    required this.stage,
    required this.trait,
  });

  factory FieldRpgState.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return FieldRpgState(
      id: doc.id,
      farmId: d['farmId'] ?? '',
      name: d['name'] ?? 'Field',
      crop: d['crop'] ?? 'Unknown crop',
      level: (d['level'] ?? 1) as int,
      xp: (d['xp'] ?? 0) as int,
      xpToNextLevel: (d['xpToNextLevel'] ?? 100) as int,
      health: d['health'] ?? 'Unknown',
      stage: d['stage'] ?? 'Unknown',
      trait: d['trait'] ?? 'Unassigned',
    );
  }
}

class CompanionState {
  final String id;
  final String farmId;
  final String name;
  final String type;
  final String icon;
  final int bondLevel;
  final String status;
  final String perk;
  final double uptime;

  const CompanionState({
    required this.id,
    required this.farmId,
    required this.name,
    required this.type,
    required this.icon,
    required this.bondLevel,
    required this.status,
    required this.perk,
    required this.uptime,
  });

  factory CompanionState.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return CompanionState(
      id: doc.id,
      farmId: d['farmId'] ?? '',
      name: d['name'] ?? 'Companion',
      type: d['type'] ?? 'Sensor',
      icon: d['icon'] ?? '🤖',
      bondLevel: (d['bondLevel'] ?? 1) as int,
      status: d['status'] ?? 'Unknown',
      perk: d['perk'] ?? 'None',
      uptime: ((d['uptime'] ?? 0) as num).toDouble(),
    );
  }
}

class SeasonMission {
  final String id;
  final String farmId;
  final String title;
  final String detail;
  final String cropStage;
  final int rewardXp;
  final double progress;
  final String status;

  const SeasonMission({
    required this.id,
    required this.farmId,
    required this.title,
    required this.detail,
    required this.cropStage,
    required this.rewardXp,
    required this.progress,
    required this.status,
  });

  factory SeasonMission.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SeasonMission(
      id: doc.id,
      farmId: d['farmId'] ?? '',
      title: d['title'] ?? 'Mission',
      detail: d['detail'] ?? '',
      cropStage: d['cropStage'] ?? '',
      rewardXp: (d['rewardXp'] ?? 0) as int,
      progress: ((d['progress'] ?? 0) as num).toDouble(),
      status: d['status'] ?? 'active',
    );
  }
}

class LeagueEntry {
  final String id;
  final String name;
  final int score;
  final String badge;
  final int rank;

  const LeagueEntry({
    required this.id,
    required this.name,
    required this.score,
    required this.badge,
    required this.rank,
  });

  factory LeagueEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return LeagueEntry(
      id: doc.id,
      name: d['name'] ?? 'Farm',
      score: (d['score'] ?? 0) as int,
      badge: d['badge'] ?? '',
      rank: (d['rank'] ?? 0) as int,
    );
  }
}

class RewardItem {
  final String id;
  final String title;
  final String type;
  final String detail;
  final String status;
  final int requiredLevel;
  final int requiredXp;

  const RewardItem({
    required this.id,
    required this.title,
    required this.type,
    required this.detail,
    required this.status,
    required this.requiredLevel,
    required this.requiredXp,
  });

  factory RewardItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return RewardItem(
      id: doc.id,
      title: d['title'] ?? 'Reward',
      type: d['type'] ?? 'digital',
      detail: d['detail'] ?? '',
      status: d['status'] ?? 'locked',
      requiredLevel: (d['requiredLevel'] ?? 1) as int,
      requiredXp: (d['requiredXp'] ?? 0) as int,
    );
  }
}
