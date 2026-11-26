/// Riverpod controller for the Personal Assessment + Goal Selection flow.
///
/// Persists to Hive after every mutation so progress survives app closure.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/services/storage_service.dart';
import '../constants/assessment_constants.dart';
import '../models/assessment_state.dart';

// ──────────────────────────────────────────────────────────────
//  Provider
// ──────────────────────────────────────────────────────────────

final assessmentProvider =
    NotifierProvider<AssessmentController, AssessmentState>(
  AssessmentController.new,
);

// ──────────────────────────────────────────────────────────────
//  Controller
// ──────────────────────────────────────────────────────────────

class AssessmentController extends Notifier<AssessmentState> {
  @override
  AssessmentState build() {
    // Load persisted state.
    final raw = StorageService.instance.assessmentData;
    if (raw.isNotEmpty) {
      return AssessmentState.fromJson(raw);
    }
    // Fresh start: default height in feet mode.
    final defaultCm = feetInchesToCm(4, 6);
    return AssessmentState(heightCm: defaultCm);
  }

  // ── Navigation ────────────────────────────────────────────

  void goToStep(int step) {
    _update(state.copyWith(currentStep: step));
  }

  void nextStep() {
    if (state.currentStep < kTotalAssessmentSteps - 1) {
      _update(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void prevStep() {
    if (state.currentStep > 0) {
      _update(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  // ── Field setters ─────────────────────────────────────────

  void setName(String name) {
    _update(state.copyWith(name: name));
  }

  void setGender(String gender) {
    _update(state.copyWith(gender: gender));
  }

  void setHeightCm(double cm) {
    final (f, i) = cmToFeetInches(cm);
    _update(state.copyWith(heightCm: cm, heightFeet: f, heightInches: i));
  }

  void setHeightFeetInches(int feet, int inches) {
    final cm = feetInchesToCm(feet, inches);
    _update(state.copyWith(heightCm: cm, heightFeet: feet, heightInches: inches));
  }

  void setHeightUnit(HeightUnit unit) {
    _update(state.copyWith(heightUnit: unit));
  }

  void setWeightKg(double kg) {
    _update(state.copyWith(weightKg: kg));
  }

  void setWeightUnit(WeightUnit unit) {
    _update(state.copyWith(weightUnit: unit));
  }

  void setFitnessLevel(String level) {
    _update(state.copyWith(fitnessLevel: level));
  }

  void setOccupation(String occupation) {
    _update(state.copyWith(occupation: occupation));
  }

  void setSittingHours(double hours) {
    _update(state.copyWith(sittingHours: hours));
  }

  void setActivityLevel(String level) {
    _update(state.copyWith(activityLevel: level));
  }

  void setPainAreas(List<String> areas) {
    _update(state.copyWith(painAreas: areas));
  }

  void togglePainArea(String area) {
    final current = List<String>.from(state.painAreas);
    if (current.contains(area)) {
      current.remove(area);
    } else {
      current.add(area);
    }
    _update(state.copyWith(painAreas: current));
  }

  void setFlexibilityLevel(String level) {
    _update(state.copyWith(flexibilityLevel: level));
  }

  void setGoals(List<String> goals) {
    _update(state.copyWith(goals: goals));
  }

  void toggleGoal(String goal) {
    final current = List<String>.from(state.goals);
    if (current.contains(goal)) {
      current.remove(goal);
    } else {
      current.add(goal);
    }
    _update(state.copyWith(goals: current));
  }

  // ── Finish / skip helpers ─────────────────────────────────

  Future<void> finishAssessment() async {
    final storage = StorageService.instance;
    await storage.saveAssessmentData(state.toJson());
    if (state.name.trim().isNotEmpty) {
      await storage.setUserName(state.name.trim());
    }
    await storage.setAssessmentDone(true);
  }

  Future<void> skipAssessment() async {
    final storage = StorageService.instance;
    // Save whatever we have so far.
    await storage.saveAssessmentData(state.toJson());
    if (state.name.trim().isNotEmpty) {
      await storage.setUserName(state.name.trim());
    }
    await storage.setAssessmentSkipped(true);
  }

  Future<void> finishGoals() async {
    final storage = StorageService.instance;
    await storage.saveAssessmentData(state.toJson());
    await storage.setGoalsDone(true);
  }

  Future<void> skipGoals() async {
    final storage = StorageService.instance;
    await storage.saveAssessmentData(state.toJson());
    await storage.setGoalsSkipped(true);
  }

  // ── Validation helpers ────────────────────────────────────

  /// Whether the current step is valid (Next button enabled).
  bool isCurrentStepValid() => isStepValid(state.currentStep);

  bool isStepValid(int step) {
    switch (step) {
      case 0:
        return state.name.trim().length >= kMinNameLength;
      case 1:
        return state.gender.isNotEmpty;
      case 2:
        return state.heightCm >= kMinHeightCm && state.heightCm <= kMaxHeightCm;
      case 3:
        return state.weightKg >= kMinWeightKg && state.weightKg <= kMaxWeightKg;
      case 4:
        return state.fitnessLevel.isNotEmpty;
      case 5:
        return state.occupation.isNotEmpty;
      case 6:
        return state.sittingHours >= kMinSittingHours &&
            state.sittingHours <= kMaxSittingHours;
      case 7:
        return state.activityLevel.isNotEmpty;
      case 8:
        return state.painAreas.isNotEmpty;
      case 9:
        return state.flexibilityLevel.isNotEmpty;
      default:
        return false;
    }
  }

  // ── Private ───────────────────────────────────────────────

  void _update(AssessmentState next) {
    state = next;
    // Fire-and-forget save.
    StorageService.instance.saveAssessmentData(next.toJson());
  }
}
