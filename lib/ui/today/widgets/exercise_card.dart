import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter/services.dart';

import '../../../core/theme/forja_theme.dart';
import '../../../core/weight_units.dart';
import '../../../domain/models/models.dart';
import '../../core/widgets.dart';

class ExerciseCard extends StatefulWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.log,
    required this.prescription,
    required this.index,
    required this.isNext,
    required this.onToggle,
    required this.onWeight,
    required this.onDetails,
    required this.onMove,
    required this.onSets,
    this.unit = WeightUnit.kg,
    this.busy = false,
    this.canMoveUp = true,
    this.canMoveDown = true,
  });
  final Exercise exercise;
  final ExerciseLog log;
  final Prescription prescription;
  final int index;
  final bool isNext, busy, canMoveUp, canMoveDown;
  final VoidCallback onToggle, onDetails, onSets;
  final WeightUnit unit;
  // Receives kilograms, whatever unit the person typed.
  final Future<bool> Function(double) onWeight;
  final ValueChanged<int> onMove;
  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  late TextEditingController weight;
  final FocusNode weightFocus = FocusNode();
  final FocusNode gripFocus = FocusNode();
  String? error;
  @override
  void initState() {
    super.initState();
    weight = TextEditingController(text: _shown);
    weightFocus.addListener(_onFocus);
  }

  void _onFocus() {
    if (!weightFocus.hasFocus) _save();
  }

  @override
  void didUpdateWidget(ExerciseCard old) {
    super.didUpdateWidget(old);
    if (!weightFocus.hasFocus &&
        (old.log.weightKg != widget.log.weightKg || old.unit != widget.unit)) {
      weight.text = _shown;
    }
  }

  // What the field shows: the stored kilograms in the chosen unit, rounded
  // only for display.
  String get _shown => weightText(widget.log.weightKg, widget.unit);

  Future<void> _save() async {
    // Untouched text is not a change: the displayed value is rounded, so
    // comparing numbers would rewrite a stored weight with its rounded form.
    if (weight.text.trim().replaceAll(',', '.') == _shown) {
      if (error != null) setState(() => error = null);
      return;
    }
    final value = parseWeightKg(weight.text, widget.unit);
    if (value == null || value < 0 || value > 2000) {
      setState(
        () => error =
            'Peso: 0–${weightText(2000, widget.unit)} ${widget.unit.label}',
      );
      return;
    }
    if (widget.busy) return;
    final saved = await widget.onWeight(value);
    if (mounted) {
      setState(() => error = saved ? null : 'No se guardó. Reintenta.');
    }
  }

  @override
  void dispose() {
    weightFocus.removeListener(_onFocus);
    weightFocus.dispose();
    weight.dispose();
    gripFocus.dispose();
    super.dispose();
  }

  // Done, skipped (with the reason) or pending, plus how many sets were
  // recorded; nothing is shown for sets that were never recorded.
  String get _status {
    final log = widget.log, done = log.workSets.length;
    final base = log.completed
        ? 'Completado'
        : log.skipped
        ? 'Omitido: ${log.skipReason ?? ''}'
        : widget.isNext
        ? 'Siguiente'
        : 'Pendiente';
    return done == 0 ? base : '$base · $done ${done == 1 ? 'serie' : 'series'}';
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise, p = widget.prescription;
    final setsButton = IconButton(
      key: ValueKey('sets-${e.id}'),
      tooltip: 'Series de ${e.name}',
      onPressed: widget.onSets,
      icon: const Icon(Icons.format_list_numbered),
    );
    final large = MediaQuery.textScalerOf(context).scale(14) > 20;
    final weightField = SizedBox(
      width: large ? 124 : 88,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: TextField(
          key: ValueKey('weight-${e.id}'),
          controller: weight,
          focusNode: weightFocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _save(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            labelText: 'Peso',
            suffixText: widget.unit.label,
            errorText: error,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
          ),
        ),
      ),
    );
    final grip = FocusableActionDetector(
      focusNode: gripFocus,
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowUp): _MoveIntent(-1),
        SingleActivator(LogicalKeyboardKey.arrowDown): _MoveIntent(1),
      },
      actions: {
        _MoveIntent: CallbackAction<_MoveIntent>(
          onInvoke: (intent) {
            widget.onMove(intent.delta);
            return null;
          },
        ),
      },
      child: Semantics(
        customSemanticsActions: {
          if (widget.canMoveUp)
            CustomSemanticsAction(label: 'Mover arriba'): () =>
                widget.onMove(-1),
          if (widget.canMoveDown)
            CustomSemanticsAction(label: 'Mover abajo'): () => widget.onMove(1),
        },
        child: ReorderableDragStartListener(
          index: widget.index,
          enabled: !widget.busy,
          child: PopupMenuButton<int>(
            tooltip: 'Mover ${e.name}',
            onCanceled: gripFocus.requestFocus,
            onSelected: (delta) {
              gripFocus.requestFocus();
              widget.onMove(delta);
            },
            itemBuilder: (_) => [
              if (widget.canMoveUp)
                const PopupMenuItem(value: -1, child: Text('Mover arriba')),
              if (widget.canMoveDown)
                const PopupMenuItem(value: 1, child: Text('Mover abajo')),
            ],
            icon: const Icon(Icons.drag_indicator, size: 22),
            constraints: const BoxConstraints(minWidth: 160),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SurfaceCard(
        padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Semantics(
                  container: true,
                  onTap: widget.onToggle,
                  label: widget.log.skipped
                      ? 'Completar ${e.name} (omitido)'
                      : '${widget.log.completed ? 'Desmarcar' : 'Completar'} ${e.name}',
                  checked: widget.log.completed,
                  button: true,
                  excludeSemantics: true,
                  child: IconButton(
                    key: ValueKey('complete-${e.id}'),
                    onPressed: widget.onToggle,
                    icon: Icon(
                      widget.log.completed
                          ? Icons.check_circle
                          : widget.log.skipped
                          ? Icons.remove_circle_outline
                          : Icons.radio_button_unchecked,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _status,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ForjaColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                grip,
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: large
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${p.sets} series · ${p.reps} reps · ${p.rir}'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            weightField,
                            const Spacer(),
                            setsButton,
                            IconButton(
                              tooltip: 'Detalles de ${e.name}',
                              onPressed: widget.onDetails,
                              icon: const Icon(Icons.info_outline),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${p.sets} × ${p.reps} · ${p.rir}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: ForjaColors.muted,
                            ),
                          ),
                        ),
                        weightField,
                        setsButton,
                        IconButton(
                          tooltip: 'Detalles de ${e.name}',
                          onPressed: widget.onDetails,
                          icon: const Icon(Icons.info_outline),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoveIntent extends Intent {
  const _MoveIntent(this.delta);
  final int delta;
}
