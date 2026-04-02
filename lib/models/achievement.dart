import 'dart:convert';

import 'package:flutter/material.dart';

/// Defines all achievements available in the game.
enum AchievementId {
  firstFarm,
  speedFarmer,
  horseWhisperer,
  dogLover,
  survivor,
  foxOutsmarted,
  fullBarn,
  underdog,
  farmerPro,
  luckyRoller,
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.targetProgress,
  });

  final AchievementId id;
  final String name;
  final String description;
  final IconData icon;

  /// For multi-step achievements (e.g. 50 for Farmer Pro, 5 for Fox Outsmarted).
  /// Null means single-step (unlock on first trigger).
  final int? targetProgress;

  static const List<AchievementDefinition> all = [
    AchievementDefinition(
      id: AchievementId.firstFarm,
      name: 'First Farm',
      description: 'Win your first game',
      icon: Icons.emoji_events,
    ),
    AchievementDefinition(
      id: AchievementId.speedFarmer,
      name: 'Speed Farmer',
      description: 'Win in under 15 turns',
      icon: Icons.timer,
    ),
    AchievementDefinition(
      id: AchievementId.horseWhisperer,
      name: 'Horse Whisperer',
      description: 'Win with 3+ horses',
      icon: Icons.pets,
    ),
    AchievementDefinition(
      id: AchievementId.dogLover,
      name: 'Dog Lover',
      description: 'Own both dogs simultaneously',
      icon: Icons.favorite,
    ),
    AchievementDefinition(
      id: AchievementId.survivor,
      name: 'Survivor',
      description: 'Survive 3 wolf attacks in one game',
      icon: Icons.shield,
    ),
    AchievementDefinition(
      id: AchievementId.foxOutsmarted,
      name: 'Fox Outsmarted',
      description: 'Block 5 fox attacks total (across games)',
      icon: Icons.psychology,
      targetProgress: 5,
    ),
    AchievementDefinition(
      id: AchievementId.fullBarn,
      name: 'Full Barn',
      description: 'Have 10+ of every animal at once',
      icon: Icons.warehouse,
    ),
    AchievementDefinition(
      id: AchievementId.underdog,
      name: 'Underdog',
      description: 'Win from behind (lowest % at turn 20+)',
      icon: Icons.collections,
    ),
    AchievementDefinition(
      id: AchievementId.farmerPro,
      name: 'Farmer Pro',
      description: 'Win 50 games',
      icon: Icons.star,
      targetProgress: 50,
    ),
    AchievementDefinition(
      id: AchievementId.luckyRoller,
      name: 'Lucky Roller',
      description: 'Roll double horse',
      icon: Icons.casino,
    ),
  ];

  static AchievementDefinition getById(AchievementId id) =>
      all.firstWhere((a) => a.id == id);
}

/// Persisted state of a single achievement for a player.
class AchievementState {
  const AchievementState({
    required this.id,
    this.unlocked = false,
    this.unlockedAt,
    this.progress = 0,
  });

  final AchievementId id;
  final bool unlocked;
  final DateTime? unlockedAt;

  /// Current progress towards targetProgress. Only meaningful for multi-step achievements.
  final int progress;

  AchievementState copyWith({
    bool? unlocked,
    DateTime? unlockedAt,
    int? progress,
  }) {
    return AchievementState(
      id: id,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id.name,
        'unlocked': unlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
        'progress': progress,
      };

  factory AchievementState.fromJson(Map<String, dynamic> json) {
    return AchievementState(
      id: AchievementId.values.firstWhere((e) => e.name == json['id']),
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      progress: json['progress'] as int? ?? 0,
    );
  }

  static String encode(List<AchievementState> states) =>
      jsonEncode(states.map((s) => s.toJson()).toList());

  static List<AchievementState> decode(String source) =>
      (jsonDecode(source) as List)
          .map((e) => AchievementState.fromJson(e as Map<String, dynamic>))
          .toList();
}
