/// Defines each step in the assessment flow as data.
///
/// One reusable screen reads these definitions so adding / editing
/// steps requires zero widget changes and the progress bar adjusts
/// automatically.
library;

import '../constants/assessment_constants.dart';

// ──────────────────────────────────────────────────────────────
//  Step type enum
// ──────────────────────────────────────────────────────────────

enum AssessmentStepType {
  text,
  gender,
  height,
  weight,
  singleSelect,
  multiSelect,
  number,
}

// ──────────────────────────────────────────────────────────────
//  Step definition
// ──────────────────────────────────────────────────────────────

class AssessmentStepDef {
  const AssessmentStepDef({
    required this.title,
    required this.type,
    this.options = const <String>[],
    this.placeholder = '',
    this.stateKey = '',
  });

  /// The question text displayed below the progress bar.
  final String title;

  /// Drives which widget is rendered for this step.
  final AssessmentStepType type;

  /// For singleSelect / multiSelect steps.
  final List<String> options;

  /// Hint text for text / number fields.
  final String placeholder;

  /// Key name in the controller state map (for saving).
  final String stateKey;
}

// ──────────────────────────────────────────────────────────────
//  Step list
// ──────────────────────────────────────────────────────────────

const List<AssessmentStepDef> kAssessmentSteps = <AssessmentStepDef>[
  // 1 – Name
  AssessmentStepDef(
    title: kNameQuestion,
    type: AssessmentStepType.text,
    placeholder: kNamePlaceholder,
    stateKey: 'name',
  ),
  // 2 – Gender
  AssessmentStepDef(
    title: kGenderQuestion,
    type: AssessmentStepType.gender,
    stateKey: 'gender',
  ),
  // 3 – Height
  AssessmentStepDef(
    title: kHeightQuestion,
    type: AssessmentStepType.height,
    stateKey: 'heightCm',
  ),
  // 4 – Weight
  AssessmentStepDef(
    title: kWeightQuestion,
    type: AssessmentStepType.weight,
    stateKey: 'weightKg',
  ),
  // 5 – Fitness level
  AssessmentStepDef(
    title: kFitnessLevelQuestion,
    type: AssessmentStepType.singleSelect,
    options: kFitnessLevels,
    stateKey: 'fitnessLevel',
  ),
  // 6 – Occupation
  AssessmentStepDef(
    title: kOccupationQuestion,
    type: AssessmentStepType.singleSelect,
    options: kOccupations,
    stateKey: 'occupation',
  ),
  // 7 – Sitting hours
  AssessmentStepDef(
    title: kSittingHoursQuestion,
    type: AssessmentStepType.number,
    placeholder: kSittingHoursPlaceholder,
    stateKey: 'sittingHours',
  ),
  // 8 – Activity level
  AssessmentStepDef(
    title: kActivityLevelQuestion,
    type: AssessmentStepType.singleSelect,
    options: kActivityLevels,
    stateKey: 'activityLevel',
  ),
  // 9 – Pain areas
  AssessmentStepDef(
    title: kPainAreasQuestion,
    type: AssessmentStepType.multiSelect,
    options: kPainAreas,
    stateKey: 'painAreas',
  ),
  // 10 – Flexibility
  AssessmentStepDef(
    title: kFlexibilityQuestion,
    type: AssessmentStepType.singleSelect,
    options: kFlexibilityLevels,
    stateKey: 'flexibilityLevel',
  ),
];
