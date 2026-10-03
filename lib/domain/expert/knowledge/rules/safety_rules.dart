import '../../../../core/date_utils.dart';
import '../../../models/models.dart';
import '../../../services/training_rules.dart';
import '../../engine/rule.dart';
import '../../facts/coach_facts.dart';
import '../../model/coach_action.dart';
import '../../model/recommendation.dart';
import '../../model/veto.dart';
import '../evidence.dart';
import '../thresholds.dart';

String _day(String key) => shortDate(parseDateKey(key));

/// What to do after [gapDays] without training, or null when the gap is
/// short. Shared with the advice line of Hoy (D41e).
String? breakAdvice(int gapDays) {
  if (gapDays >= Thresholds.breakRebuildDays) {
    return 'Llevas $gapDays días sin entrenar: empieza con cargas más ligeras '
        'y reconstruye durante 2–3 semanas. No se sugieren aumentos hasta '
        'que vuelvas a registrar sesiones.';
  }
  if (gapDays >= Thresholds.breakKeepLoadDays) {
    return 'Llevas $gapDays días sin entrenar: retoma con las mismas cargas y '
        'deja 1–2 repeticiones más en reserva las primeras sesiones.';
  }
  return null;
}

/// S1 · An injury registered today pauses the session and rules out any
/// increase. Wraps [TrainingRules.recommendation]: the text is the same one
/// Hoy shows.
class InjuryToday extends ExpertRule {
  const InjuryToday();
  @override
  String get id => 'safety.injury-today';
  @override
  RuleFamily get family => RuleFamily.safety;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 1;

  List<FactRef> _because(CoachFacts f) => [
    FactRef('Check-in de hoy', 'lesión', date: f.todayKey),
  ];

  @override
  Iterable<Veto> vetoes(CoachFacts f) => [
    if (f.feelingToday == Feeling.injured)
      veto(
        VetoKind.loadIncrease,
        'hoy registraste una lesión.',
        because: _because(f),
      ),
  ];

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) => [
    if (f.feelingToday == Feeling.injured)
      make(
        subject: 'today',
        anchor: f.todayKey,
        kind: RecommendationKind.caution,
        title: 'Lesión registrada hoy',
        summary: TrainingRules.recommendation(f.profile, Feeling.injured)!,
        because: _because(f),
      ),
  ];
}

/// S2 · An injury check-in (before or after training) in the last 14 days
/// rules out increases for every exercise. Today's check-in before training
/// is S1's.
class InjuryRecent extends ExpertRule {
  const InjuryRecent();
  @override
  String get id => 'safety.injury-recent';
  @override
  RuleFamily get family => RuleFamily.safety;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 2;

  String? _latest(CoachFacts f) {
    final from = f.keyDaysAgo(Thresholds.injuryVetoDays - 1);
    bool inWindow(String k) =>
        k.compareTo(from) >= 0 && k.compareTo(f.todayKey) <= 0;
    final keys = <String>{
      for (final e in f.inputs.checkIns.entries)
        if (e.value.feeling == Feeling.injured &&
            inWindow(e.key) &&
            e.key != f.todayKey)
          e.key,
      for (final e in f.inputs.afterCheckIns.entries)
        if (e.value.feeling == Feeling.injured && inWindow(e.key)) e.key,
    }.toList()..sort();
    return keys.lastOrNull;
  }

  List<FactRef> _because(String key) => [
    FactRef('Check-in', 'lesión', date: key),
    const FactRef(
      'Ventana sin aumentos',
      '${Thresholds.injuryVetoDays} días desde la lesión',
    ),
  ];

  @override
  Iterable<Veto> vetoes(CoachFacts f) {
    final key = _latest(f);
    if (key == null) return const [];
    return [
      veto(
        VetoKind.loadIncrease,
        'registraste una lesión el ${_day(key)} (se respetan '
        '${Thresholds.injuryVetoDays} días).',
        because: _because(key),
      ),
    ];
  }

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final key = _latest(f);
    if (key == null) return const [];
    return [
      make(
        subject: 'injury',
        anchor: key,
        kind: RecommendationKind.caution,
        title: 'Lesión reciente',
        summary:
            'Registraste una lesión el ${_day(key)}. Durante '
            '${Thresholds.injuryVetoDays} días desde entonces no se sugieren '
            'aumentos de carga. Si el dolor sigue o empeora, consulta a un '
            'profesional de la salud.',
        because: _because(key),
        threshold: '${Thresholds.injuryVetoDays} días',
      ),
    ];
  }
}

/// S3 · A monthly review that answered "pain" rules out increases for 14
/// days after it.
class ReviewPain extends ExpertRule {
  const ReviewPain();
  @override
  String get id => 'safety.review-pain';
  @override
  RuleFamily get family => RuleFamily.safety;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 2;

  MonthlyReview? _review(CoachFacts f) {
    final last = f.inputs.reviews.lastOrNull;
    if (last == null || last.answers['pain'] != true) return null;
    final ago = f.daysAgo(last.reviewedOn);
    return ago >= 0 && ago < Thresholds.reviewPainVetoDays ? last : null;
  }

  List<FactRef> _because(MonthlyReview r) => [
    FactRef(
      'Revisión mensual',
      'dolor que estorba al entrenar',
      date: r.reviewedOn,
    ),
  ];

  @override
  Iterable<Veto> vetoes(CoachFacts f) {
    final r = _review(f);
    if (r == null) return const [];
    return [
      veto(
        VetoKind.loadIncrease,
        'en la revisión del ${_day(r.reviewedOn)} dijiste que el dolor te '
        'estorbaba.',
        because: _because(r),
      ),
    ];
  }

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final r = _review(f);
    if (r == null) return const [];
    return [
      make(
        subject: 'review',
        anchor: r.reviewedOn,
        kind: RecommendationKind.caution,
        title: 'Dolor en la última revisión',
        summary:
            'En la revisión del ${_day(r.reviewedOn)} dijiste que el dolor te '
            'estorbaba al entrenar. Durante ${Thresholds.reviewPainVetoDays} '
            'días no se sugieren aumentos. Si persiste, consulta a un '
            'profesional de la salud.',
        because: _because(r),
        threshold: '${Thresholds.reviewPainVetoDays} días',
      ),
    ];
  }
}

/// S4 · Coming back after a break: same loads with more reserve after 8
/// days, lighter loads after 21. An exercise not done for 21 days or more
/// gets no increase, whatever its last two sessions said.
class ReturnAfterBreak extends ExpertRule {
  const ReturnAfterBreak();
  @override
  String get id => 'safety.return-after-break';
  @override
  RuleFamily get family => RuleFamily.safety;
  @override
  Evidence get evidence => const Evidence(
    EvidenceLevel.heuristic,
    '${Sources.forja} Basada en la pérdida de forma tras semanas sin entrenar.',
  );
  @override
  int get specificity => 1;

  @override
  Iterable<Veto> vetoes(CoachFacts f) sync* {
    for (final id in f.progression.keys) {
      final last = f.completedExposures(id).lastOrNull?.dateKey;
      if (last == null) continue;
      final ago = f.daysAgo(last);
      if (ago < Thresholds.breakRebuildDays) continue;
      yield veto(
        VetoKind.loadIncrease,
        'la última sesión de ${f.exercise(id).name} fue hace $ago días: '
        'primero hay que volver a coger el ritmo.',
        exerciseId: id,
        because: [FactRef('Última sesión', f.exercise(id).name, date: last)],
      );
    }
  }

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final last = f.lastActivityBeforeToday;
    if (last == null) return const [];
    // Already back today: "N days without training" would not be true.
    final today = f.sessionOn(f.todayKey);
    if (today != null && CoachFacts.hasActivity(today)) return const [];
    final gap = f.daysAgo(last);
    final advice = breakAdvice(gap);
    if (advice == null) return const [];
    return [
      make(
        subject: 'break',
        anchor: last,
        kind: gap >= Thresholds.breakRebuildDays
            ? RecommendationKind.caution
            : RecommendationKind.info,
        title: 'Vuelta tras una pausa',
        summary: advice,
        because: [
          FactRef('Último entreno', '$gap días antes de hoy', date: last),
        ],
        threshold:
            '${Thresholds.breakKeepLoadDays} y ${Thresholds.breakRebuildDays} días',
      ),
    ];
  }
}

/// S5 · Pain registered again after a week: see a professional.
class PainPersists extends ExpertRule {
  const PainPersists();
  @override
  String get id => 'safety.pain-persists';
  @override
  RuleFamily get family => RuleFamily.safety;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 3;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final dates = f.datesFeeling(
      Feeling.injured,
      Thresholds.painPersistsWindowDays,
    );
    if (dates.length < Thresholds.painPersistsDates) return const [];
    final span = f.daysAgo(dates.first) - f.daysAgo(dates.last);
    if (span < Thresholds.painPersistsGapDays) return const [];
    return [
      make(
        subject: 'pain',
        anchor: dates.last,
        kind: RecommendationKind.caution,
        title: 'La lesión se repite',
        summary:
            'Registraste lesión o dolor el ${_day(dates.first)} y otra vez el '
            '${_day(dates.last)}. Si persiste o empeora, consulta a un '
            'profesional de la salud antes de seguir cargando esa zona.',
        because: [
          for (final d in dates) FactRef('Check-in', 'lesión', date: d),
        ],
        threshold:
            '${Thresholds.painPersistsDates} fechas separadas al menos '
            '${Thresholds.painPersistsGapDays} días',
      ),
    ];
  }
}

/// S6 · Nutrition ranges are for adults: none for a minor.
class MinorNoRanges extends ExpertRule {
  const MinorNoRanges();
  @override
  String get id => 'safety.minor';
  @override
  RuleFamily get family => RuleFamily.safety;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 1;

  @override
  Iterable<Veto> vetoes(CoachFacts f) {
    final age = f.profile.age;
    if (age == null || age >= Thresholds.adultAge) return const [];
    return [
      veto(
        VetoKind.nutritionRanges,
        'las referencias de nutrición son para adultos.',
        because: [FactRef('Edad del perfil', '$age años')],
      ),
    ];
  }
}

/// S7 · A very low calorie goal of one's own gets a caution (it is kept: the
/// goals are the person's).
class LowCalorieGoal extends ExpertRule {
  const LowCalorieGoal();
  @override
  String get id => 'safety.kcal-goal';
  @override
  RuleFamily get family => RuleFamily.safety;
  @override
  Evidence get evidence =>
      const Evidence(EvidenceLevel.moderate, Sources.nhlbi);
  @override
  int get specificity => 1;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final kcal = f.inputs.goals.kcal;
    if (kcal == null || kcal >= Thresholds.kcalGoalCaution) return const [];
    final medical = kcal < Thresholds.kcalGoalMedical;
    return [
      make(
        subject: 'kcal-goal',
        anchor: '$kcal',
        kind: RecommendationKind.caution,
        title: 'Objetivo de calorías muy bajo',
        summary: medical
            ? 'Tu objetivo de $kcal kcal al día está por debajo de '
                  '${Thresholds.kcalGoalMedical}: una dieta así solo debe '
                  'seguirse con supervisión médica.'
            : 'Tu objetivo de $kcal kcal al día es muy bajo para la mayoría '
                  'de adultos. Si es lo que buscas, coméntalo con un '
                  'profesional de la salud.',
        because: [FactRef('Tu objetivo diario', '$kcal kcal')],
        threshold:
            '${Thresholds.kcalGoalCaution} y ${Thresholds.kcalGoalMedical} kcal',
        action: const OpenNutritionGoals(),
      ),
    ];
  }
}
