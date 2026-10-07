import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/core/date_utils.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/domain/expert/expert_coach.dart';
import 'package:forja_app/domain/expert/knowledge/knowledge_base.dart';
import 'package:forja_app/domain/models/models.dart';

import 'expert_fixtures.dart';

/// Words the local coach never uses about itself or the person (D37): it is
/// not a diagnosis, not a treatment, not an AI, and it never blames.
final _forbidden = <RegExp>[
  RegExp(r'\bIA\b'),
  RegExp(r'prescrip', caseSensitive: false),
  RegExp(r'\btratamiento', caseSensitive: false),
  RegExp(r'\bcura\b', caseSensitive: false),
  RegExp(r'garantiz', caseSensitive: false),
  RegExp(r'\bculpa\b', caseSensitive: false),
  RegExp(r'fracas', caseSensitive: false),
  RegExp(r'perezos', caseSensitive: false),
  RegExp(r'deberías haber', caseSensitive: false),
  RegExp(r'fallaste', caseSensitive: false),
];

List<String> _lint(String text) {
  final problems = [
    for (final r in _forbidden)
      if (r.hasMatch(text)) r.pattern,
  ];
  // "diagnóstico" only to say what it is not.
  final diagnosis = RegExp(r'diagn[oó]stic', caseSensitive: false);
  if (diagnosis.hasMatch(text) &&
      !RegExp(
        r'no (es )?(un )?diagn[oó]stic',
        caseSensitive: false,
      ).hasMatch(text)) {
    problems.add('diagnóstico');
  }
  return problems;
}

/// A random but plausible state of the app, drawn entirely from [random].
CoachInputs _randomInputs(Random random) {
  T pick<T>(List<T> items) => items[random.nextInt(items.length)];
  final today = monday;
  final plan = random.nextBool()
      ? legacyTemplatePlan
      : examplePlanCopy(pick([PlanSource.manual, PlanSource.generated]));
  final profile = UserProfile(
    experience: pick(Experience.values),
    goal: pick(TrainingGoal.values),
    energy: pick(Energy.values),
    onboarded: random.nextBool(),
    age: pick([null, 16, 30, 70]),
    weightKg: pick([null, 55.0, 80.0]),
    sessionMinutes: pick([30, 45, 60, 90]),
    equipment: {
      Equipment.bodyweight,
      for (final e in Equipment.values)
        if (random.nextInt(3) > 0) e,
    },
  );
  final history = <WorkoutSession>[];
  final checkIns = <String, CheckIn>{};
  final after = <String, CheckIn>{};
  for (var i = 70; i >= 0; i--) {
    final day = nextDay(today, -i), key = dateKey(day);
    if (random.nextInt(6) == 0) {
      checkIns[key] = CheckIn(feeling: pick(Feeling.values));
    }
    if (random.nextInt(9) == 0) {
      after[key] = CheckIn(feeling: pick(Feeling.values));
    }
    final routine = plan.routineOnWeekday(day.weekday);
    if (routine == null || random.nextInt(4) == 0) continue;
    // A third of the sessions are perfect, so increases do come up.
    if (random.nextInt(3) == 0) {
      history.add(
        session(key, [for (final p in routine.exercises) logged(p.exerciseId)]),
      );
      continue;
    }
    final logs = <ExerciseLog>[
      for (final p in routine.exercises)
        if (random.nextInt(5) > 0)
          ExerciseLog(
            exerciseId: p.exerciseId,
            weightKg: 60,
            completed: random.nextInt(4) > 0,
            technique: pick([
              null,
              TechniqueRating.solid,
              TechniqueRating.unstable,
            ]),
            sets: [
              for (var s = 1; s <= random.nextInt(p.sets + 2); s++)
                workSet(
                  s,
                  kg: pick([null, 60.0, 62.5]),
                  reps: random.nextInt(8) == 0 ? null : 3 + random.nextInt(14),
                  rir: random.nextInt(6) == 0 ? null : random.nextInt(5),
                ),
            ],
          ),
    ];
    history.add(
      session(
        key,
        logs,
        status: pick([
          SessionStatus.completed,
          SessionStatus.completed,
          SessionStatus.partial,
          SessionStatus.missed,
          SessionStatus.scheduled,
        ]),
      ),
    );
  }
  final food = <String, List<FoodEntry>>{
    for (var i = 0; i < 14; i++)
      if (random.nextInt(3) > 0)
        dateKey(nextDay(today, -i)): [
          for (var k = 0; k < 1 + random.nextInt(3); k++)
            foodOn(
              dateKey(nextDay(today, -i)),
              100 + random.nextInt(900),
              protein: random.nextBool() ? 10.0 + random.nextInt(40) : null,
              carbs: random.nextBool() ? 50 : null,
              fat: random.nextBool() ? 10 : null,
              id: 'f$i-$k',
            ),
        ],
  };
  return coachInputs(
    today: today,
    profile: profile,
    plan: plan,
    history: history,
    checkIns: checkIns,
    afterCheckIns: after,
    adjustmentToday: pick([null, true, false]),
    reviews: [
      if (random.nextBool())
        reviewOn(
          dateKey(nextDay(today, -random.nextInt(40))),
          pain: random.nextBool(),
        ),
    ],
    cardio: [
      for (var i = 0; i < random.nextInt(5); i++)
        cardioOn(
          dateKey(nextDay(today, -random.nextInt(30))),
          10 + random.nextInt(60),
          activity: pick(CardioActivity.values),
          intensity: pick(CardioIntensity.values),
          feedback: pick([null, ...Feeling.values]),
          id: 'c$i',
        ),
    ],
    food: food,
    goals: random.nextBool()
        ? const NutritionGoals()
        : NutritionGoals(
            kcal: pick([null, 700, 1100, 2200]),
            proteinG: pick([null, 120.0]),
          ),
  );
}

bool _injuredWithin14(CoachInputs i) {
  final from = dateKey(nextDay(i.today, -13)), to = dateKey(i.today);
  bool inside(String k) => k.compareTo(from) >= 0 && k.compareTo(to) <= 0;
  return [
    ...i.checkIns.entries,
    ...i.afterCheckIns.entries,
  ].any((e) => e.value.feeling == Feeling.injured && inside(e.key));
}

void main() {
  group('expert-v1 properties on random histories', () {
    // Drawn up front, outside any closure.
    final random = Random(20261002);
    final cases = [for (var i = 0; i < 300; i++) _randomInputs(random)];

    test('an injury in the last 14 days leaves no increase to accept', () {
      // The same cases without the injury do offer increases: the property
      // is not true by accident.
      var offered = 0;
      for (final inputs in cases) {
        offered += ExpertCoach.evaluate(inputs).recommendations
            .where((r) => r.action?.raisesLoad ?? false)
            .length;
      }
      expect(offered, greaterThan(20));
      var injured = 0;
      for (final inputs in cases) {
        if (!_injuredWithin14(inputs)) continue;
        injured++;
        final result = ExpertCoach.evaluate(inputs);
        for (final r in result.recommendations) {
          expect(r.action?.raisesLoad ?? false, isFalse, reason: r.key);
        }
      }
      expect(injured, greaterThan(20));
    });

    test('never a lighter week and more volume to accept at once', () {
      for (final inputs in cases) {
        final result = ExpertCoach.evaluate(inputs);
        final deload = result.recommendations.any(
          (r) => r.ruleId == 'readiness.deload',
        );
        if (!deload) continue;
        for (final r in result.recommendations) {
          expect(r.action?.raisesVolume ?? false, isFalse, reason: r.key);
        }
      }
    });

    test('every recommendation names a registered rule, its evidence and '
        'why; keys are unique; same data, same answer', () {
      for (final inputs in cases) {
        final result = ExpertCoach.evaluate(inputs);
        final again = ExpertCoach.evaluate(inputs);
        expect(
          [for (final r in again.recommendations) '${r.key}${r.summary}'],
          [for (final r in result.recommendations) '${r.key}${r.summary}'],
        );
        final keys = <String>{};
        for (final r in result.recommendations) {
          expect(ruleById(r.ruleId), isNotNull, reason: r.ruleId);
          expect(keys.add(r.key), isTrue, reason: r.key);
          expect(r.because, isNotEmpty, reason: r.key);
          expect(r.title, isNotEmpty);
          expect(r.summary, isNotEmpty);
          expect(r.evidence.source, isNotEmpty);
          if (r.kind == RecommendationKind.blocked) {
            expect(r.action, isNull);
            expect(ruleById(r.vetoedBy!), isNotNull);
          }
        }
        expect(result.kbVersion, 'expert-v1');
      }
    });

    test('a minor never gets nutrition ranges', () {
      for (final inputs in cases) {
        if ((inputs.profile.age ?? 99) >= 18) continue;
        expect(
          ExpertCoach.evaluate(inputs).recommendations
              .where((r) => r.ruleId == 'nutrition.protein-reference'),
          isEmpty,
        );
      }
    });

    test('the texts never diagnose, prescribe, promise or blame', () {
      final seen = <String>{};
      for (final inputs in cases) {
        for (final r in ExpertCoach.evaluate(inputs).recommendations) {
          seen.add(r.ruleId);
          for (final text in [
            r.title,
            r.summary,
            r.threshold ?? '',
            for (final f in r.because) f.toString(),
          ]) {
            expect(_lint(text), isEmpty, reason: '${r.ruleId}: $text');
          }
        }
      }
      // The random cases reach most of the knowledge base.
      expect(seen.length, greaterThanOrEqualTo(18));
      // And the source of every rule, in case a text is rarely produced.
      for (final f in Directory(
        'lib/domain/expert/knowledge',
      ).listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final strings = RegExp(r"'([^'\\]|\\.)*'")
            .allMatches(f.readAsStringSync());
        for (final m in strings) {
          expect(
            _lint(m.group(0)!),
            isEmpty,
            reason: '${f.path}: ${m.group(0)}',
          );
        }
      }
    });

    test('the lint itself catches what it should', () {
      expect(_lint('Esto es un diagnóstico.'), isNotEmpty);
      expect(_lint('No es un diagnóstico.'), isEmpty);
      expect(_lint('Consejo de la IA'), isNotEmpty);
      expect(_lint('Te garantizamos resultados'), isNotEmpty);
      expect(_lint('Una dieta así'), isEmpty);
    });

    test('two years of history are evaluated quickly', () {
      final history = <WorkoutSession>[];
      for (var i = 730; i >= 1; i--) {
        final day = nextDay(monday, -i);
        final routine = legacyTemplatePlan.routineOnWeekday(day.weekday);
        if (routine == null) continue;
        history.add(
          session(dateKey(day), [
            for (final p in routine.exercises) logged(p.exerciseId, reps: 6),
          ]),
        );
      }
      final inputs = coachInputs(
        profile: const UserProfile(onboarded: true, weightKg: 75),
        history: history,
      );
      final watch = Stopwatch()..start();
      final result = ExpertCoach.evaluate(inputs);
      watch.stop();
      expect(history.length, greaterThan(300));
      expect(result.recommendations, isNotEmpty);
      expect(watch.elapsedMilliseconds, lessThan(1500));
    });
  });

  group('expert-v1 exact texts', () {
    test('safety and nutrition texts are pinned', () {
      String summary(ExpertResult r, String id) =>
          r.recommendations.firstWhere((x) => x.ruleId == id).summary;
      expect(
        summary(
          ExpertCoach.evaluate(
            coachInputs(
              checkIns: {
                daysBefore(monday, 3): const CheckIn(feeling: Feeling.injured),
              },
            ),
          ),
          'safety.injury-recent',
        ),
        'Registraste una lesión el 2 oct. Durante 14 días desde entonces no se '
        'sugieren aumentos de carga. Si el dolor sigue o empeora, consulta a un '
        'profesional de la salud.',
      );
      expect(
        summary(
          ExpertCoach.evaluate(
            coachInputs(
              history: [
                session(daysBefore(monday, 10), [logged('squat')]),
              ],
            ),
          ),
          'safety.return-after-break',
        ),
        'Llevas 10 días sin entrenar: retoma con las mismas cargas y deja 1–2 '
        'repeticiones más en reserva las primeras sesiones.',
      );
      expect(
        summary(
          ExpertCoach.evaluate(
            coachInputs(goals: const NutritionGoals(kcal: 750)),
          ),
          'safety.kcal-goal',
        ),
        'Tu objetivo de 750 kcal al día está por debajo de 800: una dieta así '
        'solo debe seguirse con supervisión médica.',
      );
      expect(
        summary(
          ExpertCoach.evaluate(
            coachInputs(
              profile: const UserProfile(weightKg: 70),
              food: {
                daysBefore(monday, 1): [foodOn(daysBefore(monday, 1), 600)],
              },
            ),
          ),
          'nutrition.protein-reference',
        ),
        'Referencia general para adultos que entrenan fuerza: 1,6–2,2 g de '
        'proteína por kg al día (unos 112–154 g para tus 70 kg), repartidos en '
        '3–4 comidas. No es una dieta ni un objetivo calculado para ti: puedes '
        'fijar tus propios objetivos.',
      );
    });
  });
}
