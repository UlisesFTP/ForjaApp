/// What the operating system says about showing notifications. It is separate
/// from the person's wish (the saved reminder setting): the wish can be "on"
/// while the system says "denied".
enum NotificationPermission {
  granted,
  denied,

  /// Not asked yet, or the platform cannot tell.
  unknown,
}

/// One notification the OS keeps for us. [payload] carries everything needed
/// to compare it with what should be scheduled and to open the right day.
class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.payload,
  });
  final int id;
  // Local wall-clock time (a day and an hour on the person's calendar).
  final DateTime at;
  final String title, body, payload;
}

/// A notification already scheduled, as the OS reports it (the platform does
/// not tell when it fires; the payload does).
class PendingNotification {
  const PendingNotification({
    required this.id,
    required this.payload,
    this.title,
    this.body,
  });
  final int id;
  final String payload;
  final String? title, body;
}

/// The only door to the platform's local notifications. The plugin lives
/// behind it; ViewModels and the scheduling logic never import it.
abstract class NotificationService {
  /// Prepares the channel and the time zone. [onTap] receives the payload of
  /// a notification the person tapped while the app was running.
  Future<void> initialize({required void Function(String payload) onTap});

  Future<NotificationPermission> permission();

  /// Asks the system (it may show its dialog). Returns the resulting state.
  Future<NotificationPermission> requestPermission();

  Future<List<PendingNotification>> pending();
  Future<void> schedule(ScheduledNotification notification);
  Future<void> cancel(int id);
  Future<void> cancelAll();

  /// The payload of the notification that started the app from closed, once.
  Future<String?> launchPayload();

  /// Shows a notification right away (to check that they arrive).
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required String payload,
  });

  /// Opens the system page where the permission can be changed.
  Future<void> openSystemSettings();

  /// The IANA name of the zone used to schedule, e.g. "America/Mexico_City".
  String get zoneName;
}

/// Does nothing. Used where there are no native notifications (tests, or a
/// platform without them): permission is unknown and nothing is scheduled.
class NoopNotificationService implements NotificationService {
  @override
  Future<void> initialize({
    required void Function(String payload) onTap,
  }) async {}
  @override
  Future<NotificationPermission> permission() async =>
      NotificationPermission.unknown;
  @override
  Future<NotificationPermission> requestPermission() async =>
      NotificationPermission.unknown;
  @override
  Future<List<PendingNotification>> pending() async => const [];
  @override
  Future<void> schedule(ScheduledNotification notification) async {}
  @override
  Future<void> cancel(int id) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<String?> launchPayload() async => null;
  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {}
  @override
  Future<void> openSystemSettings() async {}
  @override
  String get zoneName => 'UTC';
}
