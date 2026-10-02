import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/date_utils.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/services/notification_service.dart';
import '../../domain/services/reminder_planner.dart';

/// What the screen shows about reminders: the wish (saved setting) and the
/// reality (system permission, how many are scheduled) kept apart.
class ReminderStatus {
  const ReminderStatus({
    this.permission = NotificationPermission.unknown,
    this.scheduled = 0,
    this.next,
    this.error,
  });
  final NotificationPermission permission;
  final int scheduled;
  final DateTime? next;
  // Why the last reconciliation failed, if it did.
  final String? error;
}

/// Keeps the OS's scheduled notifications equal to what the plan says: it
/// recomputes the 28-day window and applies only the difference. Runs when
/// the app opens or resumes and whenever the plan, the sessions or the
/// reminder setting change. Runs never overlap, so nothing is duplicated.
class ReminderCoordinator extends ChangeNotifier {
  ReminderCoordinator(
    this._service,
    this._workouts,
    this._settings, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;
  final NotificationService _service;
  final WorkoutRepository _workouts;
  final SettingsRepository _settings;
  final DateTime Function() _clock;

  ReminderStatus status = const ReminderStatus();
  bool _started = false, _disposed = false, _running = false, _dirty = false;
  Completer<void>? _done;

  /// Tapped reminders (running app) and the cold-start one, as the day to
  /// open. The shell listens and shows that day.
  final taps = ValueNotifier<DateTime?>(null);
  int tapCount = 0;

  /// Prepares the service, hears taps, handles a cold-start tap and does the
  /// first reconciliation. Safe to call once.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      await _service.initialize(onTap: _onTap);
      final launch = await _service.launchPayload();
      if (launch != null) _onTap(launch);
    } catch (e) {
      status = ReminderStatus(error: 'Notificaciones no disponibles: $e');
      _notify();
      return;
    }
    _workouts.addListener(_changed);
    _settings.addListener(_changed);
    await reconcile();
  }

  void _onTap(String payload) {
    final date = ReminderPlanner.dateFromPayload(payload);
    if (date == null) return;
    tapCount++;
    taps.value = date;
  }

  void _changed() {
    if (_disposed || !_started) return;
    unawaited(reconcile());
  }

  /// Brings the OS in line with the plan. Calls made while one is running
  /// are merged into one more pass afterwards.
  Future<void> reconcile() {
    if (_disposed) return Future.value();
    if (_running) {
      _dirty = true;
      return (_done ??= Completer<void>()).future;
    }
    _running = true;
    _done = Completer<void>();
    final done = _done!;
    unawaited(() async {
      try {
        do {
          _dirty = false;
          await _reconcileOnce();
        } while (_dirty && !_disposed);
      } finally {
        _running = false;
        _done = null;
        done.complete();
      }
    }());
    return done.future;
  }

  Future<void> _reconcileOnce() async {
    try {
      var permission = await _service.permission();
      final settings = _settings.reminder;
      final now = _clock();
      final desired = ReminderPlanner.plan(
        settings: settings,
        now: now,
        routineOn: _workouts.routineOn,
        statusOn: (d) => _workouts.sessionOn(d)?.status,
        zone: _service.zoneName,
      );
      final pending = await _service.pending();
      // Without permission nothing can be shown: keep nothing queued.
      final wanted = permission == NotificationPermission.denied
          ? const <ScheduledNotification>[]
          : desired;
      final diff = ReminderPlanner.reconcile(desired: wanted, pending: pending);
      for (final id in diff.cancel) {
        await _service.cancel(id);
      }
      for (final n in diff.schedule) {
        await _service.schedule(n);
      }
      permission = await _service.permission();
      status = ReminderStatus(
        permission: permission,
        scheduled: wanted.length,
        next: wanted.isEmpty ? null : wanted.first.at,
      );
    } catch (e) {
      status = ReminderStatus(
        permission: status.permission,
        error: 'No se pudieron programar los recordatorios: $e',
      );
    }
    _notify();
  }

  /// Asks the system for permission (it may show its dialog), then
  /// reconciles with the answer.
  Future<NotificationPermission> requestPermission() async {
    final result = await _service.requestPermission();
    await reconcile();
    return result;
  }

  Future<NotificationPermission> refreshPermission() async {
    await reconcile();
    return status.permission;
  }

  Future<void> openSystemSettings() => _service.openSystemSettings();

  /// A notification right now, to see that they arrive. It opens today.
  Future<void> sendTest() => _service.showNow(
    id: ReminderPlanner.testId,
    title: 'Prueba de FORJA',
    body: 'Si ves esto, los avisos funcionan en este teléfono.',
    payload: ReminderPlanner.payloadFor(
      dateOnly(_clock()),
      _settings.reminder,
      _service.zoneName,
    ),
  );

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_started) {
      _workouts.removeListener(_changed);
      _settings.removeListener(_changed);
    }
    taps.dispose();
    super.dispose();
  }
}
