import 'dart:io';

import 'package:fitness_app/data/seed/seed_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contains sixteen categories with three exercises each', () {
    expect(SeedData.categoryNames.length, 16);
    expect(SeedData.exercises.length, 48);

    for (final category in SeedData.categoryNames) {
      final exercises = SeedData.exercisesForCategory(category);
      expect(
        exercises.length,
        3,
        reason: '$category should have three exercises',
      );
    }
  });

  test('exercise ids are unique and resolve to an exercise', () {
    final ids = SeedData.exercises.map((exercise) => exercise.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final id in ids) {
      expect(SeedData.byId(id)?.id, id);
    }
  });

  test('today flow references valid split training exercises', () {
    expect(SeedData.todayFlowIds.length, 3);
    for (final id in SeedData.todayFlowIds) {
      final exercise = SeedData.byId(id);
      expect(exercise, isNotNull);
      expect(exercise!.category, 'Split Training');
    }
  });

  test('program ids and local image assets exist', () {
    for (final id in SeedData.programIds) {
      expect(SeedData.byId(id), isNotNull);
    }
    for (final exercise in SeedData.exercises) {
      expect(exercise.steps, isNotEmpty);
      expect(exercise.durationSec, inInclusiveRange(30, 120));
      expect(File(exercise.imageAsset).existsSync(), isTrue);
    }
    expect(File(SeedData.todayFlowImage).existsSync(), isTrue);
  });

  test('body part filtering finds relevant categories', () {
    final categories = SeedData.categoriesForBodyPart('Shoulders');
    expect(categories, isNotEmpty);
    final exercises = SeedData.exercisesForBodyPart('shoulders');
    expect(exercises, isNotEmpty);
    for (final exercise in exercises) {
      expect(
        exercise.bodyParts.join(' ').toLowerCase(),
        contains('shoulder'),
      );
    }
  });
}
