import '../../../../core/date_utils.dart';
import '../../../models/models.dart';
import '../../../services/progression_engine.dart';
import '../../engine/rule.dart';
import '../../facts/coach_facts.dart';
import '../../model/coach_action.dart';
import '../../model/recommendation.dart';
import '../evidence.dart';
import '../thresholds.dart';

String _kg(double v) => '${weightLabel(v)} kg';

/// P1 · The progression rules, unchanged: an increase becomes a suggestion
/// the person can accept (the same decision as on Progreso), two sessions
/// below the minimum become a caution. Undecided suggestions only: what was
/// decided stays decided.
class ProgressionRules extends ExpertRule {
  const ProgressionRules();
  @override
  String get id => 'progression.prog';
  @override
  RuleFamily get family => RuleFamily.progression;
  @override
  Evidence get evidence =>
      const Evidence(EvidenceLevel.heuristic, Sources.prog);
  @override
  int get specificity => 4;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) sync* {
    for (final s in f.progression.values) {
      if (s.kind != ProgressionKind.increase &&
          s.kind != ProgressionKind.review) {
        continue;
      }
      if (f.decisionAbout(s) != null) continue;
      final name = f.exercise(s.exerciseId).name;
      final because = [
        for (final d in s.sessions) FactRef('Sesión usada', name, date: d),
        const FactRef('Reglas', progressionRulesVersion),
      ];
      if (s.kind == ProgressionKind.increase) {
        yield make(
          subject: s.exerciseId,
          anchor: s.basedOn,
          kind: RecommendationKind.suggestion,
          title: '$name: subir la carga',
          summary: s.explanation,
          because: because,
          threshold: 'Dos sesiones seguidas en el tope del rango',
          action: IncreaseLoad(
            exercise: s.exerciseId,
            basedOn: s.basedOn,
            fromKg: s.fromKg!,
            toKg: s.toKg!,
          ),
        );
      } else {
        yield make(
          subject: s.exerciseId,
          anchor: s.basedOn,
          kind: RecommendationKind.caution,
          title: '$name: revisar carga y técnica',
          summary: s.explanation,
          because: because,
          threshold: 'Dos sesiones por debajo del mínimo de repeticiones',
          action: OpenAlternatives(s.exerciseId),
        );
      }
    }
  }
}

/// P2 · A suggested step of more than 10 % of the load: try adding reps
/// first, or use a smaller increment.
class BigStep extends ExpertRule {
  const BigStep();
  @override
  String get id => 'progression.big-step';
  @override
  RuleFamily get family => RuleFamily.progression;
  @override
  Evidence get evidence =>
      const Evidence(EvidenceLevel.moderate, Sources.acsm2009);
  @override
  int get specificity => 5;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) sync* {
    for (final s in f.progression.values) {
      if (s.kind != ProgressionKind.increase || f.decisionAbout(s) != null) {
        continue;
      }
      final from = s.fromKg!, to = s.toKg!;
      if (from <= 0 || (to - from) / from <= Thresholds.bigStepShare) continue;
      final name = f.exercise(s.exerciseId).name;
      yield make(
        subject: s.exerciseId,
        anchor: s.basedOn,
        kind: RecommendationKind.caution,
        title: '$name: subida grande',
        summary:
            'La subida sugerida (${_kg(to - from)}) es más del 10 % de tu '
            'carga actual (${_kg(from)}). Antes de subir puedes sumar '
            'repeticiones dentro del rango, o poner un incremento menor en el '
            'plan si tu equipo lo permite.',
        because: [
          FactRef('Carga actual', _kg(from), date: s.basedOn),
          FactRef('Incremento del plan', _kg(to - from)),
        ],
        threshold: '10 % de la carga',
        action: const OpenPlanEditor(),
      );
    }
  }
}

/// P3 · Bodyweight or timed exercises: the top of the range with the target
/// reserve in the last two sessions suggests making them harder (more reps
/// or seconds, or one more set) in the editor. A missing RIR never counts.
class BodyweightReps extends ExpertRule {
  const BodyweightReps();
  @override
  String get id => 'progression.reps-bodyweight';
  @override
  RuleFamily get family => RuleFamily.progression;
  @override
  Evidence get evidence => const Evidence(
    EvidenceLevel.heuristic,
    '${Sources.acsm2009} Doble progresión aplicada a repeticiones o tiempo.',
  );
  @override
  int get specificity => 5;

  static bool _unfit(Feeling? f) =>
      f == Feeling.injured || f == Feeling.tired || f == Feeling.doms;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) sync* {
    for (final id in f.progression.keys) {
      final exercise = f.exercise(id);
      if (exercise.loadType == LoadType.external) continue;
      final done = f.completedExposures(id);
      if (done.length < 2) continue;
      final used = done.sublist(done.length - 2);
      final planned = f.plannedFor(id);
      final reached = used.every(
        (e) =>
            !_unfit(e.feeling) &&
            e.log.technique != TechniqueRating.unstable &&
            e.log.workSets.length >= planned.sets &&
            e.log.workSets.every(
              (s) =>
                  s.reps != null &&
                  s.reps! >= planned.repsMax &&
                  s.rir != null &&
                  s.rir! >= planned.rir,
            ),
      );
      if (!reached) continue;
      final timed = exercise.loadType == LoadType.time;
      final top = timed
          ? '${planned.repsMax} s'
          : '${planned.repsMax} repeticiones';
      yield make(
        subject: id,
        anchor: used.last.dateKey,
        kind: RecommendationKind.suggestion,
        title: '${exercise.name}: más reto',
        summary:
            'En tus dos últimas sesiones llegaste a $top en todas las series '
            'con RIR ${planned.rir} o más. Puedes subir el rango '
            '${timed ? '5 s' : '1–2 repeticiones'} o añadir una serie (hasta '
            '5) desde el editor del plan.',
        because: [
          for (final e in used)
            FactRef('Sesión usada', exercise.name, date: e.dateKey),
        ],
        threshold: 'Dos sesiones en el tope del rango',
        action: AdvanceExercise(id),
      );
    }
  }
}

/// P4 · Three full sessions at one load without more reps: try another rep
/// range or an alternative.
class Stall extends ExpertRule {
  const Stall();
  @override
  String get id => 'progression.stall';
  @override
  RuleFamily get family => RuleFamily.progression;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 4;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) sync* {
    for (final id in f.progression.keys) {
      if (!f.stalled(id)) continue;
      final full = f.fullExposures(id);
      final last = full.sublist(full.length - Thresholds.stallSessions);
      final name = f.exercise(id).name;
      final load = last.last.log.workSets.first.weightKg!;
      yield make(
        subject: id,
        anchor: last.last.dateKey,
        kind: RecommendationKind.suggestion,
        title: '$name: estancado',
        summary:
            '${Thresholds.stallSessions} sesiones seguidas con ${_kg(load)} sin '
            'sumar repeticiones. Prueba otro rango de repeticiones o una '
            'alternativa compatible; si además notas fatiga, una semana más '
            'suave puede ayudar.',
        because: [
          for (final e in last)
            FactRef(
              'Sesión',
              '${_kg(load)} · ${e.log.workSets.fold<int>(0, (sum, s) => sum + (s.reps ?? 0))} repeticiones en total',
              date: e.dateKey,
            ),
        ],
        threshold: '${Thresholds.stallSessions} sesiones',
        action: OpenAlternatives(id),
      );
    }
  }
}
