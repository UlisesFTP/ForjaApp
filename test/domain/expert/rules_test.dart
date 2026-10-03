import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/core/date_utils.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/domain/expert/expert_coach.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/plan_generator.dart';

import 'expert_fixtures.dart';

List<Recommendation> _of(ExpertResult r, String ruleId) =>
    r.recommendations.where((x) => x.ruleId == ruleId).toList();

ExpertResult _run({
  UserProfile profile = const UserProfile(),
  PlanVersion? plan,
  PlanVersion? draft,
  List<WorkoutSession> history = const [],
  Map<String, CheckIn> checkIns = const {},
  Map<String, CheckIn> afterCheckIns = const {},
  List<MonthlyReview> reviews = const [],
  List<CardioSession> cardio = const [],
  Map<String, List<FoodEntry>> food = const {},
  NutritionGoals goals = const NutritionGoals(),
  List<Reschedule> reschedules = const [],
  DateTime? today,
}) => ExpertCoach.evaluate(
  coachInputs(
    today: today,
    profile: profile,
    plan: plan,
    draft: draft,
    history: history,
    checkIns: checkIns,
    afterCheckIns: afterCheckIns,
    reviews: reviews,
    cardio: cardio,
    food: food,
    goals: goals,
    reschedules: reschedules,
  ),
);

String _ago(int n) => daysBefore(monday, n);

const _injured = CheckIn(feeling: Feeling.injured);
const _tired = CheckIn(feeling: Feeling.tired);
const _doms = CheckIn(feeling: Feeling.doms);

/// An exercise logged with work sets but no effort (RIR) recorded.
ExerciseLog _noRir(String id) {
  final planned = PlanExercise.fromExercise(exerciseFor(id));
  return ExerciseLog(
    exerciseId: id,
    weightKg: 60,
    completed: true,
    technique: TechniqueRating.solid,
    sets: [
      for (var i = 1; i <= planned.sets; i++)
        workSet(i, reps: planned.repsMax, rir: null),
    ],
  );
}

/// A plan of one's own with a single training day (Tuesday).
PlanVersion _ownPlan(List<PlanExercise> exercises) => PlanVersion(
  id: 'own',
  status: PlanStatus.accepted,
  source: PlanSource.manual,
  name: 'Propio',
  createdAt: DateTime.utc(2026, 9, 1),
  effectiveFrom: '2026-09-01',
  days: [
    PlanDay(
      DateTime.tuesday,
      Routine(
        id: 'own-day',
        name: 'Día propio',
        focus: '',
        warmup: '',
        exercises: exercises,
      ),
    ),
  ],
);

PlanExercise _planned(String id, {int? sets, double? increment}) {
  final p = PlanExercise.fromExercise(exerciseFor(id));
  return p.copyWith(sets: sets, incrementKg: increment);
}

void main() {
  group('safety rules', () {
    test('S2 · an injury within 14 days vetoes increases; day 14 does not', () {
      final inside = _run(checkIns: {_ago(13): _injured});
      expect(_of(inside, 'safety.injury-recent').single.anchor, _ago(13));
      expect(inside.vetoes.any(VetoKind.loadIncrease), isTrue);
      final outside = _run(checkIns: {_ago(14): _injured});
      expect(_of(outside, 'safety.injury-recent'), isEmpty);
      expect(outside.vetoes.any(VetoKind.loadIncrease), isFalse);
      // After training counts too, today included.
      final after = _run(afterCheckIns: {_ago(0): _injured});
      expect(_of(after, 'safety.injury-recent'), hasLength(1));
      // Today's check-in before training is S1's, not S2's.
      final today = _run(checkIns: {_ago(0): _injured});
      expect(_of(today, 'safety.injury-today'), hasLength(1));
      expect(_of(today, 'safety.injury-recent'), isEmpty);
    });

    test('S3 · pain in the review vetoes for 14 days', () {
      final recent = _run(reviews: [reviewOn(_ago(13), pain: true)]);
      expect(_of(recent, 'safety.review-pain'), hasLength(1));
      expect(recent.vetoes.any(VetoKind.loadIncrease), isTrue);
      expect(
        _of(
          _run(reviews: [reviewOn(_ago(14), pain: true)]),
          'safety.review-pain',
        ),
        isEmpty,
      );
      expect(
        _of(_run(reviews: [reviewOn(_ago(2))]), 'safety.review-pain'),
        isEmpty,
      );
    });

    test('S4 · back after 8 days: same loads; after 21: lighter, and no '
        'increase for what was not done since', () {
      ExpertResult gap(int days, {bool trainedToday = false}) => _run(
        history: [
          session(_ago(days), [logged('squat')]),
          if (trainedToday) session(_ago(0), [logged('bench')]),
        ],
      );
      expect(_of(gap(7), 'safety.return-after-break'), isEmpty);
      final eight = _of(gap(8), 'safety.return-after-break').single;
      expect(eight.kind, RecommendationKind.info);
      expect(eight.summary, contains('mismas cargas'));
      expect(
        _of(gap(20), 'safety.return-after-break').single.kind,
        RecommendationKind.info,
      );
      final rebuild = gap(21);
      final r = _of(rebuild, 'safety.return-after-break').single;
      expect(r.kind, RecommendationKind.caution);
      expect(r.summary, contains('cargas más ligeras'));
      expect(
        rebuild.vetoes.any(VetoKind.loadIncrease, exerciseId: 'squat'),
        isTrue,
      );
      expect(
        gap(20).vetoes.all
            .where((v) => v.ruleId == 'safety.return-after-break'),
        isEmpty,
      );
      // Already back today: nothing to say.
      expect(
        _of(gap(30, trainedToday: true), 'safety.return-after-break'),
        isEmpty,
      );
    });

    test('S4 · an old pair of sessions cannot unlock an increase', () {
      final result = _run(
        history: [
          session(_ago(30), [logged('squat')]),
          session(_ago(25), [logged('squat')]),
        ],
      );
      expect(result.progression['squat']!.kind, ProgressionKind.increase);
      final r = _of(result, 'progression.prog').single;
      expect(r.kind, RecommendationKind.blocked);
      expect(r.vetoedBy, 'safety.return-after-break');
      expect(r.action, isNull);
    });

    test('S5 · an injury again a week later suggests a professional', () {
      expect(
        _of(
          _run(checkIns: {_ago(10): _injured, _ago(2): _injured}),
          'safety.pain-persists',
        ),
        hasLength(1),
      );
      expect(
        _of(
          _run(checkIns: {_ago(5): _injured, _ago(1): _injured}),
          'safety.pain-persists',
        ),
        isEmpty,
      );
    });

    test('S6 · a minor gets no nutrition ranges', () {
      final food = {
        _ago(1): [foodOn(_ago(1), 500)],
      };
      expect(
        _of(
          _run(profile: const UserProfile(age: 17, weightKg: 60), food: food),
          'nutrition.protein-reference',
        ),
        isEmpty,
      );
      expect(
        _of(
          _run(profile: const UserProfile(age: 18, weightKg: 60), food: food),
          'nutrition.protein-reference',
        ),
        hasLength(1),
      );
    });

    test('S7 · a very low goal of one\'s own gets a caution', () {
      String? summary(int kcal) => _of(
        _run(goals: NutritionGoals(kcal: kcal)),
        'safety.kcal-goal',
      ).firstOrNull?.summary;
      expect(summary(1200), isNull);
      expect(summary(1199), isNot(contains('supervisión médica')));
      expect(summary(800), isNot(contains('supervisión médica')));
      expect(summary(799), contains('supervisión médica'));
    });
  });

  group('readiness and progression rules', () {
    test('D1 · two kinds of fatigue signal in 14 days suggest a lighter week '
        'and stop added volume', () {
      final both = _run(
        profile: const UserProfile(onboarded: true),
        checkIns: {
          _ago(1): _tired,
          _ago(3): _tired,
          _ago(2): _doms,
          _ago(4): _doms,
        },
      );
      final deload = _of(both, 'readiness.deload').single;
      expect(deload.kind, RecommendationKind.info);
      expect(deload.action, isNull);
      expect(both.vetoes.any(VetoKind.volumeIncrease), isTrue);
      // Adding sets is blocked meanwhile.
      final volume = _of(both, 'plan.low-volume').single;
      expect(volume.kind, RecommendationKind.blocked);
      expect(volume.vetoedBy, 'readiness.deload');

      expect(
        _of(
          _run(checkIns: {_ago(1): _tired, _ago(3): _tired}),
          'readiness.deload',
        ),
        isEmpty,
      );
      // Day 14 is outside the window.
      expect(
        _of(
          _run(
            checkIns: {
              _ago(1): _tired,
              _ago(14): _tired,
              _ago(2): _doms,
              _ago(4): _doms,
            },
          ),
          'readiness.deload',
        ),
        isEmpty,
      );
    });

    test('P2 · a step over 10 % of the load gets a caution', () {
      ExpertResult step(double increment) => _run(
        plan: _ownPlan([_planned('squat', increment: increment)]),
        history: [
          session('2026-09-22', [logged('squat')]),
          session('2026-09-29', [logged('squat')]),
        ],
      );
      expect(_of(step(10), 'progression.big-step'), hasLength(1));
      expect(_of(step(6), 'progression.big-step'), isEmpty);
      expect(_of(step(2.5), 'progression.big-step'), isEmpty);
    });

    test('P3 · bodyweight reps at the top twice suggest more challenge; a '
        'missing RIR never qualifies', () {
      final done = _run(
        history: [
          session('2026-09-29', [logged('pushup')]),
          session('2026-10-01', [logged('pushup')]),
        ],
      );
      final r = _of(done, 'progression.reps-bodyweight').single;
      expect(r.action, isA<AdvanceExercise>());
      expect(r.kind, RecommendationKind.suggestion);
      final noRir = _run(
        history: [
          session('2026-09-29', [_noRir('pushup')]),
          session('2026-10-01', [logged('pushup')]),
        ],
      );
      expect(_of(noRir, 'progression.reps-bodyweight'), isEmpty);
      final belowTop = _run(
        history: [
          session('2026-09-29', [logged('pushup', reps: 12)]),
          session('2026-10-01', [logged('pushup')]),
        ],
      );
      expect(_of(belowTop, 'progression.reps-bodyweight'), isEmpty);
      // An injury blocks it like any increase.
      final injured = _run(
        history: [
          session('2026-09-29', [logged('pushup')]),
          session('2026-10-01', [logged('pushup')]),
        ],
        checkIns: {_ago(2): _injured},
      );
      expect(
        _of(injured, 'progression.reps-bodyweight').single.kind,
        RecommendationKind.blocked,
      );
    });

    test('P4 · three full sessions at one load without more reps is a '
        'stall', () {
      final stalled = _run(
        history: [
          session('2026-09-22', [logged('squat', reps: 6)]),
          session('2026-09-29', [logged('squat', reps: 6)]),
          session('2026-10-01', [logged('squat', reps: 6)]),
        ],
      );
      final r = _of(stalled, 'progression.stall').single;
      expect(r.action, isA<OpenAlternatives>());
      expect(
        _of(
          _run(
            history: [
              session('2026-09-29', [logged('squat', reps: 6)]),
              session('2026-10-01', [logged('squat', reps: 6)]),
            ],
          ),
          'progression.stall',
        ),
        isEmpty,
      );
      expect(
        _of(
          _run(
            history: [
              session('2026-09-22', [logged('squat', reps: 6)]),
              session('2026-09-29', [logged('squat', reps: 6)]),
              session('2026-10-01', [logged('squat', reps: 7)]),
            ],
          ),
          'progression.stall',
        ),
        isEmpty,
      );
    });
  });

  group('plan rules', () {
    test(
      'V2 · under 4 weekly sets for a major muscle (strength or muscle)',
      () {
        final plan = _ownPlan([_planned('bench', sets: 3)]);
        final r = _of(_run(plan: plan), 'plan.low-volume').single;
        expect(r.summary, contains('Pecho 3'));
        expect(r.action, isA<AddVolume>());
        final fourSets = _run(plan: _ownPlan([_planned('bench', sets: 4)]));
        expect(
          _of(fourSets, 'plan.low-volume').single.summary,
          isNot(contains('Pecho')),
        );
        expect(
          _of(
            _run(
              plan: plan,
              profile: const UserProfile(goal: TrainingGoal.fitness),
            ),
            'plan.low-volume',
          ),
          isEmpty,
        );
        // The example plan of someone who has not finished the setup: no.
        expect(_of(_run(), 'plan.low-volume'), isEmpty);
      },
    );

    test('V3 · over 20 weekly sets with fatigue: trim', () {
      final plan = _ownPlan([_planned('bench', sets: 21)]);
      expect(
        _of(
          _run(plan: plan, checkIns: {_ago(1): _tired, _ago(2): _tired}),
          'plan.high-volume',
        ),
        hasLength(1),
      );
      expect(_of(_run(plan: plan), 'plan.high-volume'), isEmpty);
    });

    test('V4 · a muscle goal with groups on a single day', () {
      final r = _of(
        _run(
          profile: const UserProfile(
            onboarded: true,
            goal: TrainingGoal.muscle,
          ),
        ),
        'plan.frequency',
      ).single;
      expect(r.kind, RecommendationKind.info);
      expect(
        _of(
          _run(profile: const UserProfile(onboarded: true)),
          'plan.frequency',
        ),
        isEmpty,
      );
    });

    test('G1 · a routine much longer than the chosen session length', () {
      final minutes = {
        for (final d in examplePlan.days)
          d.routine.id: PlanGenerator.routineMinutes(d.routine, exerciseFor),
      };
      for (final chosen in [10, 20, 30, 120]) {
        final expected = {
          for (final e in minutes.entries)
            if (e.value > chosen + 15) e.key,
        };
        expect(
          {
            for (final r in _of(
              _run(
                profile: UserProfile(onboarded: true, sessionMinutes: chosen),
              ),
              'plan.too-long',
            ))
              r.subject,
          },
          expected,
          reason: '$chosen min',
        );
      }
      expect(
        _of(
          _run(profile: const UserProfile(onboarded: true, sessionMinutes: 10)),
          'plan.too-long',
        ),
        hasLength(3),
      );
    });

    test('G2 · equipment the person did not mark', () {
      final r = _run(
        profile: const UserProfile(
          onboarded: true,
          equipment: {Equipment.bodyweight, Equipment.dumbbell},
        ),
      );
      final ids = {for (final x in _of(r, 'plan.missing-equipment')) x.subject};
      expect(ids, containsAll(['squat', 'bench', 'row']));
      expect(ids, isNot(contains('shoulder')));
      expect(
        _of(
          _run(profile: const UserProfile(equipment: {Equipment.bodyweight})),
          'plan.missing-equipment',
        ),
        isEmpty,
      );
    });

    test('G3 · a draft unreviewed for 3 days', () {
      PlanVersion draft(DateTime created) => PlanVersion(
        id: 'draft',
        status: PlanStatus.draft,
        source: PlanSource.generated,
        name: 'Borrador',
        createdAt: created,
        days: examplePlan.days,
      );
      expect(
        _of(
          _run(draft: draft(DateTime(2026, 10, 2, 12))),
          'plan.draft-pending',
        ),
        hasLength(1),
      );
      expect(
        _of(
          _run(draft: draft(DateTime(2026, 10, 3, 12))),
          'plan.draft-pending',
        ),
        isEmpty,
      );
    });

    test('G4 · the example plan explains its adaptation', () {
      expect(
        _of(
          _run(profile: const UserProfile(experience: Experience.beginner)),
          'plan.example-adapted',
        ).single.summary,
        contains('2 series por ejercicio'),
      );
      expect(
        _of(
          _run(plan: examplePlanCopy(PlanSource.manual)),
          'plan.example-adapted',
        ),
        isEmpty,
      );
    });
  });

  group('adherence rules', () {
    // Monday 5 Oct: the last week's planned days are Tue 29, Thu 1, Sat 3.
    final started = session('2026-09-22', [logged('squat')]);

    test('A1 · a planned day of the last week with nothing recorded', () {
      final subjects = {
        for (final r in _of(_run(history: [started]), 'adherence.unrecorded'))
          r.subject,
      };
      expect(subjects, {'2026-09-29', '2026-10-01', '2026-10-03'});
      final some = _run(
        history: [
          started,
          session('2026-09-29', [logged('squat')]),
          session('2026-10-01', const [], status: SessionStatus.missed),
        ],
        reschedules: [
          Reschedule(
            id: 'm',
            sourceDate: '2026-10-03',
            targetDate: '2026-10-06',
            kind: RescheduleKind.missed,
            createdAt: DateTime.utc(2026, 10, 3),
          ),
        ],
      );
      expect(_of(some, 'adherence.unrecorded'), isEmpty);
      // Before the person started, nothing is held against them.
      expect(_of(_run(), 'adherence.unrecorded'), isEmpty);
    });

    test('A2 · under 60 % two weeks running, never "catch up"', () {
      final low = _of(
        _run(
          history: [
            session('2026-09-15', [logged('squat')]),
          ],
        ),
        'adherence.low',
      ).single;
      expect(low.action, isA<OpenReview>());
      expect(low.summary, contains('No hace falta recuperar'));
      final better = _run(
        history: [
          session('2026-09-15', [logged('squat')]),
          session('2026-09-29', [logged('squat')]),
          session('2026-10-01', [logged('bench')]),
        ],
      );
      expect(_of(better, 'adherence.low'), isEmpty);
    });
  });

  group('cardio rules', () {
    test('C1 · moderate-equivalent minutes against 150 (WHO)', () {
      Recommendation who(List<CardioSession> cardio) =>
          _of(_run(cardio: cardio), 'cardio.who-week').single;
      final little = who([cardioOn(_ago(1), 100)]);
      expect(little.summary, contains('100 min'));
      expect(little.action, isA<OpenCardio>());
      expect(who([cardioOn(_ago(1), 150)]).action, isNull);
      // Vigorous counts double, under MET 3 counts nothing.
      expect(
        who([
          cardioOn(
            _ago(1),
            80,
            activity: CardioActivity.treadmill,
            intensity: CardioIntensity.high,
          ),
        ]).summary,
        contains('160 min'),
      );
      expect(
        who([cardioOn(_ago(1), 60, intensity: CardioIntensity.low)]).summary,
        contains('unos 0 min'),
      );
      // Nobody is nagged who does not log cardio.
      expect(_of(_run(), 'cardio.who-week'), isEmpty);
      expect(
        _of(_run(cardio: [cardioOn(_ago(30), 60)]), 'cardio.who-week'),
        isEmpty,
      );
    });

    test('C2 · two comparable, comfortable sessions: the person chooses', () {
      List<Recommendation> run(
        int a,
        int b, {
        Feeling feedback = Feeling.normal,
      }) => _of(
        _run(
          cardio: [
            cardioOn(_ago(5), a, activity: CardioActivity.bicycle),
            cardioOn(
              _ago(2),
              b,
              activity: CardioActivity.bicycle,
              feedback: feedback,
            ),
          ],
        ),
        'cardio.progress',
      );
      expect(run(30, 31).single.summary, contains('tú eliges'));
      expect(run(30, 40), isEmpty);
      expect(run(30, 30, feedback: Feeling.tired), isEmpty);
    });
  });

  group('nutrition rules', () {
    Map<String, List<FoodEntry>> days(
      List<int> ago, {
      double? protein = 30,
    }) => {
      for (final n in ago)
        _ago(n): [foodOn(_ago(n), 1800, protein: protein, carbs: 200, fat: 60)],
    };

    test('N1 · averages of the logged days, only with 4 of 7', () {
      final r = _of(
        _run(food: days([1, 2, 3, 4]), goals: const NutritionGoals(kcal: 2000)),
        'nutrition.averages',
      ).single;
      expect(r.summary, contains('media de 1800 kcal (objetivo 2000)'));
      expect(
        _of(
          _run(food: days([1, 2, 3]), goals: const NutritionGoals(kcal: 2000)),
          'nutrition.averages',
        ),
        isEmpty,
      );
      final missing = _run(
        food: {
          ...days([1, 2, 3]),
          ...days([4], protein: null),
        },
        goals: const NutritionGoals(kcal: 2000, proteinG: 120),
      );
      expect(
        _of(missing, 'nutrition.averages').single.summary,
        contains('no se puede promediar'),
      );
      // Today is left out: it is not over.
      expect(
        _of(
          _run(
            food: days([0, 1, 2, 3]),
            goals: const NutritionGoals(kcal: 2000),
          ),
          'nutrition.averages',
        ),
        isEmpty,
      );
    });

    test('N2 · three days of the week without food', () {
      expect(
        _of(_run(food: days([1, 2, 3, 4])), 'nutrition.unlogged'),
        hasLength(1),
      );
      expect(
        _of(_run(food: days([1, 2, 3, 4, 5])), 'nutrition.unlogged'),
        isEmpty,
      );
      expect(_of(_run(), 'nutrition.unlogged'), isEmpty);
    });

    test('N3 · macros known for under half the entries', () {
      Map<String, List<FoodEntry>> mixed(int known) => {
        for (var i = 1; i <= 5; i++)
          _ago(i): [
            i <= known
                ? foodOn(_ago(i), 500, protein: 30, carbs: 50, fat: 10)
                : foodOn(_ago(i), 500),
          ],
      };
      const goals = NutritionGoals(proteinG: 120);
      expect(
        _of(_run(food: mixed(2), goals: goals), 'nutrition.macro-coverage'),
        hasLength(1),
      );
      expect(
        _of(_run(food: mixed(3), goals: goals), 'nutrition.macro-coverage'),
        isEmpty,
      );
    });

    test('N4 · a general protein reference, never a goal (D39)', () {
      final food = days([1]);
      final withWeight = _of(
        _run(profile: const UserProfile(weightKg: 80), food: food),
        'nutrition.protein-reference',
      ).single;
      expect(withWeight.summary, contains('1,6–2,2 g de proteína por kg'));
      expect(withWeight.summary, contains('unos 128–176 g para tus 80 kg'));
      expect(withWeight.summary, contains('No es una dieta'));
      expect(withWeight.action, isA<OpenNutritionGoals>());
      final noWeight = _of(_run(food: food), 'nutrition.protein-reference');
      expect(noWeight.single.summary, contains('Si añades tu peso'));
      expect(
        _of(
          _run(food: food, goals: const NutritionGoals(proteinG: 100)),
          'nutrition.protein-reference',
        ),
        isEmpty,
      );
      expect(_of(_run(), 'nutrition.protein-reference'), isEmpty);
    });
  });

  group('logging rules', () {
    test('L1 · effort or technique missing on two exercises', () {
      final two = _run(
        history: [
          session('2026-09-29', [_noRir('squat'), _noRir('bench')]),
          session('2026-10-01', [_noRir('squat'), _noRir('bench')]),
        ],
      );
      expect(_of(two, 'logging.missing-effort'), hasLength(1));
      final one = _run(
        history: [
          session('2026-09-29', [_noRir('squat')]),
          session('2026-10-01', [_noRir('squat')]),
        ],
      );
      expect(_of(one, 'logging.missing-effort'), isEmpty);
    });

    test('L2 · three exercises ticked without sets in four weeks', () {
      ExerciseLog tick(String id) =>
          ExerciseLog(exerciseId: id, weightKg: 0, completed: true);
      expect(
        _of(
          _run(
            history: [
              session('2026-09-29', [tick('squat'), tick('rdl')]),
              session('2026-10-01', [tick('bench')]),
            ],
          ),
          'logging.done-without-sets',
        ),
        hasLength(1),
      );
      expect(
        _of(
          _run(
            history: [
              session('2026-09-29', [tick('squat'), tick('rdl')]),
            ],
          ),
          'logging.done-without-sets',
        ),
        isEmpty,
      );
    });
  });

  test('every date in the texts is a calendar date', () {
    expect(dateKey(monday), '2026-10-05');
  });
}
