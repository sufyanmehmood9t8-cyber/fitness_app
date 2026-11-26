/// Immutable state snapshot for the assessment flow.
library;

import '../constants/assessment_constants.dart';

class AssessmentState {
  const AssessmentState({
    this.currentStep = 0,
    this.name = '',
    this.gender = '',
    this.heightCm = 0,
    this.heightUnit = HeightUnit.feet,
    this.heightFeet = 4,
    this.heightInches = 6,
    this.weightKg = 0,
    this.weightUnit = WeightUnit.lb,
    this.fitnessLevel = '',
    this.occupation = '',
    this.sittingHours = -1,
    this.activityLevel = '',
    this.painAreas = const <String>[],
    this.flexibilityLevel = '',
    this.goals = const <String>[],
  });

  final int currentStep;
  final String name;
  final String gender;
  final double heightCm;
  final HeightUnit heightUnit;
  final int heightFeet;
  final int heightInches;
  final double weightKg;
  final WeightUnit weightUnit;
  final String fitnessLevel;
  final String occupation;
  final double sittingHours;
  final String activityLevel;
  final List<String> painAreas;
  final String flexibilityLevel;
  final List<String> goals;

  AssessmentState copyWith({
    int? currentStep,
    String? name,
    String? gender,
    double? heightCm,
    HeightUnit? heightUnit,
    int? heightFeet,
    int? heightInches,
    double? weightKg,
    WeightUnit? weightUnit,
    String? fitnessLevel,
    String? occupation,
    double? sittingHours,
    String? activityLevel,
    List<String>? painAreas,
    String? flexibilityLevel,
    List<String>? goals,
  }) {
    return AssessmentState(
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      heightUnit: heightUnit ?? this.heightUnit,
      heightFeet: heightFeet ?? this.heightFeet,
      heightInches: heightInches ?? this.heightInches,
      weightKg: weightKg ?? this.weightKg,
      weightUnit: weightUnit ?? this.weightUnit,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      occupation: occupation ?? this.occupation,
      sittingHours: sittingHours ?? this.sittingHours,
      activityLevel: activityLevel ?? this.activityLevel,
      painAreas: painAreas ?? this.painAreas,
      flexibilityLevel: flexibilityLevel ?? this.flexibilityLevel,
      goals: goals ?? this.goals,
    );
  }

  /// Serialise to a Map for Hive storage.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'currentStep': currentStep,
        'name': name,
        'gender': gender,
        'heightCm': heightCm,
        'heightUnit': heightUnit.index,
        'heightFeet': heightFeet,
        'heightInches': heightInches,
        'weightKg': weightKg,
        'weightUnit': weightUnit.index,
        'fitnessLevel': fitnessLevel,
        'occupation': occupation,
        'sittingHours': sittingHours,
        'activityLevel': activityLevel,
        'painAreas': painAreas,
        'flexibilityLevel': flexibilityLevel,
        'goals': goals,
      };

  /// Deserialise from Hive map.
  factory AssessmentState.fromJson(Map<String, dynamic> json) {
    return AssessmentState(
      currentStep: (json['currentStep'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0,
      heightUnit:
          HeightUnit.values[(json['heightUnit'] as num?)?.toInt() ?? 0],
      heightFeet: (json['heightFeet'] as num?)?.toInt() ?? 4,
      heightInches: (json['heightInches'] as num?)?.toInt() ?? 6,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      weightUnit:
          WeightUnit.values[(json['weightUnit'] as num?)?.toInt() ?? 0],
      fitnessLevel: json['fitnessLevel'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      sittingHours: (json['sittingHours'] as num?)?.toDouble() ?? -1,
      activityLevel: json['activityLevel'] as String? ?? '',
      painAreas:
          (json['painAreas'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
      flexibilityLevel: json['flexibilityLevel'] as String? ?? '',
      goals:
          (json['goals'] as List<dynamic>?)?.cast<String>() ?? const <String>[],
    );
  }
}
