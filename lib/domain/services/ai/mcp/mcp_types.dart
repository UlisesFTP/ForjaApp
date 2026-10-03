import '../ai_settings.dart';

/// Protocol version the in-app tools follow (Model Context Protocol).
const mcpProtocolVersion = '2026-07-28';

/// Hints about what a tool does. FORJA defines its own tools, so the host
/// can trust them to decide what needs confirmation.
class ToolAnnotations {
  const ToolAnnotations({
    required this.readOnlyHint,
    this.destructiveHint = false,
    this.idempotentHint = false,
    this.openWorldHint = false,
  });
  final bool readOnlyHint, destructiveHint, idempotentHint, openWorldHint;

  static const read = ToolAnnotations(readOnlyHint: true, idempotentHint: true);
  static const propose = ToolAnnotations(readOnlyHint: false);

  Map<String, Object?> toJson() => {
    'readOnlyHint': readOnlyHint,
    'destructiveHint': destructiveHint,
    'idempotentHint': idempotentHint,
    'openWorldHint': openWorldHint,
  };
}

/// A tool in the shape of an MCP tool.
class McpTool {
  const McpTool({
    required this.name,
    required this.title,
    required this.description,
    required this.inputSchema,
    required this.annotations,
    this.categories = const {},
  });

  /// `^[a-z][a-z_]{0,63}$`: valid for MCP and for MiMo function names.
  final String name;
  final String title, description;

  /// JSON Schema of the arguments (always an object, no extra properties).
  final Map<String, Object?> inputSchema;
  final ToolAnnotations annotations;

  /// What the person must have allowed for the tool to answer.
  final Set<DataCategory> categories;

  Map<String, Object?> toJson() => {
    'name': name,
    'title': title,
    'description': description,
    'inputSchema': inputSchema,
    'annotations': annotations.toJson(),
  };
}

/// What a tool call returns: a text block with the JSON, the structured
/// value, and whether it failed (a failure the model can read and correct).
class CallToolResult {
  const CallToolResult({required this.structured, this.isError = false});
  final Object? structured;
  final bool isError;

  Map<String, Object?> toJson(String text) => {
    'resultType': 'complete',
    'content': [
      {'type': 'text', 'text': text},
    ],
    'structuredContent': structured,
    'isError': isError,
  };
}
