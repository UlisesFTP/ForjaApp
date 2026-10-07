import 'package:flutter/material.dart';

import '../../core/tone_buttons.dart';

/// Changing a finished session reopens it. The person confirms first, and the
/// reopening is recorded in the history.
Future<bool> confirmReopen(BuildContext context) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reabrir la sesión'),
        content: const Text(
          'Esta sesión ya está terminada. Cambiarla la vuelve a poner en curso, '
          'recalcula tus estadísticas y queda anotado en el historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: toneStyle(ActionTone.caution),
            onPressed: () => Navigator.pop(context, true),
            child: const ToneLabel(Icons.lock_open, 'Reabrir y cambiar'),
          ),
        ],
      ),
    ) ??
    false;

/// Asks why something is being skipped. Returns the reason (possibly empty
/// when [required] is false) or null when cancelled.
Future<String?> askSkipReason(
  BuildContext context, {
  required String title,
  bool required = true,
}) => showDialog<String>(
  context: context,
  builder: (context) => _SkipReasonDialog(title: title, required: required),
);

const skipReasons = ['Dolor o molestia', 'Sin equipo', 'Sin tiempo'];

class _SkipReasonDialog extends StatefulWidget {
  const _SkipReasonDialog({required this.title, required this.required});
  final String title;
  final bool required;
  @override
  State<_SkipReasonDialog> createState() => _SkipReasonDialogState();
}

class _SkipReasonDialogState extends State<_SkipReasonDialog> {
  final reason = TextEditingController();
  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final text in skipReasons)
                ActionChip(
                  label: Text(text),
                  onPressed: () => setState(() => reason.text = text),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reason,
            maxLength: 120,
            autofocus: true,
            decoration: InputDecoration(
              labelText: widget.required ? 'Motivo' : 'Motivo (opcional)',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        style: toneStyle(ActionTone.caution),
        onPressed: widget.required && reason.text.trim().isEmpty
            ? null
            : () => Navigator.pop(context, reason.text.trim()),
        child: const ToneLabel(Icons.skip_next, 'Omitir'),
      ),
    ],
  );
}
