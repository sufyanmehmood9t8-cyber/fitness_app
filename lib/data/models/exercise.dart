class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.bodyParts,
    required this.durationSec,
    required this.imageAsset,
    required this.steps,
  });

  final String id;
  final String name;
  final String category;
  final List<String> bodyParts;
  final int durationSec;
  final String imageAsset;
  final List<String> steps;

  String get durationLabel {
    if (durationSec < 60) return '$durationSec Seconds';
    final minutes = durationSec ~/ 60;
    final seconds = durationSec % 60;
    return seconds == 0 ? '$minutes Minutes' : '$minutes min $seconds sec';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'category': category,
        'bodyParts': bodyParts,
        'durationSec': durationSec,
        'imageAsset': imageAsset,
        'steps': steps,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        bodyParts: (json['bodyParts'] as List<dynamic>).cast<String>(),
        durationSec: json['durationSec'] as int,
        imageAsset: json['imageAsset'] as String,
        steps: (json['steps'] as List<dynamic>).cast<String>(),
      );
}
