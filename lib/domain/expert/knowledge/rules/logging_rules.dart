import '../../../models/models.dart';
import '../../engine/rule.dart';
import '../../facts/coach_facts.dart';
import '../../model/recommendation.dart';
import '../evidence.dart';
import '../thresholds.dart';

String _list(List<String> items) => items.length < 2
    ? items.join()
    : '${items.sublist(0, items.length - 1).join(', ')} y ${items.last}';

/// L1 · The progression rules are holding because the effort (RIR) or the
/// technique is missing on several exercises: one combined tip.
class MissingEffort extends ExpertRule {
  const MissingEffort();
  @override
  String get id => 'logging.missing-effort';
  @override
  RuleFamily get family => RuleFamily.logging;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 2;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final from = f.keyDaysAgo(27);
    final affected = [
      for (final s in f.progression.values)
        if (s.kind == ProgressionKind.hold &&
            s.basedOn.compareTo(from) >= 0 &&
            s.missing.any(
              (m) => m.contains('esfuerzo (RIR)') || m.contains('técnica'),
            ))
          s,
    ];
    if (affected.length < Thresholds.missingDataExercises) return const [];
    final names = [for (final s in affected) f.exercise(s.exerciseId).name];
    final latest = (affected.map((s) => s.basedOn).toList()..sort()).last;
    return [
      make(
        subject: 'missing-effort',
        anchor: latest,
        kind: RecommendationKind.info,
        title: 'Falta el esfuerzo o la técnica',
        summary:
            'En ${_list(names)} faltan el RIR o la valoración de la técnica, '
            'así que la progresión no puede evaluarlos. Anótalos en el panel '
            'de series de cada ejercicio.',
        because: [
          for (final s in affected)
            FactRef(
              f.exercise(s.exerciseId).name,
              s.missing.first,
              date: s.basedOn,
            ),
        ],
        threshold: '${Thresholds.missingDataExercises} ejercicios',
      ),
    ];
  }
}

/// L2 · Exercises ticked as done without any set: they count for
/// consistency, not for progression.
class DoneWithoutSets extends ExpertRule {
  const DoneWithoutSets();
  @override
  String get id => 'logging.done-without-sets';
  @override
  RuleFamily get family => RuleFamily.logging;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 1;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final from = f.keyDaysAgo(27);
    final found = [
      for (final s in f.pastSessions)
        if (s.dateKey.compareTo(from) >= 0)
          for (final e in s.exercises)
            if (e.completed && e.workSets.isEmpty) (s.dateKey, e.exerciseId),
    ];
    if (found.length < Thresholds.doneWithoutSets) return const [];
    return [
      make(
        subject: 'done-without-sets',
        anchor: found.last.$1,
        kind: RecommendationKind.info,
        title: 'Ejercicios sin series',
        summary:
            '${found.length} ejercicios marcados como hechos sin series en las '
            'últimas 4 semanas. Cuentan para tu constancia, pero no para la '
            'progresión: anota al menos las series de trabajo.',
        because: [
          for (final (date, id) in found.take(5))
            FactRef('Hecho sin series', f.exercise(id).name, date: date),
        ],
        threshold: '${Thresholds.doneWithoutSets} ejercicios en 4 semanas',
      ),
    ];
  }
}
