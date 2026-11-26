/// All strings, option lists, image paths, and validation bounds
/// for the Personal Assessment flow and Goal Selection.
///
/// Nothing should be hard-coded in widget files; update this file
/// to add / edit / reorder steps or options.
library;

// ──────────────────────────────────────────────────────────────
//  Section headers
// ──────────────────────────────────────────────────────────────

const String kAssessmentSectionTitle = '1. Personal Assessment';
const String kGoalSectionTitle = '2. Goal Selection';

// ──────────────────────────────────────────────────────────────
//  Step questions
// ──────────────────────────────────────────────────────────────

const String kNameQuestion = 'what should we call you ?';
const String kGenderQuestion = "What's your gender ?";
const String kHeightQuestion = "What's your height ?";
const String kWeightQuestion = "What's your weight ?";
const String kFitnessLevelQuestion =
    'How would you describe your fitness level ?';
const String kOccupationQuestion = 'What is your occupation ?';
const String kSittingHoursQuestion = 'Your sitting hours ?';
const String kActivityLevelQuestion = 'Activity level ?';
const String kPainAreasQuestion = 'Pain areas ?';
const String kFlexibilityQuestion =
    'How would you describe your flexibility level ?';

// ──────────────────────────────────────────────────────────────
//  Field placeholders / labels
// ──────────────────────────────────────────────────────────────

const String kNamePlaceholder = 'Enter Name';
const String kHeightPlaceholder = 'Enter height';
const String kWeightPlaceholder = 'Enter Weight';
const String kSittingHoursPlaceholder = 'hours';

// ──────────────────────────────────────────────────────────────
//  Gender images
// ──────────────────────────────────────────────────────────────

const String kFemaleImage = 'assets/images/gender_female.webp';
const String kMaleImage = 'assets/images/gender_male.webp';

// ──────────────────────────────────────────────────────────────
//  Option lists (order matters for rendering)
// ──────────────────────────────────────────────────────────────

const List<String> kFitnessLevels = <String>[
  'Beginner',
  'Intermediate',
  'Advanced',
];

const List<String> kOccupations = <String>[
  'Driver',
  'Student',
  'Office worker',
  'Sports men',
];

const List<String> kActivityLevels = <String>[
  'Beginner',
  'Intermediate',
  'Advanced',
  'None',
];

const List<String> kPainAreas = <String>[
  'Neck',
  'Shoulder',
  'Knee',
  'Joint',
  'Elbow',
  'Knee joint',
  'Pelvic',
];

const List<String> kFlexibilityLevels = <String>[
  '0%',
  '10 - 30%',
  '30 - 60%',
  '60 - 90%',
  '100%',
];

const List<String> kGoalOptions = <String>[
  'Improve Flexibility',
  'Reduce Back Pain',
  'Better Posture',
  'Morning Stretch',
  'Sleep Better',
  'Sports Recovery',
  'Office Worker',
  'Full Body Mobility',
];

// ──────────────────────────────────────────────────────────────
//  Validation bounds
// ──────────────────────────────────────────────────────────────

const int kMinNameLength = 2;

const double kMinHeightCm = 50;
const double kMaxHeightCm = 250;
const double kMinHeightM = 0.5;
const double kMaxHeightM = 2.5;
const int kMinFeet = 3;
const int kMaxFeet = 8;
const int kMinInches = 0;
const int kMaxInches = 11;
const double kDefaultFeet = 4;
const double kDefaultInches = 6;

const double kMinWeightKg = 30;
const double kMaxWeightKg = 300;

const double kMinSittingHours = 0;
const double kMaxSittingHours = 24;

// ──────────────────────────────────────────────────────────────
//  Height / weight unit labels
// ──────────────────────────────────────────────────────────────

enum HeightUnit { feet, cm, m }

enum WeightUnit { lb, kg }

// ──────────────────────────────────────────────────────────────
//  Conversion helpers
// ──────────────────────────────────────────────────────────────

double feetInchesToCm(int feet, int inches) =>
    (feet * 30.48) + (inches * 2.54);

(int feet, int inches) cmToFeetInches(double cm) {
  final totalInches = cm / 2.54;
  final feet = totalInches ~/ 12;
  final inches = (totalInches % 12).round();
  return (feet, inches);
}

double lbToKg(double lb) => lb * 0.453592;
double kgToLb(double kg) => kg / 0.453592;

// ──────────────────────────────────────────────────────────────
//  Step count
// ──────────────────────────────────────────────────────────────

const int kTotalAssessmentSteps = 10;

// ──────────────────────────────────────────────────────────────
//  Button labels
// ──────────────────────────────────────────────────────────────

const String kNextLabel = 'Next';
const String kFinishLabel = 'Finish';
const String kSkipLabel = 'Skip';
