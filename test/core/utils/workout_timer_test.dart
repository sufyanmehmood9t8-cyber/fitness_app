import 'package:fake_async/fake_async.dart';
import 'package:fitness_app/core/utils/workout_timer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('counts down, pauses, resumes and completes once', () {
    fakeAsync((async) {
      var completed = 0;
      final timer = WorkoutTimer(
        duration: const Duration(seconds: 2),
        onComplete: () => completed++,
      );

      timer.start();
      async.elapse(const Duration(seconds: 1));
      expect(timer.remaining, const Duration(seconds: 1));
      expect(timer.isRunning, isTrue);
      expect(timer.progress, closeTo(0.5, 0.001));

      timer.pause();
      async.elapse(const Duration(seconds: 3));
      expect(timer.remaining, const Duration(seconds: 1));
      expect(timer.isRunning, isFalse);
      expect(completed, 0);

      timer.start();
      async.elapse(const Duration(seconds: 1));
      expect(timer.remaining, Duration.zero);
      expect(timer.isFinished, isTrue);
      expect(timer.isRunning, isFalse);
      expect(completed, 1);

      async.elapse(const Duration(seconds: 3));
      expect(completed, 1);

      timer.dispose();
    });
  });

  test('toggle and reset control playback', () {
    fakeAsync((async) {
      final timer = WorkoutTimer(
        duration: const Duration(seconds: 10),
      );
      timer.toggle();
      async.elapse(const Duration(seconds: 2));
      expect(timer.remaining, const Duration(seconds: 8));

      timer.toggle();
      expect(timer.isRunning, isFalse);

      timer.reset();
      expect(timer.remaining, const Duration(seconds: 10));
      expect(timer.isRunning, isFalse);
      timer.dispose();
    });
  });
}
