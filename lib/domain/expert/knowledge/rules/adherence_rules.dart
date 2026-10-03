import '../../../../core/date_utils.dart';
import '../../../models/models.dart';
import '../../engine/rule.dart';
import '../../facts/coach_facts.dart';
import '../../model/coach_action.dart';
import '../../model/recommendation.dart';
import '../evidence.dart';
import '../thresholds.dart';

/// A1 · A planned day of the last week with nothing recorded: mark it or
/// move it. Days before the person started are not held against them.
class Unrecorded extends ExpertRule {
  const Unrecorded();
  @override
  String get id => 'adherence.unrecorded';
  @override
  RuleFamily get family => RuleFamily.adherence;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 3;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) sync* {
    final start = f.trackingStart;
    if (start == null) return;
    for (var i = 1; i <= Thresholds.unrecordedDays; i++) {
      final key = f.keyDaysAgo(i);
      if (key.compareTo(start) < 0 || f.movedSources.contains(key)) continue;
      final routine = f.inputs.routineOn(parseDateKey(key));
      if (routine == null) continue;
      final s = f.sessionOn(key);
      if (s != null &&
          (CoachFacts.hasActivity(s) || s.status == SessionStatus.missed)) {
        continue;
      }
      yield make(
        subject: key,
        anchor: key,
        kind: RecommendationKind.suggestion,
        title: 'Día sin registrar',
        summary:
            'El ${friendlyDate(parseDateKey(key)).toLowerCase()} tocaba '
            '${routine.name} y no hay registro. Márcalo como hecho o como '
            'falta, o muévelo a otro día.',
        because: [FactRef('Día planificado', routine.name, date: key)],
        threshold: 'últimos ${Thresholds.unrecordedDays} días',
        action: OpenDay(key),
      );
    }
  }
}

/// A2 · Under 60 % of the planned sessions in each of the last two weeks:
/// shorter sessions or other days, through the review. Never "catch up".
class LowAdherence extends ExpertRule {
  const LowAdherence();
  @override
  String get id => 'adherence.low';
  @override
  RuleFamily get family => RuleFamily.adherence;
  @override
  Evidence get evidence => const Evidence(
    EvidenceLevel.heuristic,
    '${Sources.lally2010} El umbral del 60 % es de FORJA.',
  );
  @override
  int get specificity => 2;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final weeks = [weekOf(nextDay(f.today, -14)), weekOf(nextDay(f.today, -7))];
    final results = [for (final w in weeks) f.compliance(w.first, w.last)];
    if (results.any(
      (c) =>
          c.due < 2 || c.ratio == null || c.ratio! >= Thresholds.lowAdherence,
    )) {
      return const [];
    }
    return [
      make(
        subject: 'adherence',
        anchor: dateKey(weeks.last.first),
        kind: RecommendationKind.suggestion,
        title: 'Plan difícil de cumplir',
        summary:
            'En las dos últimas semanas completaste ${results[0].fraction} y '
            '${results[1].fraction} de las sesiones previstas. Quizá te '
            'encajen mejor sesiones más cortas u otros días; puedes cambiarlo '
            'en la revisión del minicoach. No hace falta recuperar lo que '
            'faltó.',
        because: [
          for (var i = 0; i < 2; i++)
            FactRef(
              'Semana del ${shortDate(weeks[i].first)}',
              '${results[i].fraction} completadas',
              date: dateKey(weeks[i].first),
            ),
        ],
        threshold: '60 % dos semanas seguidas',
        action: const OpenReview(),
      ),
    ];
  }
}
