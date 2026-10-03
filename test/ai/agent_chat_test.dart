import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/app/forja_app.dart';
import 'package:forja_app/core/theme/forja_theme.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/data/services/tutorial_launcher.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/ai/ai_client.dart';
import 'package:forja_app/domain/services/ai/ai_prompts.dart';
import 'package:forja_app/domain/services/ai/ai_settings.dart';
import 'package:forja_app/domain/services/ai/ai_types.dart';
import 'package:forja_app/domain/services/ai/mcp/proposal_inbox.dart';
import 'package:forja_app/domain/services/ai/proposal_gate.dart';
import 'package:forja_app/ui/coach/view_models/coach_chat_view_model.dart';
import 'package:forja_app/ui/shell/view_models/shell_view_model.dart';

class _Launcher implements TutorialLauncher {
  @override
  Future<bool> open(Uri uri) async => true;
}

/// Answers from a script; records every request.
class ScriptedClient implements AiChatClient {
  ScriptedClient(this.script);
  final List<AiResponse Function(AiRequest)> script;
  final requests = <AiRequest>[];
  Object? failWith;

  @override
  Future<AiResponse> complete(
    AiRequest request,
    AiEndpoint endpoint, {
    Future<void>? cancel,
  }) async {
    requests.add(request);
    final f = failWith;
    if (f != null) throw f;
    final next = script.isEmpty ? _text('Listo.') : script.removeAt(0);
    return next(request);
  }
}

AiResponse Function(AiRequest) _text(String text) =>
    (_) => AiResponse(
      message: AiMessage(role: AiRole.assistant, content: text),
      usage: const AiUsage(prompt: 100, completion: 20),
      model: 'mimo-v2.6-flash',
      latency: const Duration(milliseconds: 500),
    );

AiResponse Function(AiRequest) _call(String name, Object? args) =>
    (_) => AiResponse(
      message: AiMessage(
        role: AiRole.assistant,
        reasoning: 'pienso en $name',
        toolCalls: [
          AiToolCall(
            id: 'call_$name',
            name: name,
            arguments: args is String ? args : jsonEncode(args),
          ),
        ],
      ),
      usage: const AiUsage(prompt: 80, completion: 10),
      model: 'mimo-v2.6-flash',
      latency: const Duration(milliseconds: 400),
    );

final _now = DateTime(2026, 10, 6, 12);

Future<AppDependencies> _deps(
  ScriptedClient client, {
  bool tools = true,
  Set<DataCategory>? categories,
}) async {
  final d = await AppDependencies.create(
    store: MemoryForjaStore(),
    launcher: _Launcher(),
    aiClient: client,
    secrets: MemorySecretStore()..key = 'sk-test-key-0000000000',
    aiSettings: MemoryAiSettingsStore(),
    clock: () => _now,
  );
  await d.ai.accept(categories ?? {...DataCategory.values});
  await d.ai.setCapabilities(AiCapabilities(tools: tools, jsonMode: false));
  return d;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the chat runs the in-app tools, read-only (F17)', () {
    test('a tool call is answered with FORJA data and the reasoning goes '
        'back', () async {
      final client = ScriptedClient([
        _call('get_profile', {}),
        _text('Tu objetivo es ganar fuerza.'),
      ]);
      final d = await _deps(client);
      addTearDown(() => unawaited(d.dispose()));
      final vm = d.createCoachChat();
      addTearDown(vm.dispose);
      await vm.send('¿Cuál es mi objetivo?');
      expect(vm.entries.last.text, 'Tu objetivo es ganar fuerza.');
      expect(
        client.requests.first.tools.map((t) => t.name),
        contains('get_profile'),
      );
      expect(
        client.requests.first.messages.first.content,
        startsWith(coachChatPrompt.substring(0, 40)),
      );
      final second = client.requests[1].messages;
      final assistant = second.firstWhere((m) => m.toolCalls.isNotEmpty);
      expect(assistant.reasoning, 'pienso en get_profile');
      final tool = second.last;
      expect(tool.role, AiRole.tool);
      expect(tool.toolCallId, 'call_get_profile');
      final envelope = jsonDecode(tool.content!) as Map;
      expect(envelope['source'], 'forja');
      expect(envelope['dataOnly'], isTrue);
      final trace = vm.entries.last.turn!.trace.single;
      expect(trace.title, 'Perfil');
      expect(trace.isError, isFalse);
      expect(vm.entries.last.turn!.usage.prompt, 180);
    });

    test(
      'unknown tools and broken arguments are errors the model reads',
      () async {
        final client = ScriptedClient([
          _call('borrar_todo', {}),
          _call('get_training_history', '{no es json'),
          _text('Vale.'),
        ]);
        final d = await _deps(client);
        addTearDown(() => unawaited(d.dispose()));
        final vm = d.createCoachChat();
        addTearDown(vm.dispose);
        await vm.send('hola');
        final trace = vm.entries.last.turn!.trace;
        expect(trace.map((t) => t.isError), [true, true]);
        expect(client.requests[1].messages.last.content, contains('No existe'));
        expect(d.repository.snapshot.food, isEmpty);
      },
    );

    test('at most four rounds: the last one has no tools', () async {
      final client = ScriptedClient([
        for (var i = 0; i < 6; i++) _call('get_plan', {}),
      ]);
      final d = await _deps(client);
      addTearDown(() => unawaited(d.dispose()));
      final vm = d.createCoachChat();
      addTearDown(vm.dispose);
      await vm.send('hola');
      expect(client.requests, hasLength(4));
      expect(client.requests.last.tools, isEmpty);
      expect(vm.entries.last.role, ChatRole.assistant);
    });

    test('an injury: the model is told no increases and the app says so, '
        'even when wellbeing was not shared', () async {
      final client = ScriptedClient([_text('Puedes subir 5 kg.')]);
      final d = await _deps(
        client,
        categories: {DataCategory.profile, DataCategory.training},
      );
      addTearDown(() => unawaited(d.dispose()));
      await d.repository.saveCheckIn(
        _now,
        const CheckIn(feeling: Feeling.injured),
      );
      final vm = d.createCoachChat();
      addTearDown(vm.dispose);
      await vm.send('¿Subo peso?');
      expect(
        client.requests.single.messages.first.content,
        contains(vetoInstruction),
      );
      expect(vm.entries.last.notices.single, startsWith('Sin aumento:'));
    });

    test('without confirmed tools, a local summary of what was allowed goes '
        'instead (capsule)', () async {
      final client = ScriptedClient([_text('Resumen recibido.')]);
      final d = await _deps(
        client,
        tools: false,
        categories: {DataCategory.profile},
      );
      addTearDown(() => unawaited(d.dispose()));
      final vm = d.createCoachChat();
      addTearDown(vm.dispose);
      await vm.send('¿Qué ves?');
      final r = client.requests.single;
      expect(r.tools, isEmpty);
      expect(r.messages[1].content, contains('"dataOnly":true'));
      // Only the allowed category was summarised.
      expect(vm.entries.last.turn!.capsule, isTrue);
      expect(vm.entries.last.turn!.trace.map((t) => t.tool), ['get_profile']);
    });

    test('offline, the local rules answer; a red flag gets the app\'s own '
        'notice', () async {
      final client = ScriptedClient([])..failWith = const AiOffline();
      final d = await _deps(client);
      addTearDown(() => unawaited(d.dispose()));
      final vm = d.createCoachChat();
      addTearDown(vm.dispose);
      await vm.send('Tengo dolor en el pecho al correr');
      expect(vm.entries[1].role, ChatRole.local);
      expect(vm.entries[1].text, contains('busca atención médica'));
      expect(vm.entries.last.role, ChatRole.local);
      expect(vm.entries.last.text, contains('reglas locales'));
      expect(vm.entries.last.recommendations, isNotEmpty);
    });

    test('the conversation lives in memory only', () async {
      final client = ScriptedClient([_text('Hola.')]);
      final d = await _deps(client);
      addTearDown(() => unawaited(d.dispose()));
      final vm = d.createCoachChat();
      await vm.send('hola');
      final before = jsonEncode(d.repository.snapshot.toJson());
      expect(before, isNot(contains('hola')));
      vm.dispose();
      expect(vm.entries, isEmpty);
      expect(d.createCoachChat().entries, isEmpty);
    });
  });

  group('the chat page', () {
    Future<AppDependencies> open(
      WidgetTester tester,
      ScriptedClient client, {
      Size size = const Size(390, 2400),
      double scale = 1,
    }) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final d = await _deps(client);
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
      await tester.pumpAndSettle();
      d.shell.open(AppPage.today);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Minicoach'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Minicoach'));
      await tester.pumpAndSettle();
      final ask = find.byKey(const ValueKey('coach-ask-ai'));
      // The page's list builds lazily: scroll until the row exists.
      await tester.scrollUntilVisible(
        ask,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(ask);
      await tester.pumpAndSettle();
      return d;
    }

    testWidgets('a proposed food opens the form and is saved as an estimate', (
      tester,
    ) async {
      final client = ScriptedClient([
        _call('propose_food_entry', {
          'name': 'Tacos al pastor',
          'kcal': 540,
          'proteinG': 28,
          'confidence': 'medium',
        }),
        _text('Te propongo registrarlos.'),
      ]);
      final d = await open(tester, client);
      expect(find.textContaining('Asistente externo (IA)'), findsWidgets);
      expect(find.textContaining('No es un diagnóstico'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('chat-input')),
        'Comí 2 tacos',
      );
      await tester.tap(find.byKey(const ValueKey('chat-send')));
      await tester.pumpAndSettle();
      expect(find.text('Te propongo registrarlos.'), findsOneWidget);
      expect(
        find.text('Propuesta: Tacos al pastor · 540 kcal'),
        findsOneWidget,
      );
      expect(find.textContaining('Para el 6 oct'), findsOneWidget);
      expect(d.nutrition.entries, isEmpty, reason: 'nothing saved by itself');
      // Regression: the card's title and button were paper on paper.
      final handle = tester.ensureSemantics();
      await tester.pump();
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
      final title = tester.widget<Text>(
        find.text('Propuesta: Tacos al pastor · 540 kcal'),
      );
      expect(title.style?.color, ForjaColors.ink);
      await tester.tap(find.text('Qué miró la IA'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Proponer una comida'), findsOneWidget);
      final review = find.textContaining('Revisar y guardar');
      await tester.ensureVisible(review);
      await tester.pumpAndSettle();
      await tester.tap(review);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('food-kcal')))
            .controller!
            .text,
        '540',
      );
      await tester.tap(find.byKey(const ValueKey('food-save')));
      await tester.pumpAndSettle();
      final saved = d.nutrition.entries.single;
      expect(saved.caloriesSource, CaloriesSource.estimated);
      expect(saved.calories, 540);
    });

    testWidgets('fits 320 px at 200 % with the badge and the guidelines', (
      tester,
    ) async {
      final client = ScriptedClient([_text('Hola, ¿en qué te ayudo?')]);
      await open(tester, client, size: const Size(320, 568), scale: 2);
      await tester.enterText(find.byKey(const ValueKey('chat-input')), 'Hola');
      await tester.tap(find.byKey(const ValueKey('chat-send')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Regression: fixed parts left the conversation one line tall; now it
      // scrolls to the answer, which is on screen.
      final answer = tester.getRect(find.text('Hola, ¿en qué te ayudo?'));
      expect(answer.top, greaterThanOrEqualTo(0));
      expect(answer.bottom, lessThanOrEqualTo(568));
      final handle = tester.ensureSemantics();
      await tester.pump();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  test('the gate checks every proposal again with local data', () {
    final inbox = ProposalInbox(clock: () => _now);
    FoodProposal food(String date, {int kcal = 10, String name = 'x'}) =>
        FoodProposal(
          inbox.newId(),
          _now,
          dateKey: date,
          name: name,
          kcal: kcal,
        );
    expect(ProposalGate.food(food('2026-10-06'), _now), isNull);
    expect(ProposalGate.food(food('2026-12-01'), _now), contains('fecha'));
    expect(ProposalGate.food(food('2026-08-01'), _now), contains('fecha'));
    expect(
      ProposalGate.food(food('2026-10-06', kcal: 9000), _now),
      contains('calorías'),
    );
    expect(
      ProposalGate.food(food('2026-10-06', name: ' '), _now),
      contains('nombre'),
    );
  });
}
