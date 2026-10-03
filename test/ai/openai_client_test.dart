import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/services/ai/openai_compatible_client.dart';
import 'package:forja_app/domain/services/ai/ai_client.dart';
import 'package:forja_app/domain/services/ai/ai_settings.dart';
import 'package:forja_app/domain/services/ai/ai_types.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _key = 'sk-test-key-0000000000';

AiEndpoint _endpoint({
  AiProvider provider = AiProvider.opencodeGo,
  String? baseUrl,
  String? session = 'ses_0123456789abcdef0123456789abcdef',
  AiCapabilities? capabilities,
}) {
  final preset = aiPresets[provider]!;
  return AiEndpoint(
    baseUrl:
        baseUrl ??
        (preset.baseUrl.isEmpty ? 'https://example.com/v1' : preset.baseUrl),
    model: 'mimo-v2.6-flash',
    apiKey: _key,
    preset: preset,
    sessionId: session,
    capabilities: capabilities,
  );
}

String _ok({
  String content = 'hola',
  List<Map<String, Object?>>? toolCalls,
  String? reasoning,
}) => jsonEncode({
  'model': 'mimo-v2.6-flash',
  'choices': [
    {
      'finish_reason': toolCalls == null ? 'stop' : 'tool_calls',
      'message': {
        'role': 'assistant',
        'content': toolCalls == null ? content : null,
        'reasoning_content': ?reasoning,
        'tool_calls': ?toolCalls,
      },
    },
  ],
  'usage': {
    'prompt_tokens': 120,
    'completion_tokens': 30,
    'completion_tokens_details': {'reasoning_tokens': 4},
    'prompt_tokens_details': {'cached_tokens': 60},
  },
});

void main() {
  late List<http.Request> seen;
  late List<http.Response Function(http.Request)> answers;
  late List<Duration> waits;

  OpenAiCompatibleClient client() => OpenAiCompatibleClient(
    client: MockClient((request) async {
      seen.add(request);
      final next = answers.isEmpty
          ? (http.Request _) => http.Response(_ok(), 200)
          : answers.removeAt(0);
      return next(request);
    }),
    wait: (d) async => waits.add(d),
  );

  setUp(() {
    seen = [];
    answers = [];
    waits = [];
  });

  const request = AiRequest(
    messages: [AiMessage.system('Eres un coach.'), AiMessage.user('Hola')],
    maxTokens: 900,
  );

  group('request shape (F17)', () {
    test('OpenCode Go: path, honest headers, session, no thinking, a token '
        'limit', () async {
      final r = await client().complete(request, _endpoint());
      final sent = seen.single;
      expect(
        sent.url.toString(),
        'https://opencode.ai/zen/go/v1/chat/completions',
      );
      expect(sent.headers['Authorization'], 'Bearer $_key');
      expect(sent.headers['User-Agent'], startsWith('FORJA/'));
      expect(sent.headers['User-Agent'], isNot(contains('Dart')));
      expect(
        sent.headers['x-opencode-session'],
        'ses_0123456789abcdef0123456789abcdef',
      );
      final body = jsonDecode(sent.body) as Map<String, dynamic>;
      expect(body['model'], 'mimo-v2.6-flash');
      expect(body['max_completion_tokens'], 900);
      expect(body['stream'], isFalse);
      expect(body['thinking'], {'type': 'disabled'});
      expect(body.containsKey('tools'), isFalse);
      expect(body.containsKey('response_format'), isFalse);
      expect(body['messages'], [
        {'role': 'system', 'content': 'Eres un coach.'},
        {'role': 'user', 'content': 'Hola'},
      ]);
      expect(r.message.content, 'hola');
      expect(r.usage.prompt, 120);
      expect(r.usage.completion, 30);
      expect(r.usage.reasoning, 4);
      expect(r.usage.cached, 60);
      expect(r.model, 'mimo-v2.6-flash');
    });

    test('Xiaomi and custom: no OpenCode session header; custom sends no '
        'thinking field', () async {
      await client().complete(request, _endpoint(provider: AiProvider.xiaomi));
      expect(seen.last.headers.containsKey('x-opencode-session'), isFalse);
      expect(jsonDecode(seen.last.body)['thinking'], {'type': 'disabled'});
      await client().complete(request, _endpoint(provider: AiProvider.custom));
      expect(seen.last.headers.containsKey('x-opencode-session'), isFalse);
      expect(
        (jsonDecode(seen.last.body) as Map).containsKey('thinking'),
        isFalse,
      );
    });

    test('tools go as functions with tool_choice auto; JSON mode only once '
        'confirmed (or probed)', () async {
      const withTools = AiRequest(
        messages: [AiMessage.user('Hola')],
        maxTokens: 100,
        json: true,
        tools: [
          AiFunction(
            name: 'get_profile',
            description: 'Perfil',
            parameters: {'type': 'object', 'properties': {}},
          ),
        ],
      );
      await client().complete(withTools, _endpoint());
      var body = jsonDecode(seen.last.body) as Map<String, dynamic>;
      expect(body['tool_choice'], 'auto');
      expect(body['tools'], [
        {
          'type': 'function',
          'function': {
            'name': 'get_profile',
            'description': 'Perfil',
            'parameters': {'type': 'object', 'properties': {}},
          },
        },
      ]);
      expect(
        body.containsKey('response_format'),
        isFalse,
        reason: 'unconfirmed',
      );
      await client().complete(
        withTools,
        _endpoint(capabilities: const AiCapabilities(jsonMode: true)),
      );
      body = jsonDecode(seen.last.body) as Map<String, dynamic>;
      expect(body['response_format'], {'type': 'json_object'});
    });

    test('a tool call comes back, and goes back with its reasoning', () async {
      answers.add(
        (_) => http.Response(
          _ok(
            reasoning: 'pienso',
            toolCalls: [
              {
                'id': 'call_1',
                'type': 'function',
                'function': {'name': 'get_profile', 'arguments': '{"a":1}'},
              },
            ],
          ),
          200,
        ),
      );
      final r = await client().complete(request, _endpoint());
      final call = r.message.toolCalls.single;
      expect(
        [call.id, call.name, call.arguments],
        ['call_1', 'get_profile', '{"a":1}'],
      );
      expect(r.message.reasoning, 'pienso');
      await client().complete(
        AiRequest(
          messages: [
            const AiMessage.user('Hola'),
            r.message,
            const AiMessage.tool('call_1', '{"data":1}'),
          ],
          maxTokens: 100,
        ),
        _endpoint(),
      );
      final messages = (jsonDecode(seen.last.body) as Map)['messages'] as List;
      expect(messages[1], {
        'role': 'assistant',
        'content': '',
        'tool_calls': [
          {
            'id': 'call_1',
            'type': 'function',
            'function': {'name': 'get_profile', 'arguments': '{"a":1}'},
          },
        ],
        'reasoning_content': 'pienso',
      });
      expect(messages[2], {
        'role': 'tool',
        'tool_call_id': 'call_1',
        'content': '{"data":1}',
      });
    });

    test('only https', () async {
      await expectLater(
        client().complete(
          request,
          _endpoint(baseUrl: 'http://opencode.ai/zen/go/v1'),
        ),
        throwsA(isA<AiMisconfigured>()),
      );
      expect(seen, isEmpty);
    });
  });

  group('errors and retries', () {
    Future<Object> failure(
      List<http.Response Function(http.Request)> list,
    ) async {
      answers = list;
      try {
        await client().complete(request, _endpoint());
      } catch (e) {
        return e;
      }
      fail('no failure');
    }

    test('each status says what happened, and only safe cases retry', () async {
      expect(
        await failure([(_) => http.Response('{}', 401)]),
        isA<AiUnauthorized>(),
      );
      expect(
        await failure([(_) => http.Response('{}', 403)]),
        isA<AiUnauthorized>(),
      );
      expect(await failure([(_) => http.Response('{}', 402)]), isA<AiQuota>());
      expect(
        await failure([(_) => http.Response('{}', 421)]),
        isA<AiContentFiltered>(),
      );
      expect(
        await failure([
          (_) => http.Response(
            '{"type":"error","error":{"type":"MissingSessionID"}}',
            400,
          ),
        ]),
        isA<AiMisconfigured>(),
      );
      expect(
        await failure([(_) => http.Response('{}', 404)]),
        isA<AiRejected>(),
      );
      expect(seen, hasLength(6), reason: 'none of these is retried');
      expect(waits, isEmpty);
    });

    test('a short rate limit is waited once; a long one is reported', () async {
      answers = [
        (_) => http.Response('{}', 429, headers: {'retry-after-ms': '1500'}),
      ];
      final r = await client().complete(request, _endpoint());
      expect(r.message.content, 'hola');
      expect(waits, [const Duration(milliseconds: 1500)]);
      final long = await failure([
        (_) => http.Response('{}', 429, headers: {'retry-after': '3600'}),
      ]);
      expect(long, isA<AiRateLimited>());
      expect((long as AiRateLimited).retryAt, isNotNull);
      expect(long.message, contains('prueba a las'));
    });

    test('a server or network error is retried once', () async {
      answers = [(_) => http.Response('{}', 503)];
      expect(
        (await client().complete(request, _endpoint())).message.content,
        'hola',
      );
      expect(seen, hasLength(2));
      expect(
        await failure([
          (_) => http.Response('{}', 500),
          (_) => http.Response('{}', 502),
        ]),
        isA<AiServer>(),
      );
      expect(
        await failure([
          (_) => throw const SocketException('sin red'),
          (_) => throw const SocketException('sin red'),
        ]),
        isA<AiOffline>(),
      );
    });

    test('an answer that is not the expected JSON is invalid output', () async {
      expect(
        await failure([(_) => http.Response('<html>', 200)]),
        isA<AiInvalidOutput>(),
      );
      expect(
        await failure([(_) => http.Response('{"choices":[]}', 200)]),
        isA<AiInvalidOutput>(),
      );
    });

    test('stopping ends it at once and is never retried', () async {
      final gate = Completer<void>();
      final slow = OpenAiCompatibleClient(
        client: MockClient((request) async {
          seen.add(request);
          await gate.future;
          return http.Response(_ok(), 200);
        }),
        wait: (d) async => waits.add(d),
      );
      final stop = Completer<void>();
      final future = slow.complete(request, _endpoint(), cancel: stop.future);
      await Future<void>.delayed(Duration.zero);
      stop.complete();
      await expectLater(future, throwsA(isA<AiCancelled>()));
      gate.complete();
      expect(seen, hasLength(1));
    });

    test('a failure never carries the key or the body', () async {
      final e = await failure([
        (_) => http.Response('{"secret":"$_key"}', 401),
      ]);
      expect(e.toString(), isNot(contains(_key)));
      expect((e as AiFailure).message, isNot(contains(_key)));
    });
  });
}
