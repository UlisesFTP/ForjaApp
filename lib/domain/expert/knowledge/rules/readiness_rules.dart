import '../../../models/labels.dart';
import '../../../models/models.dart';
import '../../../services/training_rules.dart';
import '../../engine/rule.dart';
import '../../facts/coach_facts.dart';
import '../../model/coach_action.dart';
import '../../model/recommendation.dart';
import '../../model/veto.dart';
import '../evidence.dart';
import '../thresholds.dart';

/// R1 · Tiredness, soreness or a low habitual energy propose a lighter
/// session today (one set fewer, 3 reps in reserve), reversible on Hoy.
/// Wraps [TrainingRules.needsLighterSession] and its text.
class LighterSession extends ExpertRule {
  const LighterSession();
  @override
  String get id => 'readiness.lighter-session';
  @override
  RuleFamily get family => RuleFamily.readiness;
  @override
  Evidence get evidence => const Evidence(
    EvidenceLevel.heuristic,
    '${Sources.helms2016} Ajuste de FORJA desde la versión 0.1.',
  );
  @override
  int get specificity => 2;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    if (!f.lighterSessionProposed) return const [];
    final feeling = f.feelingToday;
    return [
      make(
        subject: 'today',
        anchor: f.todayKey,
        kind: RecommendationKind.info,
        title: f.lighterSessionApplied
            ? 'Sesión más ligera hoy'
            : 'Sesión según el plan',
        summary: f.todayLine!,
        because: [
          if (feeling == Feeling.tired || feeling == Feeling.doms)
            FactRef(
              'Check-in de hoy',
              feelingLabels[feeling]!.toLowerCase(),
              date: f.todayKey,
            ),
          if (f.profile.energy == Energy.low)
            const FactRef('Energía habitual del perfil', 'baja'),
        ],
        action: OpenDay(f.todayKey),
      ),
    ];
  }
}

/// D1 · Several kinds of fatigue signal within two weeks: a lighter week may
/// help. Information only (the person decides; the plan does not change),
/// and no added volume meanwhile.
class DeloadSuggestion extends ExpertRule {
  const DeloadSuggestion();
  @override
  String get id => 'readiness.deload';
  @override
  RuleFamily get family => RuleFamily.readiness;
  @override
  Evidence get evidence =>
      const Evidence(EvidenceLevel.heuristic, Sources.bell2023);
  @override
  int get specificity => 5;
  @override
  int get cooldownDays => 28;

  /// The signals found, as facts, one per kind.
  List<FactRef> signals(CoachFacts f) {
    const window = Thresholds.deloadWindowDays;
    final from = f.keyDaysAgo(window - 1);
    final found = <FactRef>[];
    final tired = f.datesFeeling(Feeling.tired, window);
    if (tired.length >= Thresholds.fatigueDays) {
      found.add(
        FactRef('Días con cansancio', '${tired.length}', date: tired.last),
      );
    }
    final doms = f.datesFeeling(Feeling.doms, window);
    if (doms.length >= Thresholds.fatigueDays) {
      found.add(FactRef('Días con DOMS', '${doms.length}', date: doms.last));
    }
    final review = [
      for (final s in f.progression.values)
        if (s.kind == ProgressionKind.review && s.basedOn.compareTo(from) >= 0)
          s.exerciseId,
    ];
    if (review.length >= Thresholds.reviewExercises) {
      found.add(
        FactRef(
          'Ejercicios por debajo del mínimo',
          [for (final id in review) f.exercise(id).name].join(', '),
        ),
      );
    }
    final stalled = [
      for (final id in f.progression.keys)
        if (f.stalled(id) &&
            (f.completedExposures(id).lastOrNull?.dateKey ?? '').compareTo(
                  from,
                ) >=
                0)
          id,
    ];
    if (stalled.isNotEmpty) {
      found.add(
        FactRef(
          'Ejercicios estancados',
          [for (final id in stalled) f.exercise(id).name].join(', '),
        ),
      );
    }
    final rirZero = <String>{
      for (final s in f.pastSessions)
        if (s.dateKey.compareTo(from) >= 0)
          for (final e in s.exercises)
            if (f.plannedFor(e.exerciseId).rir >=
                    Thresholds.rirZeroTargetAtLeast &&
                e.workSets.any((x) => x.rir == 0))
              s.dateKey,
    };
    if (rirZero.length >= Thresholds.rirZeroSessions) {
      found.add(
        FactRef(
          'Sesiones al fallo (RIR 0) con objetivo de RIR '
              '${Thresholds.rirZeroTargetAtLeast} o más',
          '${rirZero.length}',
        ),
      );
    }
    return found;
  }

  bool _fires(CoachFacts f) =>
      signals(f).length >= Thresholds.deloadMinSignalKinds;

  @override
  Iterable<Veto> vetoes(CoachFacts f) => [
    if (_fires(f))
      veto(
        VetoKind.volumeIncrease,
        'hay señales de fatiga de las últimas dos semanas.',
        because: signals(f),
      ),
  ];

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final found = signals(f);
    if (found.length < Thresholds.deloadMinSignalKinds) return const [];
    return [
      make(
        subject: 'deload',
        anchor: f.todayKey,
        kind: RecommendationKind.info,
        title: 'Una semana más suave',
        summary:
            'En las dos últimas semanas hay varias señales de fatiga. Puede '
            'venir bien una semana más suave: las mismas sesiones con una serie '
            'menos y 3 repeticiones en reserva. Tú decides; la app no cambia el '
            'plan.',
        because: found,
        threshold:
            '${Thresholds.deloadMinSignalKinds} tipos de señal en '
            '${Thresholds.deloadWindowDays} días',
      ),
    ];
  }
}
