import '../../core/utils/stats_engine.dart';

class Program {
  const Program({
    required this.id,
    required this.name,
    required this.days,
    required this.currentDay,
    required this.progress,
    required this.exerciseIds,
  });

  final String id;
  final String name;
  final int days;
  final int currentDay;
  final double progress;
  final List<String> exerciseIds;

  int get currentExerciseIndex => StatsEngine.programExerciseIndex(
        progress: progress,
        exerciseCount: exerciseIds.length,
      );

  String? get currentExerciseId => exerciseIds.isEmpty
      ? null
      : exerciseIds[currentExerciseIndex.clamp(0, exerciseIds.length - 1)];

  Program copyWith({
    String? id,
    String? name,
    int? days,
    int? currentDay,
    double? progress,
    List<String>? exerciseIds,
  }) {
    return Program(
      id: id ?? this.id,
      name: name ?? this.name,
      days: days ?? this.days,
      currentDay: currentDay ?? this.currentDay,
      progress: progress ?? this.progress,
      exerciseIds: exerciseIds ?? this.exerciseIds,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'days': days,
        'currentDay': currentDay,
        'progress': progress,
        'exerciseIds': exerciseIds,
      };

  factory Program.fromJson(Map<String, dynamic> json) => Program(
        id: json['id'] as String,
        name: json['name'] as String,
        days: (json['days'] as num).toInt(),
        currentDay: (json['currentDay'] as num).toInt(),
        progress: (json['progress'] as num).toDouble(),
        exerciseIds:
            (json['exerciseIds'] as List<dynamic>).cast<String>(),
      );
}
