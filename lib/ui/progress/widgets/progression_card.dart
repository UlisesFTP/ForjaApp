import 'package:flutter/material.dart';

import '../../../core/date_utils.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../core/weight_units.dart';
import '../../../domain/models/models.dart';
import '../../../domain/services/progression_engine.dart';
import '../../core/widgets.dart';
import '../view_models/progression_view_model.dart';
import '../../core/tone_buttons.dart';

const progressionTitles = {
  ProgressionKind.increase: 'Sugerencia: subir la carga',
  ProgressionKind.hold: 'Mantener la carga',
  ProgressionKind.review: 'Revisar carga y técnica',
  ProgressionKind.blocked: 'Sin aumento por ahora',
};

/// One exercise's suggestion with its explanation: the sessions used, the
/// rule, what data is missing, and, for an increase, accept or reject. The
/// suggestion is never applied by itself.
class ProgressionCard extends StatelessWidget {
  const ProgressionCard({
    super.key,
    required this.vm,
    required this.suggestion,
    this.showName = true,
  });
  final ProgressionViewModel vm;
  final ProgressionSuggestion suggestion;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final s = suggestion, unit = WeightUnit.kg;
    final decision = vm.decisionFor(s);
    final working = vm.workingWeight(s.exerciseId);
    // A recent injury, pain or a long break holds the increase back (D41c).
    final veto = decision == null ? vm.vetoFor(s) : null;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showName)
            Text(
              vm.exercise(s.exerciseId).name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          Semantics(
            header: true,
            child: Text(
              progressionTitles[s.kind]!,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: ForjaColors.paper,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(s.explanation),
          if (s.missing.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Datos que faltan:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            for (final line in s.missing) Text('• $line'),
          ],
          if (s.sessions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Sesiones usadas: ${s.sessions.map((d) => shortDate(parseDateKey(d))).join(' y ')}.',
              style: const TextStyle(color: ForjaColors.muted),
            ),
          ],
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Cómo se calcula'),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${s.rule}\n\nReglas $progressionRulesVersion: heurística de organización del entrenamiento, no una prescripción médica ni una predicción. Nunca se aplica sola.',
                ),
              ),
            ],
          ),
          if (working != null)
            Text(
              'Carga de trabajo aceptada: ${weightText(working, unit)} ${unit.label}.',
              style: const TextStyle(color: ForjaColors.muted),
            ),
          if (decision != null)
            Text(
              decision.status == DecisionStatus.accepted
                  ? 'Aceptaste este aumento el ${shortDate(decision.decidedAt.toLocal())}.'
                  : 'Rechazaste esta sugerencia el ${shortDate(decision.decidedAt.toLocal())}.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          else if (veto != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Sin aumento: ${veto.reason}',
                key: ValueKey('veto-${s.exerciseId}'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          else if (s.actionable)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    key: ValueKey('accept-${s.exerciseId}'),
                    style: toneStyle(ActionTone.confirm),
                    onPressed: vm.busy ? null : () => vm.accept(s),
                    child: const ToneLabel(
                      Icons.trending_up,
                      'Aceptar aumento',
                    ),
                  ),
                  OutlinedButton(
                    key: ValueKey('reject-${s.exerciseId}'),
                    style: toneStyle(ActionTone.caution),
                    onPressed: vm.busy ? null : () => vm.reject(s),
                    child: const ToneLabel(Icons.close, 'Rechazar'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
