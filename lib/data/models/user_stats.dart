class UserStats {
  const UserStats({
    required this.xp,
    required this.streak,
    required this.totalMinutes,
    this.lastWorkoutDate,
  });

  final int xp;
  final int streak;
  final int totalMinutes;
  final DateTime? lastWorkoutDate;

  UserStats copyWith({
    int? xp,
    int? streak,
    int? totalMinutes,
    DateTime? lastWorkoutDate,
  }) {
    return UserStats(
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'xp': xp,
        'streak': streak,
        'totalMinutes': totalMinutes,
        'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
      };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        streak: (json['streak'] as num?)?.toInt() ?? 0,
        totalMinutes: (json['totalMinutes'] as num?)?.toInt() ?? 0,
        lastWorkoutDate: DateTime.tryParse(
          json['lastWorkoutDate'] as String? ?? '',
        ),
      );
}
