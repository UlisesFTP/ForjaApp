import 'dart:convert';

import '../ai_settings.dart';
import 'forja_tools.dart';
import 'mcp_types.dart';

/// FORJA's own tools served as Model Context Protocol (JSON-RPC 2.0) over an
/// in-process transport: `tools/list` and `tools/call`. The app is the host;
/// no external server is reached (D38). Every result is data only, wrapped
/// so the model cannot take it for instructions.
class ForjaMcpServer {
  ForjaMcpServer(this.context);
  final ForjaToolContext context;

  static const _parseError = -32700,
      _invalidRequest = -32600,
      _methodNotFound = -32601,
      _invalidParams = -32602;

  Map<String, Object?> _error(Object? id, int code, String message) => {
    'jsonrpc': '2.0',
    'id': id,
    'error': {'code': code, 'message': message},
  };

  Map<String, Object?> _result(Object? id, Map<String, Object?> result) => {
    'jsonrpc': '2.0',
    'id': id,
    'result': {
      ...result,
      '_meta': {'io.modelcontextprotocol/protocolVersion': mcpProtocolVersion},
    },
  };

  /// Handles one JSON-RPC message given as text.
  Map<String, Object?> handleText(String text) {
    final Object? message;
    try {
      message = jsonDecode(text);
    } on FormatException {
      return _error(null, _parseError, 'Parse error');
    }
    if (message is! Map<String, Object?>) {
      return _error(null, _invalidRequest, 'Invalid Request');
    }
    return handle(message);
  }

  Map<String, Object?> handle(Map<String, Object?> message) {
    final id = message['id'];
    if (message['jsonrpc'] != '2.0' ||
        message['method'] is! String ||
        (id != null && id is! String && id is! int)) {
      return _error(id, _invalidRequest, 'Invalid Request');
    }
    final params = message['params'];
    if (params != null && params is! Map) {
      return _error(id, _invalidParams, 'Invalid params');
    }
    switch (message['method']) {
      case 'tools/list':
        return _result(id, {
          'resultType': 'complete',
          'tools': [for (final t in forjaTools) t.toJson()],
        });
      case 'tools/call':
        final p = (params as Map?) ?? const {};
        final name = p['name'];
        final tool = name is String ? toolNamed(name) : null;
        if (tool == null) return _error(id, _invalidParams, 'Unknown tool');
        final args = p['arguments'] ?? const <String, Object?>{};
        if (args is! Map) {
          return _error(id, _invalidParams, 'Invalid arguments');
        }
        return _result(id, call(tool, Map<String, Object?>.from(args)));
      default:
        return _error(id, _methodNotFound, 'Method not found');
    }
  }

  /// One tool call: a [CallToolResult] as JSON, never an exception. A
  /// category the person did not allow, or wrong arguments, come back as
  /// `isError` so the model can read them and carry on.
  Map<String, Object?> call(McpTool tool, Map<String, Object?> args) {
    final missing = [
      for (final c in tool.categories)
        if (!context.allows(c)) c,
    ];
    if (missing.isNotEmpty) {
      return _wrap({
        'error':
            'La persona no permitió consultar: '
            '${missing.map((c) => c.label.toLowerCase()).join(', ')}.',
      }, isError: true);
    }
    try {
      return _wrap(runForjaTool(tool, args, context));
    } on ToolArgumentError catch (e) {
      return _wrap({'error': e.message}, isError: true);
    }
  }

  Map<String, Object?> _wrap(Object? data, {bool isError = false}) {
    final envelope = {'source': 'forja', 'dataOnly': true, 'data': data};
    var text = jsonEncode(envelope);
    if (text.length > maxToolResultChars) {
      text = jsonEncode({
        'source': 'forja',
        'dataOnly': true,
        'error': 'Resultado demasiado grande: pide un rango más corto.',
      });
      return CallToolResult(structured: null, isError: true).toJson(text);
    }
    return CallToolResult(structured: envelope, isError: isError).toJson(text);
  }
}

/// The categories a tool needs, in words (for the trace).
String categoryNames(Iterable<DataCategory> categories) =>
    categories.map((c) => c.label.toLowerCase()).join(', ');
