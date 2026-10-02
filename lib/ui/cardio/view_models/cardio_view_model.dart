import 'dart:async';

import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/cardio_math.dart';
import '../../core/view_model.dart';

/// Time that only moves forward while the app runs (a [Stopwatch]).
typedef Monotonic = Duration Function();

/// Cardio with persistent sessions. The time shown is rebuilt from stored
/// timestamps; the periodic timer only refreshes the screen. While the
/// process lives, a monotonic clock measures the running segment, so a change
/// of the phone's clock cannot alter it; after a restart only the wall clock
/// is left, and an incoherent result asks the person to correct the duration.
class CardioViewModel extends ViewModel {
  CardioViewModel(
    this._cardio,
    this._profile, {
    DateTime Function()? clock,
    Monotonic? monotonic,
    this.tick = const Duration(seconds: 1),
  }) : _clock = clock ?? DateTime.now {
    final sw = Stopwatch()..start();
    _mono = monotonic ?? (() => sw.elapsed);
    watch(_cardio);
    watch(_profile);
    final seg = session?.current;
    if (seg != null) _runningElapsed(seg);
    _syncTicker();
  }
  final CardioRepository _cardio;
  final ProfileRepository _profile;
  final DateTime Function() _clock;
  // How often the screen refreshes; it never counts time.
  final Duration tick;
  late final Monotonic _mono;
  Timer? _ticker;

  // The running segment being measured: which one, and how much of it had
  // already elapsed (by the wall clock) when this process first saw it.
  String? _anchorId;
  Duration _anchorElapsed = Duration.zero;
  Duration _anchorMono = Duration.zero;
  // Whether the wall clock looked coherent when the segment was first seen.
  CardioCoherence _anchorCoherence = CardioCoherence.ok;

  CardioActivity activity = CardioActivity.walk;
  CardioIntensity intensity = CardioIntensity.moderate;
  int? targetMinutes;

  CardioSession? get session => _cardio.activeCardio;
  List<CardioSession> get history => _cardio.cardioHistory;
  bool get active => session != null;
  bool get running => session?.running ?? false;
  bool get paused => session?.paused ?? false;
  double? get weightKg => _profile.profile.weightKg;
  DateTime get _now => _clock().toUtc();

  Duration _runningElapsed(CardioSegment seg) {
    if (_anchorId != seg.id) {
      // First time this process sees the segment (just started, or the app
      // was restarted): trust the wall clock once, then the monotonic one.
      _anchorId = seg.id;
      final wall = _now.difference(seg.startedAt);
      _anchorCoherence = wall < -CardioMath.skew
          ? CardioCoherence.clockBehind
          : wall > CardioMath.implausibleAfter
          ? CardioCoherence.implausible
          : CardioCoherence.ok;
      _anchorElapsed = wall.isNegative ? Duration.zero : wall;
      _anchorMono = _mono();
    }
    return _anchorElapsed + (_mono() - _anchorMono);
  }

  /// Where the running segment would end if it closed now.
  DateTime get closeAt {
    final seg = session?.current;
    return seg == null ? _now : seg.startedAt.add(_runningElapsed(seg));
  }

  /// The active session with its running segment closed at [closeAt].
  CardioSession? get _measured {
    final s = session;
    if (s == null) return null;
    final seg = s.current;
    if (seg == null) return s;
    return s.copyWith(
      segments: [
        for (final x in s.segments)
          if (x.id == seg.id) x.closedAt(closeAt) else x,
      ],
    );
  }

  Duration get elapsed => _measured?.duration(_now) ?? Duration.zero;
  String get display => CardioMath.clock(elapsed);

  /// kcal so far; null when a body weight is missing.
  double? get calories {
    final s = _measured;
    return s == null ? null : CardioMath.kcal(s, _now);
  }

  /// Time left to the optional target, never negative.
  Duration? get remaining {
    final target = session?.targetMinutes;
    if (target == null) return null;
    final left = Duration(minutes: target) - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  /// A clock that went backwards, or a session far too long to be real.
  /// While the process lives the monotonic measure is trusted, so a clock
  /// change then is not a problem; what is judged is the stored data (closed
  /// segments) and how the wall clock looked when the running segment was
  /// first seen, which is all that survives a restart.
  CardioCoherence get coherence {
    final measured = _measured;
    if (measured == null) return CardioCoherence.ok;
    final stored = CardioMath.coherence(measured, _now);
    if (stored != CardioCoherence.ok) return stored;
    if (session?.running ?? false) {
      if (_anchorCoherence != CardioCoherence.ok) return _anchorCoherence;
      if (elapsed > CardioMath.implausibleAfter) {
        return CardioCoherence.implausible;
      }
    }
    return CardioCoherence.ok;
  }

  void select(CardioActivity value) {
    if (active) return;
    activity = value;
    notifyListeners();
  }

  void setTarget(int? minutes) {
    targetMinutes = minutes;
    notifyListeners();
  }

  void _syncTicker() {
    if (running && _ticker == null) {
      _ticker = Timer.periodic(tick, (_) => notifyListeners());
    } else if (!running) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  void notifyListeners() {
    // Anchor the monotonic measure the moment the segment is first seen, not
    // when the screen happens to read it.
    final seg = session?.current;
    if (seg != null) _runningElapsed(seg);
    _syncTicker();
    super.notifyListeners();
  }

  Future<bool> start() => run(
    () => _cardio.startCardio(
      activity: activity,
      intensity: intensity,
      at: _now,
      targetMinutes: targetMinutes,
    ),
  );

  Future<bool> pause() => run(() => _cardio.pauseCardio(closeAt));
  Future<bool> resume() => run(() => _cardio.resumeCardio(_now));

  /// Changes the intensity from now on. While paused it applies when the
  /// session continues.
  Future<bool> setIntensity(CardioIntensity value) {
    intensity = value;
    if (!running) {
      notifyListeners();
      return Future.value(true);
    }
    return run(() => _cardio.changeCardioIntensity(closeAt, value));
  }

  Future<bool> finish({
    Duration? correctedDuration,
    Feeling? feedback,
    String note = '',
  }) {
    final s = session;
    if (s == null) return Future.value(false);
    if (correctedDuration == null && coherence != CardioCoherence.ok) {
      error = 'El reloj del teléfono no es coherente con la sesión. Indica la duración real.';
      announce(error!);
      return Future.value(false);
    }
    return run(() async {
      await _cardio.finishCardio(
        s.id,
        closeAt,
        correctedDuration: correctedDuration,
        feedback: feedback,
        note: note,
      );
      announce('Sesión de cardio guardada');
    });
  }

  Future<bool> discard() {
    final s = session;
    if (s == null) return Future.value(false);
    return run(() => _cardio.discardCardio(s.id), success: 'Sesión descartada');
  }

  /// kcal of a stored session, null if it lacks a weight.
  double? caloriesOf(CardioSession s) => CardioMath.kcal(s, _now);

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }
}
