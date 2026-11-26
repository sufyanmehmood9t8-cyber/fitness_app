import 'dart:async';

import 'package:flutter/foundation.dart';

/// A small, testable countdown timer used by the workout player.
class WorkoutTimer extends ChangeNotifier {
  WorkoutTimer({
    required Duration duration,
    this.onComplete,
  })  : _total = duration,
        _remaining = duration;

  final Duration _total;
  Duration _remaining;
  Timer? _ticker;
  bool _running = false;

  VoidCallback? onComplete;

  Duration get total => _total;
  Duration get remaining => _remaining;
  bool get isRunning => _running;
  bool get isFinished => _remaining <= Duration.zero;
  double get progress {
    if (_total.inMilliseconds <= 0) return 1;
    final elapsed = _total.inMilliseconds - _remaining.inMilliseconds;
    return (elapsed / _total.inMilliseconds).clamp(0.0, 1.0);
  }

  void start() {
    if (_running || isFinished) return;
    _running = true;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  void pause() {
    if (!_running) return;
    _running = false;
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
  }

  void toggle() {
    if (_running) {
      pause();
    } else {
      start();
    }
  }

  void reset({Duration? duration}) {
    _ticker?.cancel();
    _ticker = null;
    _running = false;
    _remaining = duration ?? _total;
    notifyListeners();
  }

  void _tick(Timer timer) {
    if (!_running) return;
    final next = _remaining - const Duration(seconds: 1);
    if (next <= Duration.zero) {
      _remaining = Duration.zero;
      _running = false;
      timer.cancel();
      _ticker = null;
      notifyListeners();
      onComplete?.call();
      return;
    }
    _remaining = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }
}
