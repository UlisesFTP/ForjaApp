/// A stopwatch built on timestamps instead of ticks, so the time shown is
/// right after the app was in the background or the screen was off: it is
/// recomputed from [clock], never accumulated. Cardio (F10) reuses it.
class ElapsedTimer {
  ElapsedTimer({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;
  final DateTime Function() _clock;
  // Time banked before the current run (while paused).
  Duration _banked = Duration.zero;
  DateTime? _runningSince;
  // Started and not reset: a pause right after the start has banked no time
  // yet and is still a pause, not a timer that never began.
  bool _started = false;

  bool get isRunning => _runningSince != null;
  bool get isStarted => _started;
  bool get isPaused => _started && !isRunning;

  Duration get elapsed {
    final since = _runningSince;
    if (since == null) return _banked;
    final run = _clock().difference(since);
    // A clock moved backwards must not produce negative time.
    return _banked + (run.isNegative ? Duration.zero : run);
  }

  void start() {
    _runningSince ??= _clock();
    _started = true;
  }

  void pause() {
    if (!isRunning) return;
    _banked = elapsed;
    _runningSince = null;
  }

  void reset() {
    _banked = Duration.zero;
    _runningSince = null;
    _started = false;
  }

  /// Rebuilds a timer from stored timestamps: [banked] is the time already
  /// accumulated and [runningSince] when the current run began (null if it
  /// was paused).
  ElapsedTimer.restore({
    required Duration banked,
    DateTime? runningSince,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _banked = banked;
    _runningSince = runningSince;
    _started = banked > Duration.zero || runningSince != null;
  }

  Duration get banked => _banked;
  DateTime? get runningSince => _runningSince;
}

/// A countdown over an [ElapsedTimer], for rest between sets.
class RestTimer {
  RestTimer({DateTime Function()? clock}) : _timer = ElapsedTimer(clock: clock);
  final ElapsedTimer _timer;
  Duration _target = Duration.zero;

  Duration get target => _target;
  bool get isRunning => _timer.isRunning;
  bool get isPaused => _timer.isPaused;
  bool get isActive => _timer.isStarted;

  Duration get remaining {
    final left = _target - _timer.elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  bool get isDone => isActive && remaining == Duration.zero;

  /// Starts a fresh countdown of [seconds].
  void start(int seconds) {
    if (seconds <= 0) throw ArgumentError('El descanso debe ser positivo.');
    _target = Duration(seconds: seconds);
    _timer
      ..reset()
      ..start();
  }

  void pause() => _timer.pause();
  void resume() {
    if (!isDone) _timer.start();
  }

  void cancel() {
    _timer.reset();
    _target = Duration.zero;
  }
}

String clockText(Duration d) {
  final minutes = d.inMinutes, seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
