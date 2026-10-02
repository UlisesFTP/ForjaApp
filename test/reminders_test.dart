import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/notification_service.dart';
import 'package:forja_app/domain/services/reminder_planner.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

import 'support/fake_notifications.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

Routine? weekly(DateTime d) => switch (d.weekday) {
  DateTime.tuesday => examplePlan.routines[0],
  DateTime.thursday => examplePlan.routines[1],
  DateTime.saturday => examplePlan.routines[2],
  _ => null,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'DM Sans',
    )..addFont(rootBundle.load('assets/fonts/DMSans.ttf'))).load();
    await (FontLoader('Barlow Condensed')
          ..addFont(rootBundle.load('assets/fonts/BarlowCondensed-Bold.ttf')))
        .load();
  });

  const on = ReminderSettings(enabled: true, hour: 7, minute: 30);
  const zone = 'America/Mexico_City';

  List<ScheduledNotification> plan({
    ReminderSettings settings = on,
    DateTime? now,
    Routine? Function(DateTime)? routineOn,
    Map<String, SessionStatus> status = const {},
    String z = zone,
  }) => ReminderPlanner.plan(
    settings: settings,
    now: now ?? DateTime(2026, 9, 30, 12),
    routineOn: routineOn ?? weekly,
    statusOn: (d) =>
        status['${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'],
    zone: z,
  );

  group('reminder planning (F11)', () {
    test('nothing when reminders are off', () {
      expect(plan(settings: const ReminderSettings()), isEmpty);
    });

    test('one reminder per planned workout in the next 28 days', () {
      final list = plan();
      // Wed 30 Sep → Tue 27 Oct: four weeks of Tue/Thu/Sat.
      expect(list, hasLength(12));
      expect(list.first.at, DateTime(2026, 10, 1, 7, 30));
      expect(list.first.id, 20261001);
      expect(list.last.at.isBefore(DateTime(2026, 10, 28)), isTrue);
      expect(list.map((n) => n.at.weekday).toSet(), {2, 4, 6});
      expect(list.every((n) => n.at.hour == 7 && n.at.minute == 30), isTrue);
    });

    test('the horizon is exactly 28 days from today', () {
      final list = plan(now: DateTime(2026, 9, 29, 6));
      final last = DateTime(2026, 9, 29).add(const Duration(days: 27));
      expect(
        list.every(
          (n) => !DateTime(n.at.year, n.at.month, n.at.day).isAfter(last),
        ),
        isTrue,
      );
      // Today (Tue) is included while its hour is still ahead.
      expect(list.first.at, DateTime(2026, 9, 29, 7, 30));
      expect(list.first.title, 'Hoy toca: Pierna & fuerza');
      expect(list[1].title, isNot(startsWith('Hoy')));
    });

    test('today is skipped once its hour has passed', () {
      final list = plan(now: DateTime(2026, 9, 29, 7, 30));
      expect(list.first.at, DateTime(2026, 10, 1, 7, 30));
      expect(
        plan(now: DateTime(2026, 9, 29, 7, 29)).first.at,
        DateTime(2026, 9, 29, 7, 30),
      );
    });

    test('finished sessions get no reminder; open ones do', () {
      for (final done in [
        SessionStatus.completed,
        SessionStatus.partial,
        SessionStatus.missed,
      ]) {
        final list = plan(status: {'2026-10-01': done});
        expect(list.first.at.day, 3, reason: done.name);
      }
      expect(
        plan(status: {'2026-10-01': SessionStatus.scheduled}).first.id,
        20261001,
      );
    });

    test('rest days and moved workouts follow the routines of the day', () {
      final moved = plan(
        routineOn: (d) =>
            d.day == 2 && d.month == 10 ? examplePlan.routines[0] : weekly(d),
      );
      expect(moved.map((n) => n.id), contains(20261002));
      final none = plan(routineOn: (_) => null);
      expect(none, isEmpty);
    });

    test('ids are the date, unique across month and year ends', () {
      final list = plan(
        now: DateTime(2026, 12, 20),
        routineOn: (d) => examplePlan.routines[0],
      );
      expect(list.map((n) => n.id).toSet(), hasLength(list.length));
      expect(list.map((n) => n.id), contains(20261231));
      expect(list.map((n) => n.id), contains(20270101));
      expect(ReminderPlanner.idFor(DateTime(2027, 1, 5)), 20270105);
      expect(
        ReminderPlanner.idFor(DateTime(2026, 10, 1)) == ReminderPlanner.testId,
        isFalse,
      );
    });

    test('the payload carries the day, the hour and the zone', () {
      final p = plan().first.payload;
      expect(p, 'session:2026-10-01@07:30@$zone');
      expect(ReminderPlanner.dateFromPayload(p), DateTime(2026, 10, 1));
      // Another zone or hour is another payload: it is rescheduled.
      expect(plan(z: 'Europe/Madrid').first.payload, isNot(p));
      expect(
        plan(settings: const ReminderSettings(enabled: true, hour: 8))
            .first
            .payload,
        isNot(p),
      );
    });

    test('bad payloads open nothing', () {
      for (final bad in [
        '',
        'x',
        'session:',
        'session:2026-02-31@07:30@UTC',
        'session:2026-13-01',
        'workout:2026-10-01',
        'session:20261001',
      ]) {
        expect(ReminderPlanner.dateFromPayload(bad), isNull, reason: bad);
      }
      expect(
        ReminderPlanner.dateFromPayload('session:2026-10-01'),
        DateTime(2026, 10, 1),
      );
    });

    test('daylight saving does not move the hour: each day is its own wall-clock time', () {
      // US clocks change on 8 March 2026 and 1 November 2026.
      for (final start in [DateTime(2026, 3, 1), DateTime(2026, 10, 25)]) {
        final list = ReminderPlanner.plan(
          settings: const ReminderSettings(enabled: true, hour: 18, minute: 0),
          now: start,
          routineOn: (d) => examplePlan.routines[0],
          statusOn: (_) => null,
          zone: 'America/New_York',
        );
        expect(list, hasLength(28));
        expect(list.every((n) => n.at.hour == 18 && n.at.minute == 0), isTrue);
      }
    });

    test('reconciling changes only the difference, and repeating it changes nothing', () {
      final desired = plan();
      final first = ReminderPlanner.reconcile(
        desired: desired,
        pending: const [],
      );
      expect(first.cancel, isEmpty);
      expect(first.schedule, hasLength(12));
      final pending = [
        for (final n in desired)
          PendingNotification(id: n.id, payload: n.payload),
      ];
      final again = ReminderPlanner.reconcile(
        desired: desired,
        pending: pending,
      );
      expect(again.cancel, isEmpty);
      expect(again.schedule, isEmpty);
    });

    test('a new hour cancels and schedules each affected reminder', () {
      final old = plan();
      final pending = [
        for (final n in old) PendingNotification(id: n.id, payload: n.payload),
      ];
      final later = plan(
        settings: const ReminderSettings(enabled: true, hour: 9),
      );
      final diff = ReminderPlanner.reconcile(desired: later, pending: pending);
      expect(diff.cancel, hasLength(12));
      expect(diff.schedule, hasLength(12));
    });

    test(
      'stale reminders are cancelled; the test notification is left alone',
      () {
        final desired = plan();
        final pending = [
          for (final n in desired)
            PendingNotification(id: n.id, payload: n.payload),
          const PendingNotification(
            id: 20250101,
            payload: 'session:2025-01-01@07:30@UTC',
          ),
          const PendingNotification(id: ReminderPlanner.testId, payload: 'x'),
        ];
        final diff = ReminderPlanner.reconcile(
          desired: desired,
          pending: pending,
        );
        expect(diff.cancel, [20250101]);
        expect(diff.schedule, isEmpty);
      },
    );
  });

  group('reminder coordinator (F11)', () {
    late FakeNotificationService fake;
    late AppDependencies d;
    var now = DateTime(2026, 9, 30, 12);

    Future<void> boot({
      NotificationPermission permission = NotificationPermission.granted,
      ReminderSettings? settings,
    }) async {
      fake = FakeNotificationService(granted: permission);
      d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => now,
        notifications: fake,
      );
      addTearDown(() => unawaited(d.dispose()));
      if (settings != null) await d.repository.saveReminder(settings);
      await d.reminders.start();
    }

    setUp(() => now = DateTime(2026, 9, 30, 12));

    test(
      'with reminders on it schedules the window; off cancels everything',
      () async {
        await boot(settings: on);
        expect(fake.scheduled, hasLength(12));
        expect(d.reminders.status.scheduled, 12);
        expect(d.reminders.status.next, DateTime(2026, 10, 1, 7, 30));
        await d.repository.saveReminder(const ReminderSettings());
        await d.reminders.reconcile();
        expect(fake.scheduled, isEmpty);
        expect(d.reminders.status.scheduled, 0);
      },
    );

    test(
      'running again never duplicates or reschedules what is right',
      () async {
        await boot(settings: on);
        fake.calls.clear();
        await d.reminders.reconcile();
        await d.reminders.reconcile();
        expect(fake.calls.where((c) => c.startsWith('schedule')), isEmpty);
        expect(fake.calls.where((c) => c.startsWith('cancel')), isEmpty);
        expect(fake.scheduled.map((n) => n.id).toSet(), hasLength(12));
      },
    );

    test('concurrent reconciliations are merged', () async {
      await boot(settings: on);
      fake.store.clear();
      fake.calls.clear();
      await Future.wait([for (var i = 0; i < 6; i++) d.reminders.reconcile()]);
      final schedules = fake.calls
          .where((c) => c.startsWith('schedule'))
          .toList();
      expect(
        schedules.toSet(),
        hasLength(schedules.length),
        reason: 'no id twice',
      );
      expect(fake.scheduled, hasLength(12));
    });

    test('completing a session cancels that day only', () async {
      await boot(settings: on);
      final thursday = DateTime(2026, 10, 1);
      for (final e in d.repository.sessionOn(thursday)!.exercises) {
        await d.repository.toggleExercise(thursday, e.exerciseId);
      }
      await d.repository.finishSession(thursday, SessionStatus.completed);
      await d.reminders.reconcile();
      expect(fake.store.containsKey(20261001), isFalse);
      expect(fake.scheduled, hasLength(11));
      // Reopening it brings the reminder back.
      await d.repository.reopenSession(thursday);
      await d.reminders.reconcile();
      expect(fake.store.containsKey(20261001), isTrue);
    });

    test('rescheduling a session moves its reminder with it', () async {
      await boot(settings: on);
      final moved = await d.repository.finishSession(
        DateTime(2026, 10, 1),
        SessionStatus.missed,
      );
      await d.reminders.reconcile();
      expect(fake.store.containsKey(20261001), isFalse);
      expect(fake.store.containsKey(ReminderPlanner.idFor(moved!)), isTrue);
      // Undoing brings it back to the original day.
      await d.repository.undoReschedule(d.repository.reschedules.single.id);
      await d.reminders.reconcile();
      expect(fake.store.containsKey(20261001), isTrue);
      expect(fake.store.containsKey(ReminderPlanner.idFor(moved)), isFalse);
    });

    test('editing the hour reschedules every reminder', () async {
      await boot(settings: on);
      await d.repository.saveReminder(
        const ReminderSettings(enabled: true, hour: 19, minute: 15),
      );
      await d.reminders.reconcile();
      expect(fake.scheduled, hasLength(12));
      expect(
        fake.scheduled.every((n) => n.at.hour == 19 && n.at.minute == 15),
        isTrue,
      );
    });

    test(
      'a changed time zone reschedules (the payload names the zone)',
      () async {
        await boot(settings: on);
        fake.zone = 'Asia/Tokyo';
        await d.reminders.reconcile();
        expect(
          fake.scheduled.every((n) => n.payload.endsWith('@Asia/Tokyo')),
          isTrue,
        );
        expect(fake.scheduled, hasLength(12));
      },
    );

    test('a new day moves the window forward', () async {
      await boot(settings: on);
      now = DateTime(2026, 10, 20, 12);
      await d.reminders.reconcile();
      expect(fake.scheduled.first.at.isAfter(DateTime(2026, 10, 20)), isTrue);
      expect(fake.scheduled.last.at.isAfter(DateTime(2026, 11, 1)), isTrue);
      expect(fake.store.containsKey(20261001), isFalse);
    });

    test(
      'without permission nothing is scheduled but the wish is kept',
      () async {
        await boot(permission: NotificationPermission.denied, settings: on);
        expect(fake.scheduled, isEmpty);
        expect(d.repository.reminder.enabled, isTrue);
        expect(d.reminders.status.permission, NotificationPermission.denied);
        expect(d.reminders.status.scheduled, 0);
        // The person allows it in the system settings and returns to the app.
        fake.granted = NotificationPermission.granted;
        await d.reminders.reconcile();
        expect(fake.scheduled, hasLength(12));
      },
    );

    test('revoking the permission removes what was queued', () async {
      await boot(settings: on);
      expect(fake.scheduled, hasLength(12));
      fake.granted = NotificationPermission.denied;
      await d.reminders.reconcile();
      expect(fake.scheduled, isEmpty);
      expect(d.reminders.status.permission, NotificationPermission.denied);
    });

    test('a platform failure is reported and the next run recovers', () async {
      await boot(settings: on);
      fake.store.clear();
      fake.failSchedule = true;
      await d.reminders.reconcile();
      expect(d.reminders.status.error, contains('No se pudieron programar'));
      fake.failSchedule = false;
      await d.reminders.reconcile();
      expect(d.reminders.status.error, isNull);
      expect(fake.scheduled, hasLength(12));
    });

    test('a tap while the app runs asks to open that day', () async {
      await boot(settings: on);
      fake.tap('session:2026-10-03@07:30@$zone');
      expect(d.reminders.taps.value, DateTime(2026, 10, 3));
      fake.tap('garbage');
      expect(d.reminders.taps.value, DateTime(2026, 10, 3), reason: 'ignored');
      expect(d.reminders.tapCount, 1);
    });

    test('a tap that started the app from closed is handled once', () async {
      fake = FakeNotificationService()
        ..launch = 'session:2026-10-06@07:30@$zone';
      d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => now,
        notifications: fake,
      );
      addTearDown(() => unawaited(d.dispose()));
      await d.reminders.start();
      expect(d.reminders.taps.value, DateTime(2026, 10, 6));
      await d.reminders.start();
      expect(fake.initializations, 1, reason: 'start() is idempotent');
    });

    test(
      'the system permission can be asked for, and the answer is shown',
      () async {
        await boot(permission: NotificationPermission.unknown, settings: on);
        fake.afterRequest = NotificationPermission.denied;
        expect(
          await d.reminders.requestPermission(),
          NotificationPermission.denied,
        );
        expect(d.reminders.status.permission, NotificationPermission.denied);
        fake.afterRequest = NotificationPermission.granted;
        await d.reminders.requestPermission();
        expect(fake.scheduled, hasLength(12));
      },
    );

    test(
      'the test notification opens today and never shows as a session reminder',
      () async {
        await boot(settings: on);
        await d.reminders.sendTest();
        expect(fake.shown.single, startsWith('session:2026-09-30@07:30'));
        // The test id never collides with a date and survives reconciliation.
        fake.store[ReminderPlanner.testId] = ScheduledNotification(
          id: ReminderPlanner.testId,
          at: DateTime(2026, 10, 1),
          title: 't',
          body: 'b',
          payload: 'x',
        );
        await d.reminders.reconcile();
        expect(fake.store.containsKey(ReminderPlanner.testId), isTrue);
      },
    );

    test('with no native notifications nothing breaks', () async {
      final noop = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => now,
      );
      addTearDown(() => unawaited(noop.dispose()));
      await noop.repository.saveReminder(on);
      await noop.reminders.start();
      expect(noop.reminders.status.permission, NotificationPermission.unknown);
      expect(noop.reminders.status.scheduled, 12);
    });
  });

  group('reminder screens (F11)', () {
    Future<(AppDependencies, FakeNotificationService)> start(
      WidgetTester tester, {
      NotificationPermission permission = NotificationPermission.granted,
      double width = 390,
      double scale = 1,
      ReminderSettings? settings,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 2400);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fake = FakeNotificationService(granted: permission);
      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => DateTime(2026, 9, 30, 12),
        notifications: fake,
      );
      addTearDown(() => unawaited(d.dispose()));
      if (settings != null) await d.repository.saveReminder(settings);
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: Size(width, 2400),
            textScaler: TextScaler.linear(scale),
          ),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      await tester.pumpAndSettle();
      return (d, fake);
    }

    Future<void> openSheet(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Recordatorios'));
      await tester.pumpAndSettle();
    }

    testWidgets('the wish and the system permission are shown apart', (
      tester,
    ) async {
      final (d, fake) = await start(
        tester,
        permission: NotificationPermission.denied,
        settings: on,
      );
      await openSheet(tester);
      expect(
        find.textContaining('Permiso del sistema: denegado'),
        findsOneWidget,
      );
      expect(find.textContaining('Programados: ninguno'), findsOneWidget);
      expect(d.repository.reminder.enabled, isTrue);
      expect(find.byKey(const ValueKey('ask-permission')), findsOneWidget);
      expect(find.byKey(const ValueKey('open-settings')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('open-settings')));
      await tester.pump();
      expect(fake.settingsOpened, isTrue);
    });

    testWidgets('allowing shows the real state and what is scheduled', (
      tester,
    ) async {
      final (_, fake) = await start(
        tester,
        permission: NotificationPermission.unknown,
        settings: on,
      );
      await openSheet(tester);
      expect(find.textContaining('sin comprobar'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ask-permission')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Permiso del sistema: permitido'),
        findsOneWidget,
      );
      expect(find.textContaining('Programados: 12'), findsOneWidget);
      expect(fake.scheduled, hasLength(12));
      expect(find.byKey(const ValueKey('send-test')), findsOneWidget);
    });

    testWidgets(
      'turning reminders on asks for permission and saves the wish even if refused',
      (tester) async {
        final (d, fake) = await start(
          tester,
          permission: NotificationPermission.unknown,
        );
        fake.afterRequest = NotificationPermission.denied;
        await openSheet(tester);
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar preferencia'));
        await tester.pumpAndSettle();
        expect(fake.calls, contains('request'));
        expect(d.repository.reminder.enabled, isTrue);
        expect(
          find.textContaining('El sistema no permite avisos'),
          findsOneWidget,
        );
        expect(fake.scheduled, isEmpty);
      },
    );

    testWidgets(
      'saving with permission already granted schedules and says how many',
      (tester) async {
        final (d, fake) = await start(tester);
        await openSheet(tester);
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Guardar preferencia'));
        await tester.pumpAndSettle();
        expect(fake.calls, isNot(contains('request')));
        expect(d.repository.reminder.enabled, isTrue);
        expect(fake.scheduled, hasLength(12));
        expect(find.text('Recordatorios programados: 12'), findsOneWidget);
      },
    );

    testWidgets('turning them off cancels what was scheduled', (tester) async {
      final (d, fake) = await start(tester, settings: on);
      await d.reminders.reconcile();
      expect(fake.scheduled, hasLength(12));
      await openSheet(tester);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar preferencia'));
      await tester.pumpAndSettle();
      expect(fake.scheduled, isEmpty);
      expect(find.text('Recordatorios desactivados'), findsOneWidget);
    });

    testWidgets('the test notification can be sent when allowed', (
      tester,
    ) async {
      final (_, fake) = await start(tester, settings: on);
      await openSheet(tester);
      await tester.tap(find.byKey(const ValueKey('send-test')));
      await tester.pumpAndSettle();
      expect(fake.shown, hasLength(1));
      expect(find.text('Aviso de prueba enviado'), findsOneWidget);
    });

    testWidgets('a tapped reminder opens its day in Hoy, from any screen', (
      tester,
    ) async {
      final (d, fake) = await start(tester, settings: on);
      d.shell.open(AppPage.progress);
      await tester.pumpAndSettle();
      fake.tap('session:2026-10-03@07:30@$zone');
      await tester.pumpAndSettle();
      expect(d.shell.page, AppPage.today);
      expect(d.today.selectedDate, DateTime(2026, 10, 3));
      expect(find.text('Tirón'), findsOneWidget);
      // Handled: the same notification can be tapped again later.
      d.today.selectDate(DateTime(2026, 10, 1));
      fake.tap('session:2026-10-03@07:30@$zone');
      await tester.pumpAndSettle();
      expect(d.today.selectedDate, DateTime(2026, 10, 3));
    });

    testWidgets(
      'coming back to the app looks at the permission and the window again',
      (tester) async {
        final (d, fake) = await start(
          tester,
          permission: NotificationPermission.denied,
          settings: on,
        );
        expect(fake.scheduled, isEmpty);
        fake.granted = NotificationPermission.granted;
        // The valid path an app takes to the background and back.
        for (final state in [
          AppLifecycleState.inactive,
          AppLifecycleState.hidden,
          AppLifecycleState.paused,
          AppLifecycleState.hidden,
          AppLifecycleState.inactive,
          AppLifecycleState.resumed,
        ]) {
          tester.binding.handleAppLifecycleStateChanged(state);
        }
        await tester.pumpAndSettle();
        expect(fake.scheduled, hasLength(12));
        expect(d.reminders.status.permission, NotificationPermission.granted);
      },
    );

    testWidgets('the reminders screen fits 320 px at 200% text', (
      tester,
    ) async {
      await start(
        tester,
        width: 320,
        scale: 2,
        permission: NotificationPermission.denied,
        settings: on,
      );
      await openSheet(tester);
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('open-settings')), findsOneWidget);
    });
  });
}
