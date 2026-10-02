import 'package:forja_app/domain/services/notification_service.dart';

/// A stand-in for the platform: keeps what was scheduled, lets a test change
/// the permission and "tap" a notification. It shows intent; only a device
/// shows delivery.
class FakeNotificationService implements NotificationService {
  FakeNotificationService({
    this.granted = NotificationPermission.granted,
    this.zone = 'America/Mexico_City',
  });
  NotificationPermission granted;
  // What a request will result in.
  NotificationPermission afterRequest = NotificationPermission.granted;
  String zone;

  final Map<int, ScheduledNotification> store = {};
  final List<String> calls = [];
  void Function(String payload)? _onTap;
  String? launch;
  bool failSchedule = false;
  int initializations = 0;

  @override
  String get zoneName => zone;

  @override
  Future<void> initialize({
    required void Function(String payload) onTap,
  }) async {
    initializations++;
    _onTap = onTap;
  }

  @override
  Future<NotificationPermission> permission() async => granted;

  @override
  Future<NotificationPermission> requestPermission() async {
    calls.add('request');
    granted = afterRequest;
    return granted;
  }

  @override
  Future<List<PendingNotification>> pending() async => [
    for (final n in store.values)
      PendingNotification(
        id: n.id,
        payload: n.payload,
        title: n.title,
        body: n.body,
      ),
  ];

  @override
  Future<void> schedule(ScheduledNotification n) async {
    if (failSchedule) throw StateError('no se pudo programar');
    calls.add('schedule ${n.id}');
    // The platform keeps one notification per id: scheduling replaces.
    store[n.id] = n;
  }

  @override
  Future<void> cancel(int id) async {
    calls.add('cancel $id');
    store.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    calls.add('cancelAll');
    store.clear();
  }

  @override
  Future<String?> launchPayload() async {
    final p = launch;
    launch = null;
    return p;
  }

  final List<String> shown = [];
  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async => shown.add(payload);

  bool settingsOpened = false;
  @override
  Future<void> openSystemSettings() async => settingsOpened = true;

  /// The person taps a delivered notification while the app is running.
  void tap(String payload) => _onTap?.call(payload);

  List<ScheduledNotification> get scheduled =>
      store.values.toList()..sort((a, b) => a.at.compareTo(b.at));
}
