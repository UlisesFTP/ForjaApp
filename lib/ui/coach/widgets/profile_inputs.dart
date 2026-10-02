import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../domain/models/labels.dart';
import '../../../domain/models/models.dart';

/// Exactly three weekdays, chosen with toggle chips (never color alone: the
/// selected state also shows a check).
class TrainingDaysPicker extends StatelessWidget {
  const TrainingDaysPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });
  final List<int> selected;
  final ValueChanged<List<int>> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var day = DateTime.monday; day <= DateTime.sunday; day++)
            FilterChip(
              label: Text(weekdayNames[day - 1]),
              selected: selected.contains(day),
              materialTapTargetSize: MaterialTapTargetSize.padded,
              onSelected: !enabled
                  ? null
                  : (on) {
                      final next = [...selected];
                      if (on) {
                        if (next.length < 3) next.add(day);
                      } else {
                        next.remove(day);
                      }
                      onChanged(next..sort());
                    },
            ),
        ],
      ),
      const SizedBox(height: 8),
      Semantics(
        liveRegion: true,
        child: Text(
          selected.length == 3
              ? 'Tres días elegidos. El resto son de descanso.'
              : 'Elige ${3 - selected.length} día${3 - selected.length == 1 ? '' : 's'} más (exactamente tres).',
        ),
      ),
    ],
  );
}

/// Equipment the person can use. Body weight is always available.
class EquipmentPicker extends StatelessWidget {
  const EquipmentPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });
  final Set<Equipment> selected;
  final ValueChanged<Set<Equipment>> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final e in Equipment.values)
        FilterChip(
          label: Text(equipmentLabels[e]!),
          selected: selected.contains(e) || e == Equipment.bodyweight,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onSelected: !enabled || e == Equipment.bodyweight
              ? null
              : (on) =>
                    onChanged({...selected.where((x) => x != e), if (on) e}),
        ),
    ],
  );
}

const sessionMinuteOptions = [30, 45, 60, 75, 90];

class SessionMinutesPicker extends StatelessWidget {
  const SessionMinutesPicker({
    super.key,
    required this.minutes,
    required this.onChanged,
    this.enabled = true,
  });
  final int minutes;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final m in sessionMinuteOptions)
        ChoiceChip(
          label: Text('$m min'),
          selected: minutes == m,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          onSelected: enabled ? (_) => onChanged(m) : null,
        ),
    ],
  );
}

/// Optional body data: empty means unknown, which is fine.
String? optionalWeightError(String? text) {
  final value = (text ?? '').trim();
  if (value.isEmpty) return null;
  final number = double.tryParse(value.replaceAll(',', '.'));
  return number == null || number < 25 || number > 300
      ? 'Introduce un peso entre 25 y 300 kg, o déjalo vacío'
      : null;
}

String? optionalAgeError(String? text) {
  final value = (text ?? '').trim();
  if (value.isEmpty) return null;
  final number = int.tryParse(value);
  return number == null || number < 14 || number > 100
      ? 'Introduce una edad entre 14 y 100 años, o déjala vacía'
      : null;
}

double? parseOptionalWeight(String text) =>
    text.trim().isEmpty ? null : double.parse(text.trim().replaceAll(',', '.'));
int? parseOptionalAge(String text) =>
    text.trim().isEmpty ? null : int.parse(text.trim());
