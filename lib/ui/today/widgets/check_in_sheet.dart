import 'package:flutter/material.dart';

import '../../../domain/models/models.dart';
import '../../../domain/models/labels.dart';
import '../../core/widgets.dart';
import '../view_models/today_view_model.dart';

Future<void> showCheckIn(
  BuildContext context,
  TodayViewModel vm, {
  CheckInPhase phase = CheckInPhase.before,
}) => showForjaSheet<void>(
  context,
  title: phase == CheckInPhase.before
      ? '¿Cómo te sientes?'
      : '¿Cómo te sentiste al terminar?',
  child: _CheckInForm(vm, phase),
);

class _CheckInForm extends StatefulWidget {
  const _CheckInForm(this.vm, this.phase);
  final TodayViewModel vm;
  final CheckInPhase phase;
  @override
  State<_CheckInForm> createState() => _CheckInFormState();
}

class _CheckInFormState extends State<_CheckInForm> {
  late Feeling feeling;
  late TextEditingController note;
  @override
  void initState() {
    super.initState();
    final saved = widget.phase == CheckInPhase.before
        ? widget.vm.checkIn
        : widget.vm.afterCheckIn;
    feeling = saved?.feeling ?? Feeling.normal;
    note = TextEditingController(text: saved?.note ?? '');
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.vm,
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...Feeling.values.map(
          (f) => Semantics(
            selected: f == feeling,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(feelingLabels[f]!),
              trailing: Icon(
                f == feeling
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: widget.vm.busy ? null : () => setState(() => feeling = f),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: note,
          minLines: 2,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(labelText: 'Nota (opcional)'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: widget.vm.busy
              ? null
              : () async {
                  if (await widget.vm.saveCheckIn(
                        CheckIn(feeling: feeling, note: note.text.trim()),
                        phase: widget.phase,
                      ) &&
                      context.mounted) {
                    Navigator.pop(context);
                  }
                },
          child: Text(widget.vm.busy ? 'Guardando…' : 'Guardar check-in'),
        ),
        if (widget.vm.error != null)
          Semantics(liveRegion: true, child: Text(widget.vm.error!)),
      ],
    ),
  );
}
