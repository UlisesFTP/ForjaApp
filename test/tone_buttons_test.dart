import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/core/theme/forja_theme.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/ui/core/tone_buttons.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

double _luminance(Color c) {
  double lin(double v) =>
      v <= .03928 ? v / 12.92 : math.pow((v + .055) / 1.055, 2.4).toDouble();
  return .2126 * lin(c.r) + .7152 * lin(c.g) + .0722 * lin(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + .05) / (lo + .05);
}

/// D44: green, yellow and red on key action buttons. The colour never stands
/// alone (each button has an icon and a label) and must stay readable in
/// every state.
void main() {
  group('the action colours (D44)', () {
    final states = <String, Set<WidgetState>>{
      'rest': {},
      'hover': {WidgetState.hovered},
      'focus': {WidgetState.focused},
      'pressed': {WidgetState.pressed, WidgetState.hovered},
    };

    for (final tone in ActionTone.values) {
      for (final e in states.entries) {
        test('${tone.name} · ${e.key}: white text and icon are at least '
            '4.5:1 on the solid fill', () {
          final fill = toneFill(tone, e.value);
          expect(
            _contrast(toneText, fill),
            greaterThanOrEqualTo(4.5),
            reason: 'label and icon on the fill',
          );
        });
      }
      test('${tone.name}: the button stands out from the dark background '
          'and from the paper cards (3:1)', () {
        expect(
          _contrast(toneAccent(tone), ForjaColors.background),
          greaterThanOrEqualTo(3),
        );
        expect(
          _contrast(toneAccent(tone), ForjaColors.paper),
          greaterThanOrEqualTo(3),
        );
        expect(
          _contrast(toneAccent(tone), ForjaColors.surface),
          greaterThanOrEqualTo(3),
        );
      });
    }

    test('the fill is solid, white-on-colour, compact and still a 48 px '
        'tap target', () {
      for (final tone in ActionTone.values) {
        final style = toneStyle(tone);
        expect(style.foregroundColor!.resolve({}), ForjaColors.onTone);
        expect(style.iconColor!.resolve({}), ForjaColors.onTone);
        expect(style.backgroundColor!.resolve({})!.a, 1, reason: 'solid');
        expect(style.minimumSize!.resolve({})!.height, 40, reason: 'compact');
        expect(style.tapTargetSize, MaterialTapTargetSize.padded);
        expect(style.side!.resolve({}), BorderSide.none);
      }
    });

    test('hover, focus and press each look different from rest, and the '
        'disabled one is quiet', () {
      for (final tone in ActionTone.values) {
        final style = toneStyle(tone);
        Color? bg(Set<WidgetState> s) => style.backgroundColor!.resolve(s);
        final rest = bg({}), hover = bg({WidgetState.hovered});
        final focus = bg({WidgetState.focused});
        final pressed = bg({WidgetState.pressed});
        expect({rest, hover, pressed}.length, 3, reason: tone.name);
        expect(focus, hover);
        expect(
          style.side!.resolve({WidgetState.hovered})!.width,
          greaterThan(0),
          reason: 'hover adds a light outline',
        );
        expect(
          style.side!.resolve({WidgetState.focused})!.width,
          greaterThan(style.side!.resolve({WidgetState.hovered})!.width),
          reason: 'focus thickens it',
        );
        expect(bg({WidgetState.disabled}), ForjaColors.border);
        expect(
          style.foregroundColor!.resolve({WidgetState.disabled}),
          ForjaColors.muted,
        );
        expect(style.mouseCursor!.resolve({}), SystemMouseCursors.click);
        expect(
          style.mouseCursor!.resolve({WidgetState.disabled}),
          SystemMouseCursors.basic,
        );
      }
    });

    test('red, yellow and green are three different colours, and none of '
        'them is the flame', () {
      final all = {for (final t in ActionTone.values) toneAccent(t)};
      expect(all.length, 3);
      expect(all, isNot(contains(ForjaColors.flame)));
      expect(all, isNot(contains(ForjaColors.flameCore)));
    });

    testWidgets('a mouse over a button tints it; leaving restores it, and '
        'the button keeps its own type, key and label', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: forjaTheme(),
          home: Scaffold(
            body: Center(
              child: FilledButton(
                key: const ValueKey('save'),
                style: toneStyle(ActionTone.confirm),
                onPressed: () => taps++,
                child: const ToneLabel(Icons.save_outlined, 'Guardar'),
              ),
            ),
          ),
        ),
      );
      Color fill() {
        final m = tester.widget<Material>(
          find
              .descendant(
                of: find.byKey(const ValueKey('save')),
                matching: find.byType(Material),
              )
              .first,
        );
        return m.color!;
      }

      expect(find.widgetWithText(FilledButton, 'Guardar'), findsOneWidget);
      expect(find.byIcon(Icons.save_outlined), findsOneWidget);
      final rest = fill();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byKey(const ValueKey('save'))));
      await tester.pumpAndSettle();
      final hover = fill();
      expect(hover, isNot(rest));
      expect(
        _contrast(toneText, hover),
        greaterThanOrEqualTo(4.5),
        reason: 'the label stays readable while hovered',
      );
      await mouse.moveTo(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(fill(), rest);
      await tester.tap(find.byKey(const ValueKey('save')));
      expect(taps, 1);
    });

    testWidgets('the visible button is compact (40 px) and its tap target '
        'is 48 px', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: forjaTheme(),
          home: Scaffold(
            body: Center(
              child: FilledButton(
                key: const ValueKey('compact'),
                style: toneStyle(ActionTone.confirm),
                onPressed: () {},
                child: const ToneLabel(Icons.check, 'Aceptar'),
              ),
            ),
          ),
        ),
      );
      final outer = tester.getSize(find.byKey(const ValueKey('compact')));
      expect(outer.height, greaterThanOrEqualTo(48), reason: 'tap target');
      final visible = tester.getSize(
        find
            .descendant(
              of: find.byKey(const ValueKey('compact')),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(visible.height, 40);
    });

    testWidgets('the neutral buttons also react to the pointer (theme)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: forjaTheme(),
          home: Scaffold(
            body: Center(
              child: OutlinedButton(
                key: const ValueKey('plain'),
                onPressed: () {},
                child: const Text('Por qué'),
              ),
            ),
          ),
        ),
      );
      final style = tester
          .widget<OutlinedButton>(find.byKey(const ValueKey('plain')))
          .style;
      expect(style, isNull, reason: 'it uses the theme');
      final theme = forjaTheme().outlinedButtonTheme.style!;
      expect(theme.overlayColor!.resolve({WidgetState.hovered}), isNotNull);
      expect(theme.overlayColor!.resolve({WidgetState.focused}), isNotNull);
      expect(theme.overlayColor!.resolve({WidgetState.pressed}), isNotNull);
      expect(theme.overlayColor!.resolve({}), isNull);
    });

    testWidgets('a long label wraps at 320 px with text at 200 % and the '
        'button stays 48 px tall at least', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 700),
            textScaler: TextScaler.linear(2),
          ),
          child: MaterialApp(
            theme: forjaTheme(),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  key: const ValueKey('long'),
                  style: toneStyle(ActionTone.danger),
                  onPressed: () {},
                  child: const ToneLabel(
                    Icons.delete_forever_outlined,
                    'Desactivar y borrar todo lo del asistente',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const ValueKey('long'))).height,
        greaterThanOrEqualTo(48),
      );
    });
  });

  group('the coloured buttons in the app', () {
    Future<AppDependencies> open(
      WidgetTester tester, {
      Size size = const Size(390, 2400),
      double scale = 1,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await AppDependencies.create(
        store: MemoryForjaStore(),
        launcher: _Launcher(),
        clock: () => DateTime(2026, 10, 7, 12),
      );
      addTearDown(() => unawaited(d.dispose()));
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(scale),
          ),
          child: ForjaApp(dependencies: d, offerOnboarding: false),
        ),
      );
      d.shell.open(AppPage.more);
      await tester.pumpAndSettle();
      return d;
    }

    Future<void> openData(WidgetTester tester) async {
      final row = find.text('Datos y privacidad');
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await tester.pumpAndSettle();
    }

    for (final (size, scale) in [
      (const Size(390, 2400), 1.0),
      (const Size(320, 1800), 2.0),
    ]) {
      testWidgets('data sheet at ${size.width.toInt()} px, text '
          '${(scale * 100).toInt()} %: the delete button is red with its '
          'icon, and nothing overflows', (tester) async {
        final handle = tester.ensureSemantics();
        await open(tester, size: size, scale: scale);
        await openData(tester);
        final delete = find.byKey(const ValueKey('delete-all'));
        await tester.ensureVisible(delete);
        await tester.pumpAndSettle();
        final button = tester.widget<OutlinedButton>(delete);
        final style = button.style!;
        expect(
          style.backgroundColor!.resolve({}),
          ForjaColors.danger,
          reason: 'solid red',
        );
        expect(style.foregroundColor!.resolve({}), ForjaColors.onTone);
        expect(
          find.descendant(of: delete, matching: find.byType(Icon)),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: delete,
            matching: find.text('Eliminar todos mis datos'),
          ),
          findsOneWidget,
        );
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        expect(tester.takeException(), isNull);
        handle.dispose();
      });
    }
  });
}
