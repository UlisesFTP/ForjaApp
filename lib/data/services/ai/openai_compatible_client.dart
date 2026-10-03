import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException, HandshakeException;
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../../core/app_info.dart';
import '../../../domain/services/ai/ai_client.dart';
import '../../../domain/services/ai/ai_types.dart';

/// Chat completions over HTTPS for OpenAI-compatible providers (OpenCode Go,
/// Xiaomi MiMo, others). It sends exactly what the request holds, identifies
/// itself honestly, never logs bodies or keys, and retries only what is
/// safe: one wait on a short rate limit, one retry on a server or network
/// error. A cancelled request is never retried.
class OpenAiCompatibleClient implements AiChatClient {
  OpenAiCompatibleClient({
    http.Client? client,
    Random? random,
    Future<void> Function(Duration)? wait,
    DateTime Function()? clock,
    this.longestWait = const Duration(seconds: 20),
  }) : _client = client ?? http.Client(),
       _random = random ?? Random(),
       _wait = wait ?? Future<void>.delayed,
       _clock = clock ?? DateTime.now;

  final http.Client _client;
  final Random _random;
  final Future<void> Function(Duration) _wait;
  final DateTime Function() _clock;

  /// A rate limit longer than this is reported, not waited for.
  final Duration longestWait;

  static const userAgent = 'FORJA/$appVersion (app de gimnasio; Flutter)';

  /// The JSON body for [request]; public so tests can check its shape.
  static Map<String, Object?> body(AiRequest request, AiEndpoint endpoint) {
    final caps = endpoint.capabilities;
    return {
      'model': endpoint.model,
      'messages': [for (final m in request.messages) _message(m)],
      'max_completion_tokens': request.maxTokens,
      'temperature': request.temperature,
      'stream': false,
      if (request.tools.isNotEmpty) ...{
        'tools': [
          for (final t in request.tools)
            {
              'type': 'function',
              'function': {
                'name': t.name,
                'description': t.description,
                'parameters': t.parameters,
              },
            },
        ],
        // The only value MiMo accepts.
        'tool_choice': 'auto',
      },
      if (endpoint.preset.disableThinking) 'thinking': {'type': 'disabled'},
      if (request.jsonProbe || (request.json && caps?.jsonMode == true))
        'response_format': {'type': 'json_object'},
    };
  }

  static Map<String, Object?> _message(AiMessage m) => switch (m.role) {
    AiRole.system => {'role': 'system', 'content': m.content ?? ''},
    AiRole.user => {'role': 'user', 'content': m.content ?? ''},
    AiRole.tool => {
      'role': 'tool',
      'tool_call_id': m.toolCallId,
      'content': m.content ?? '',
    },
    AiRole.assistant => {
      'role': 'assistant',
      'content': m.content ?? '',
      if (m.toolCalls.isNotEmpty)
        'tool_calls': [
          for (final c in m.toolCalls)
            {
              'id': c.id,
              'type': 'function',
              'function': {'name': c.name, 'arguments': c.arguments},
            },
        ],
      // MiMo answers 400 if the reasoning of a tool call is not sent back.
      if (m.toolCalls.isNotEmpty && m.reasoning != null)
        'reasoning_content': m.reasoning,
    },
  };

  static Map<String, String> headers(AiEndpoint endpoint) => {
    'Authorization': 'Bearer ${endpoint.apiKey}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': userAgent,
    if (endpoint.preset.sessionHeader && endpoint.sessionId != null)
      'x-opencode-session': endpoint.sessionId!,
  };

  @override
  Future<AiResponse> complete(
    AiRequest request,
    AiEndpoint endpoint, {
    Future<void>? cancel,
  }) async {
    final uri = Uri.tryParse(
      '${endpoint.baseUrl.replaceFirst(RegExp(r'/+$'), '')}/chat/completions',
    );
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw const AiMisconfigured('la dirección debe empezar por https://');
    }
    var cancelled = false;
    unawaited(cancel?.then((_) => cancelled = true));
    final payload = jsonEncode(body(request, endpoint));
    var waitedForLimit = false, retriedError = false;
    while (true) {
      if (cancelled) throw const AiCancelled();
      final started = _clock();
      try {
        return await _once(
          uri,
          payload,
          endpoint,
          request.timeout,
          cancel,
          started,
        );
      } on _RateLimit catch (limit) {
        final delay = limit.delay;
        if (!waitedForLimit && delay != null && delay <= longestWait) {
          waitedForLimit = true;
          await _pause(delay, cancel);
          continue;
        }
        throw AiRateLimited(delay == null ? null : _clock().add(delay));
      } on _Retryable catch (e) {
        if (retriedError || cancelled) throw e.failure;
        retriedError = true;
        await _pause(
          Duration(milliseconds: 1000 + _random.nextInt(1000)),
          cancel,
        );
      }
    }
  }

  Future<void> _pause(Duration d, Future<void>? cancel) async {
    final done = Completer<void>();
    unawaited(_wait(d).then((_) => done.isCompleted ? null : done.complete()));
    unawaited(
      cancel?.then(
        (_) =>
            done.isCompleted ? null : done.completeError(const AiCancelled()),
      ),
    );
    await done.future;
  }

  Future<AiResponse> _once(
    Uri uri,
    String payload,
    AiEndpoint endpoint,
    Duration timeout,
    Future<void>? cancel,
    DateTime started,
  ) async {
    final timedOut = Completer<void>();
    final timer = Timer(timeout, () {
      if (!timedOut.isCompleted) timedOut.complete();
    });
    final stop = Completer<void>();
    void abort() {
      if (!stop.isCompleted) stop.complete();
    }

    unawaited(timedOut.future.then((_) => abort()));
    unawaited(cancel?.then((_) => abort()));
    final request =
        http.AbortableRequest('POST', uri, abortTrigger: stop.future)
          ..headers.addAll(headers(endpoint))
          ..body = payload;
    try {
      // The abort trigger closes the connection where the client supports
      // it; the race makes sure the request ends either way.
      final response = await Future.any([
        _client.send(request).then(http.Response.fromStream),
        stop.future.then<http.Response>(
          (_) => throw timedOut.isCompleted
              ? const AiTimeout()
              : const AiCancelled(),
        ),
      ]);
      return _parse(response, started);
    } on http.RequestAbortedException {
      throw timedOut.isCompleted ? const AiTimeout() : const AiCancelled();
    } on SocketException {
      throw const _Retryable(AiOffline());
    } on HandshakeException {
      throw const _Retryable(AiOffline());
    } on http.ClientException {
      throw const _Retryable(AiOffline());
    } finally {
      timer.cancel();
      abort();
    }
  }

  AiResponse _parse(http.Response r, DateTime started) {
    final status = r.statusCode;
    if (status == 200) {
      final Object? root;
      try {
        root = jsonDecode(utf8.decode(r.bodyBytes));
      } on FormatException {
        throw const AiInvalidOutput();
      }
      return _answer(root, started);
    }
    if (status == 429) throw _RateLimit(_retryAfter(r));
    if (status >= 500) throw const _Retryable(AiServer());
    switch (status) {
      case 401 || 403:
        throw const AiUnauthorized();
      case 402:
        throw const AiQuota();
      case 421:
        throw const AiContentFiltered();
      case 400:
        // OpenCode Go needs a session header; say so instead of a code.
        if (utf8
            .decode(r.bodyBytes, allowMalformed: true)
            .contains('MissingSessionID')) {
          throw const AiMisconfigured('falta la cabecera de sesión');
        }
    }
    throw AiRejected(status);
  }

  Duration? _retryAfter(http.Response r) {
    final ms = int.tryParse(r.headers['retry-after-ms'] ?? '');
    if (ms != null) return Duration(milliseconds: ms);
    final s = int.tryParse(r.headers['retry-after'] ?? '');
    return s == null ? null : Duration(seconds: s);
  }

  AiResponse _answer(Object? root, DateTime started) {
    if (root is! Map<String, dynamic>) throw const AiInvalidOutput();
    final choices = root['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map) {
      throw const AiInvalidOutput();
    }
    final choice = choices.first as Map;
    final m = choice['message'];
    if (m is! Map) throw const AiInvalidOutput();
    final calls = <AiToolCall>[];
    final rawCalls = m['tool_calls'];
    if (rawCalls is List) {
      for (final c in rawCalls) {
        final f = c is Map ? c['function'] : null;
        if (c is! Map || f is! Map || f['name'] is! String) {
          throw const AiInvalidOutput();
        }
        calls.add(
          AiToolCall(
            id: '${c['id'] ?? 'call_${calls.length}'}',
            name: f['name'] as String,
            arguments: f['arguments'] is String
                ? f['arguments'] as String
                : jsonEncode(f['arguments'] ?? {}),
          ),
        );
      }
    }
    final usage = root['usage'];
    int read(Object? map, String key) =>
        map is Map && map[key] is int ? map[key] as int : 0;
    return AiResponse(
      message: AiMessage(
        role: AiRole.assistant,
        content: m['content'] is String ? m['content'] as String : null,
        toolCalls: calls,
        reasoning: m['reasoning_content'] is String
            ? m['reasoning_content'] as String
            : null,
      ),
      usage: AiUsage(
        prompt: read(usage, 'prompt_tokens'),
        completion: read(usage, 'completion_tokens'),
        reasoning: read(
          usage is Map ? usage['completion_tokens_details'] : null,
          'reasoning_tokens',
        ),
        cached: read(
          usage is Map ? usage['prompt_tokens_details'] : null,
          'cached_tokens',
        ),
      ),
      model: root['model'] is String ? root['model'] as String : '',
      latency: _clock().difference(started),
      finishReason: choice['finish_reason'] is String
          ? choice['finish_reason'] as String
          : null,
    );
  }
}

class _RateLimit implements Exception {
  const _RateLimit(this.delay);
  final Duration? delay;
}

class _Retryable implements Exception {
  const _Retryable(this.failure);
  final AiFailure failure;
}
