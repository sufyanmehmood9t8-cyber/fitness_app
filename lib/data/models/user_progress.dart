import 'program.dart';
import 'user_stats.dart';

class UserProgress {
  const UserProgress({
    required this.stats,
    required this.program,
    required this.completedSessionIds,
  });

  final UserStats stats;
  final Program program;
  final List<String> completedSessionIds;

  UserProgress copyWith({
    UserStats? stats,
    Program? program,
    List<String>? completedSessionIds,
  }) {
    return UserProgress(
      stats: stats ?? this.stats,
      program: program ?? this.program,
      completedSessionIds:
          completedSessionIds ?? this.completedSessionIds,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'stats': stats.toJson(),
        'program': program.toJson(),
        'completedSessionIds': completedSessionIds,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        stats: UserStats.fromJson(
          Map<String, dynamic>.from(json['stats'] as Map),
        ),
        program: Program.fromJson(
          Map<String, dynamic>.from(json['program'] as Map),
        ),
        completedSessionIds:
            (json['completedSessionIds'] as List<dynamic>? ?? <dynamic>[])
                .cast<String>(),
      );
}
