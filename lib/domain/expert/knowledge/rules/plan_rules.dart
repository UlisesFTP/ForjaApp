import '../../../../core/date_utils.dart';
import '../../../models/labels.dart';
import '../../../models/models.dart';
import '../../engine/rule.dart';
import '../../facts/coach_facts.dart';
import '../../model/coach_action.dart';
import '../../model/recommendation.dart';
import '../evidence.dart';
import '../muscle_map.dart';
import '../thresholds.dart';

String _sets(double v) => v == v.roundToDouble()
    ? '${v.toInt()}'
    : v.toStringAsFixed(1).replaceAll('.', ',');

String _list(List<String> items) => items.length < 2
    ? items.join()
    : '${items.sublist(0, items.length - 1).join(', ')} y ${items.last}';

/// The plan's own numbers only mean something once the plan is the person's,
/// or the example plan of someone who finished the setup.
bool _planIsTheirs(CoachFacts f) =>
    f.inputs.plan.source != PlanSource.example || f.profile.onboarded;

/// V2 · A major muscle under 4 sets a week with a strength or muscle goal.
class LowVolume extends ExpertRule {
  const LowVolume();
  @override
  String get id => 'plan.low-volume';
  @override
  RuleFamily get family => RuleFamily.plan;
  @override
  Evidence get evidence => const Evidence(
    EvidenceLevel.heuristic,
    '${Sources.schoenfeld2017} El mínimo de 4 series es un umbral de FORJA.',
  );
  @override
  int get specificity => 3;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    if (!_planIsTheirs(f) || f.profile.goal == TrainingGoal.fitness) {
      return const [];
    }
    final low = [
      for (final m in Muscle.values)
        if (m.major && (f.weeklySets[m] ?? 0) < Thresholds.minWeeklySets) m,
    ];
    if (low.isEmpty) return const [];
    final described = [
      for (final m in low) '${m.label} ${_sets(f.weeklySets[m] ?? 0)}',
    ];
    return [
      make(
        subject: 'volume',
        anchor: f.inputs.plan.id,
        kind: RecommendationKind.suggestion,
        title: 'Pocas series para tu objetivo',
        summary:
            'Series por semana en tu plan: ${_list(described)}. Para '
            '${goalLabels[f.profile.goal]!.toLowerCase()} suele recomendarse '
            'al menos ${Thresholds.minWeeklySets} por grupo; puedes añadir '
            '1–2 series en el editor.',
        because: [
          for (final m in low)
            FactRef(
              'Series semanales de ${m.label}',
              _sets(f.weeklySets[m] ?? 0),
            ),
          FactRef('Objetivo', goalLabels[f.profile.goal]!),
        ],
        threshold: '${Thresholds.minWeeklySets} series por semana',
        action: const AddVolume(),
      ),
    ];
  }
}

/// V3 · More than 20 sets a week for a muscle while fatigue shows: trim.
class HighVolume extends ExpertRule {
  const HighVolume();
  @override
  String get id => 'plan.high-volume';
  @override
  RuleFamily get family => RuleFamily.plan;
  @override
  Evidence get evidence => const Evidence(
    EvidenceLevel.heuristic,
    '${Sources.schoenfeld2017} El tope de 20 series es un umbral de FORJA.',
  );
  @override
  int get specificity => 4;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final high = [
      for (final m in Muscle.values)
        if ((f.weeklySets[m] ?? 0) > Thresholds.maxWeeklySets) m,
    ];
    if (high.isEmpty) return const [];
    final tired = f.datesFeeling(Feeling.tired, Thresholds.deloadWindowDays);
    final doms = f.datesFeeling(Feeling.doms, Thresholds.deloadWindowDays);
    if (tired.length < Thresholds.fatigueDays &&
        doms.length < Thresholds.fatigueDays) {
      return const [];
    }
    return [
      make(
        subject: 'volume-high',
        anchor: f.inputs.plan.id,
        kind: RecommendationKind.suggestion,
        title: 'Mucho volumen con fatiga',
        summary:
            '${_list([for (final m in high) '${m.label} (${_sets(f.weeklySets[m]!)} series)'])} '
            'superan ${Thresholds.maxWeeklySets} series por semana y hay '
            'señales de fatiga. Quitar alguna serie puede ayudarte a '
            'recuperar.',
        because: [
          for (final m in high)
            FactRef('Series semanales de ${m.label}', _sets(f.weeklySets[m]!)),
          if (tired.length >= Thresholds.fatigueDays)
            FactRef('Días con cansancio', '${tired.length}', date: tired.last),
          if (doms.length >= Thresholds.fatigueDays)
            FactRef('Días con DOMS', '${doms.length}', date: doms.last),
        ],
        threshold: '${Thresholds.maxWeeklySets} series por semana',
        action: const OpenPlanEditor(),
      ),
    ];
  }
}

/// V4 · With a muscle goal, a major muscle trained on a single day a week.
class Frequency extends ExpertRule {
  const Frequency();
  @override
  String get id => 'plan.frequency';
  @override
  RuleFamily get family => RuleFamily.plan;
  @override
  Evidence get evidence =>
      const Evidence(EvidenceLevel.moderate, Sources.schoenfeld2016);
  @override
  int get specificity => 3;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    if (!_planIsTheirs(f) || f.profile.goal != TrainingGoal.muscle) {
      return const [];
    }
    final once = [
      for (final m in Muscle.values)
        if (m.major && f.weeklyDays[m] == 1) m,
    ];
    if (once.isEmpty) return const [];
    return [
      make(
        subject: 'frequency',
        anchor: f.inputs.plan.id,
        kind: RecommendationKind.info,
        title: 'Grupos un solo día por semana',
        summary:
            'En tu plan, ${_list([for (final m in once) m.label])} se trabajan '
            'un solo día por semana. Para ganar músculo suele ir mejor '
            'repartir cada grupo en al menos dos días.',
        because: [
          for (final m in once) FactRef('Días por semana de ${m.label}', '1'),
        ],
        threshold: '2 días por grupo',
        action: const OpenPlanEditor(),
      ),
    ];
  }
}

/// G1 · A routine longer than the chosen session length (+15 min).
class RoutineTooLong extends ExpertRule {
  const RoutineTooLong();
  @override
  String get id => 'plan.too-long';
  @override
  RuleFamily get family => RuleFamily.plan;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 2;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) sync* {
    if (!_planIsTheirs(f)) return;
    final limit = f.profile.sessionMinutes + Thresholds.extraMinutes;
    final seen = <String>{};
    for (final day in f.inputs.plan.days) {
      final r = day.routine;
      if (!seen.add(r.id)) continue;
      final minutes = f.routineMinutes(r);
      if (minutes <= limit) continue;
      yield make(
        subject: r.id,
        anchor: f.inputs.plan.id,
        kind: RecommendationKind.suggestion,
        title: '${r.name}: sesión larga',
        summary:
            'La rutina ${r.name} dura unos $minutes min y elegiste sesiones '
            'de ${f.profile.sessionMinutes} min. Puedes quitar algún ejercicio '
            'o serie en el editor.',
        because: [
          FactRef('Duración estimada de ${r.name}', '$minutes min'),
          FactRef('Duración elegida', '${f.profile.sessionMinutes} min'),
        ],
        threshold: '${Thresholds.extraMinutes} min de margen',
        action: const OpenPlanEditor(),
      );
    }
  }
}

/// G2 · An exercise of the plan needs equipment the person did not mark.
class MissingEquipment extends ExpertRule {
  const MissingEquipment();
  @override
  String get id => 'plan.missing-equipment';
  @override
  RuleFamily get family => RuleFamily.plan;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 2;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) sync* {
    if (!f.profile.onboarded) return;
    final seen = <String>{};
    for (final day in f.inputs.plan.days) {
      for (final e in day.routine.exercises) {
        if (!seen.add(e.exerciseId)) continue;
        final exercise = f.exercise(e.exerciseId);
        if (exercise.archived ||
            f.profile.equipment.contains(exercise.equipment)) {
          continue;
        }
        yield make(
          subject: e.exerciseId,
          anchor: f.inputs.plan.id,
          kind: RecommendationKind.suggestion,
          title: '${exercise.name}: falta equipo',
          summary:
              '${exercise.name} necesita '
              '${equipmentLabels[exercise.equipment]!.toLowerCase()}, que no '
              'marcaste en tu perfil. Hay alternativas compatibles con tu '
              'equipo.',
          because: [
            FactRef(
              'Equipo del ejercicio',
              equipmentLabels[exercise.equipment]!,
            ),
            FactRef(
              'Tu equipo',
              [
                for (final q in Equipment.values)
                  if (f.profile.equipment.contains(q)) equipmentLabels[q]!,
              ].join(', '),
            ),
          ],
          action: OpenAlternatives(e.exerciseId),
        );
      }
    }
  }
}

/// G3 · A plan draft left unreviewed for 3 days or more.
class DraftPending extends ExpertRule {
  const DraftPending();
  @override
  String get id => 'plan.draft-pending';
  @override
  RuleFamily get family => RuleFamily.plan;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 1;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final draft = f.inputs.draft;
    if (draft == null || draft.status != PlanStatus.draft) return const [];
    final created = dateKey(draft.createdAt.toLocal());
    if (f.daysAgo(created) < Thresholds.draftReviewDays) return const [];
    return [
      make(
        subject: 'draft',
        anchor: draft.id,
        kind: RecommendationKind.info,
        title: 'Borrador de plan sin revisar',
        summary:
            'Tienes un borrador de plan del ${shortDate(parseDateKey(created))} '
            'sin revisar. En Plan puedes aceptarlo con su fecha de inicio o '
            'descartarlo.',
        because: [FactRef('Borrador creado', draft.name, date: created)],
        threshold: '${Thresholds.draftReviewDays} días',
        action: const OpenPlanEditor(),
      ),
    ];
  }
}

/// G4 · Why the example plan looks the way it does.
class ExampleAdapted extends ExpertRule {
  const ExampleAdapted();
  @override
  String get id => 'plan.example-adapted';
  @override
  RuleFamily get family => RuleFamily.plan;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 1;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    if (f.inputs.plan.source != PlanSource.example) return const [];
    final p = f.profile;
    final changes = [
      if (p.experience == Experience.beginner)
        '2 series por ejercicio y 3 repeticiones en reserva',
      if (p.goal == TrainingGoal.muscle) 'rangos de 8–12 repeticiones',
      if (p.goal == TrainingGoal.fitness) 'rangos de 12–15 repeticiones',
    ];
    return [
      make(
        subject: 'example-plan',
        anchor: '${p.experience.name}-${p.goal.name}',
        kind: RecommendationKind.info,
        title: 'Usas el plan de ejemplo',
        summary: changes.isEmpty
            ? 'Usas el plan de ejemplo de FORJA tal como está. Puedes generar '
                  'un plan con tus días, tu equipo y tu tiempo en Plan.'
            : 'Usas el plan de ejemplo de FORJA, adaptado a tu perfil: '
                  '${_list(changes)}. Puedes generar un plan con tus días, tu '
                  'equipo y tu tiempo en Plan.',
        because: [
          FactRef('Experiencia', experienceLabels[p.experience]!),
          FactRef('Objetivo', goalLabels[p.goal]!),
        ],
        action: const OpenPlanEditor(),
      ),
    ];
  }
}
