import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/services/notification_service.dart';

/// Local (on-device) notifications through `flutter_local_notifications`:
/// no push, no server. Scheduling is inexact (the system may delay a
/// reminder a little), so the app needs no exact-alarm permission.
class LocalNotificationService implements NotificationService {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _plugin;
  String _zone = 'UTC';

  static const _channelId = 'forja_training';
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Entrenamientos',
      channelDescription: 'Recordatorios de tus sesiones de entrenamiento',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_stat_forja',
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  String get zoneName => _zone;

  // The zone can change while the app is closed (travel, DST, a new setting),
  // so it is read again on every initialization and by the coordinator.
  Future<void> _refreshZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
      _zone = info.identifier;
    } catch (_) {
      // Unknown zone: keep UTC rather than schedule at a wrong local hour.
      tz.setLocalLocation(tz.UTC);
      _zone = 'UTC';
    }
  }

  @override
  Future<void> initialize({
    required void Function(String payload) onTap,
  }) async {
    tzdata.initializeTimeZones();
    await _refreshZone();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_forja'),
        // Permission is requested from the reminders screen, not at startup.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) onTap(payload);
      },
    );
  }

  @override
  Future<NotificationPermission> permission() async {
    await _refreshZone();
    if (Platform.isAndroid) {
      final enabled = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();
      return enabled == null
          ? NotificationPermission.unknown
          : enabled
          ? NotificationPermission.granted
          : NotificationPermission.denied;
    }
    if (Platform.isIOS) {
      final options = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      return options == null
          ? NotificationPermission.unknown
          : options.isEnabled
          ? NotificationPermission.granted
          : NotificationPermission.denied;
    }
    return NotificationPermission.unknown;
  }

  @override
  Future<NotificationPermission> requestPermission() async {
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, sound: true);
    }
    return permission();
  }

  @override
  Future<List<PendingNotification>> pending() async => [
    for (final p in await _plugin.pendingNotificationRequests())
      PendingNotification(
        id: p.id,
        payload: p.payload ?? '',
        title: p.title,
        body: p.body,
      ),
  ];

  @override
  Future<void> schedule(ScheduledNotification n) async {
    // The wall-clock hour in the current zone: each day is converted on its
    // own, so a daylight-saving change keeps the reminder at the same hour.
    final when = tz.TZDateTime(
      tz.local,
      n.at.year,
      n.at.month,
      n.at.day,
      n.at.hour,
      n.at.minute,
    );
    await _plugin.zonedSchedule(
      id: n.id,
      title: n.title,
      body: n.body,
      scheduledDate: when,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: n.payload,
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    final payload = details.notificationResponse?.payload;
    return payload == null || payload.isEmpty ? null : payload;
  }

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) => _plugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: _details,
    payload: payload,
  );

  @override
  Future<void> openSystemSettings() async {
    try {
      await _plugin.openAppNotificationSettings();
    } catch (e) {
      debugPrint('No se pudieron abrir los ajustes: $e');
    }
  }
}
