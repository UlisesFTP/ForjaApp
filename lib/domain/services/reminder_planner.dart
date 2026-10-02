import '../../core/date_utils.dart';
import '../models/models.dart';
import 'notification_service.dart';

/// Decides which notifications should exist: pure, so it can be tested with
/// any date, hour and zone. Scheduling them is the coordinator's job.
class ReminderPlanner {
  /// Days ahead that are scheduled. The OS keeps a limited number of pending
  /// notifications (iOS: 64), and nothing refills them while the app is
  /// closed, so the window is moved forward every time the app opens.
  static const horizonDays = 28;

  /// The id of the reminder for a date. Derived from the date itself, so it is
  /// stable between runs and cannot collide: 2026-10-01 → 20261001.
  static int idFor(DateTime date) =>
      date.year * 10000 + date.month * 100 + date.day;

  /// Ids of reminders are dates; this one is kept for the "test" notification
  /// and is far from any date.
  static const testId = 1;

  /// Everything the notification needs to open the right day and to tell
  /// whether it is still the one that should exist: the date, the hour and
  /// the time zone it was scheduled for.
  static String payloadFor(DateTime date, ReminderSettings s, String zone) =>
      'session:${dateKey(date)}@${s.hour.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')}@$zone';

  /// The day a payload points at, or null if it is not a session payload.
  static DateTime? dateFromPayload(String payload) {
    final parts = payload.split('@');
    if (parts.isEmpty || !parts.first.startsWith('session:')) return null;
    final value = parts.first.substring('session:'.length);
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return null;
    final date = DateTime.tryParse(value);
    // DateTime.parse accepts 2026-02-31 as March; the round trip rejects it.
    if (date == null || dateKey(date) != value) return null;
    return date;
  }

  /// Reminders from today through [horizonDays] days: one per planned
  /// workout that is still to do and whose hour has not passed. Nothing when
  /// reminders are off, on rest days, or once the day's session is finished.
  static List<ScheduledNotification> plan({
    required ReminderSettings settings,
    required DateTime now,
    required Routine? Function(DateTime) routineOn,
    required SessionStatus? Function(DateTime) statusOn,
    required String zone,
  }) {
    if (!settings.enabled) return const [];
    final today = dateOnly(now);
    final result = <ScheduledNotification>[];
    for (var i = 0; i < horizonDays; i++) {
      final date = nextDay(today, i);
      final routine = routineOn(date);
      if (routine == null) continue;
      final status = statusOn(date);
      if (status == SessionStatus.completed ||
          status == SessionStatus.partial ||
          status == SessionStatus.missed) {
        continue;
      }
      final at = DateTime(
        date.year,
        date.month,
        date.day,
        settings.hour,
        settings.minute,
      );
      if (!at.isAfter(now)) continue;
      result.add(
        ScheduledNotification(
          id: idFor(date),
          at: at,
          title: i == 0 ? 'Hoy toca: ${routine.name}' : routine.name,
          body: i == 0
              ? 'Tu sesión de FORJA te espera.'
              : 'Entrenamiento programado para ${friendlyDate(date)}.',
          payload: payloadFor(date, settings, zone),
        ),
      );
    }
    return result;
  }

  /// What to cancel and what to schedule so the OS matches [desired]. A
  /// pending reminder is kept only if its id and payload (day, hour, zone)
  /// are exactly the wanted ones: this makes the work idempotent, so running
  /// it twice never duplicates anything.
  static ({List<int> cancel, List<ScheduledNotification> schedule}) reconcile({
    required List<ScheduledNotification> desired,
    required List<PendingNotification> pending,
  }) {
    final wanted = {for (final n in desired) n.id: n};
    final cancel = <int>{};
    final seen = <int>{};
    for (final p in pending) {
      final w = wanted[p.id];
      // A duplicate id, a notification nobody wants, or one that changed.
      if (w == null || w.payload != p.payload || !seen.add(p.id)) {
        if (p.id != testId) cancel.add(p.id);
      }
    }
    return (
      cancel: cancel.toList()..sort(),
      schedule: [
        for (final n in desired)
          if (!pending.any((p) => p.id == n.id && p.payload == n.payload) ||
              cancel.contains(n.id))
            n,
      ],
    );
  }
}
