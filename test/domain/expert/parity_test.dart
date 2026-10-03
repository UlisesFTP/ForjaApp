import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/app/app_dependencies.dart';
import 'package:forja_app/core/date_utils.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/data/services/forja_store.dart';
import 'package:forja_app/domain/expert/expert_coach.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/progression_engine.dart';
import 'package:forja_app/domain/services/training_rules.dart';
import 'package:forja_app/ui/coach/view_models/coach_inputs_builder.dart';

import 'expert_fixtures.dart';

String _describe(ProgressionSuggestion s) => [
  s.exerciseId,
  s.kind,
  s.rule,
  s.explanation,
  s.sessions,
  s.missing,
  s.fromKg,
  s.toKg,
].join('|');

void main() {
  group('the expert system keeps the existing rules exactly (D37)', () {
    test('the advice line of Hoy is TrainingRules.recommendation in every '
        'combination', () {
      final manual = examplePlan.copyWith(source: PlanSource.manual);
      var cases = 0;
      for (final feeling in [null, ...Feeling.values]) {
        for (final energy in Energy.values) {
          for (final experience in Experience.values) {
            for (final goal in TrainingGoal.values) {
              for (final plan in [examplePlan, manual]) {
                for (final adjustment in [null, true, false]) {
                  // Monday is a rest day, Tuesday a training day.
                  for (final today in [monday, nextDay(monday)]) {
                    final profile = UserProfile(
                      energy: energy,
                      experience: experience,
                      goal: goal,
                    );
                    final key = dateKey(today);
                    final result = ExpertCoach.evaluate(
                      coachInputs(
                        today: today,
                        profile: profile,
                        plan: plan,
                        adjustmentToday: adjustment,
                        checkIns: {
                          if (feeling != null) key: CheckIn(feeling: feeling),
                        },
                      ),
                    );
                    // As TodayViewModel computes it.
                    final training =
                        plan.routineOnWeekday(today.weekday) != null;
                    final proposed =
                        training &&
                        TrainingRules.needsLighterSession(profile, feeling);
                    final applied = proposed && adjustment != false;
                    expect(
                      result.todayLine,
                      TrainingRules.recommendation(
                        profile,
                        feeling,
                        adaptToProfile: plan.source == PlanSource.example,
                        adjust: applied,
                      ),
                    );
                    final lighter = result.recommendations.where(
                      (r) => r.ruleId == 'readiness.lighter-session',
                    );
                    expect(lighter, hasLength(proposed ? 1 : 0));
                    if (proposed) {
                      expect(lighter.single.summary, result.todayLine);
                    }
                    final injury = result.recommendations.where(
                      (r) => r.ruleId == 'safety.injury-today',
                    );
                    expect(
                      injury,
                      hasLength(feeling == Feeling.injured ? 1 : 0),
                    );
                    cases++;
                  }
                }
              }
            }
          }
        }
      }
      expect(cases, 6 * 3 * 3 * 3 * 2 * 3 * 2);
    });

    test('an increase is offered once, with the engine values, and not '
        'after a decision', () {
      final history = [
        session('2026-09-29', [logged('squat')]),
        session('2026-10-02', [logged('squat')]),
      ];
      final result = ExpertCoach.evaluate(coachInputs(history: history));
      final s = result.progression['squat']!;
      expect(s.kind, ProgressionKind.increase);
      final r = result.recommendations
          .where((r) => r.ruleId == 'progression.prog')
          .single;
      expect(r.kind, RecommendationKind.suggestion);
      expect(r.summary, s.explanation);
      final action = r.action! as IncreaseLoad;
      expect(action.fromKg, s.fromKg);
      expect(action.toKg, s.toKg);
      expect(action.basedOn, '2026-10-02');
      expect([for (final f in r.because) f.date].whereType<String>(), [
        '2026-09-29',
        '2026-10-02',
      ]);

      final decided = ExpertCoach.evaluate(
        coachInputs(
          history: history,
          decisions: [
            ProgressionDecision(
              id: 'd',
              exerciseId: 'squat',
              ruleVersion: progressionRulesVersion,
              kind: ProgressionKind.increase,
              basedOn: '2026-10-02',
              status: DecisionStatus.rejected,
              decidedAt: DateTime.utc(2026, 10, 3),
            ),
          ],
        ),
      );
      expect(
        decided.recommendations.where((r) => r.ruleId == 'progression.prog'),
        isEmpty,
      );
    });

    test('an injury today vetoes every increase and the engine already '
        'holds it back', () {
      final result = ExpertCoach.evaluate(
        coachInputs(
          history: [
            session('2026-09-29', [logged('squat')]),
            session('2026-10-02', [logged('squat')]),
          ],
          checkIns: {dateKey(monday): const CheckIn(feeling: Feeling.injured)},
        ),
      );
      expect(result.progression['squat']!.kind, ProgressionKind.blocked);
      expect(result.vetoes.any(VetoKind.loadIncrease), isTrue);
      final ids = result.recommendations.map((r) => r.ruleId);
      expect(ids, contains('safety.injury-today'));
      expect(ids, isNot(contains('progression.prog')));
    });

    test('two sessions below the minimum become a caution, never a '
        'decrease', () {
      final result = ExpertCoach.evaluate(
        coachInputs(
          history: [
            session('2026-09-29', [logged('squat', reps: 2)]),
            session('2026-10-02', [logged('squat', reps: 2)]),
          ],
        ),
      );
      final r = result.recommendations
          .where((r) => r.ruleId == 'progression.prog')
          .single;
      expect(r.kind, RecommendationKind.caution);
      expect(r.action, isA<OpenAlternatives>());
      expect(r.summary, result.progression['squat']!.explanation);
    });

    test('random histories: the same verdict as the Progress screen', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Random values are drawn here, never inside a repository closure.
      final random = Random(20261002);
      for (var round = 0; round < 12; round++) {
        final today = DateTime(2026, 11, 2);
        final d = await AppDependencies.create(
          store: MemoryForjaStore(),
          clock: () => today,
        );
        final tuesdays = [
          for (var i = 1; i <= 6; i++) nextDay(today, -7 * i + 1),
        ];
        for (final day in tuesdays) {
          for (final id in ['squat', 'rdl', 'press']) {
            if (random.nextInt(5) == 0) continue;
            final sets = random.nextInt(6);
            final kg = random.nextBool() ? 60.0 : 62.5;
            for (var s = 0; s < sets; s++) {
              final reps = random.nextInt(10) == 0
                  ? null
                  : 4 + random.nextInt(8);
              final rir = random.nextInt(8) == 0 ? null : random.nextInt(5);
              await d.repository.addSet(
                day,
                id,
                SetEntry(weightKg: kg, reps: reps, rir: rir),
              );
            }
            final technique = [
              null,
              TechniqueRating.solid,
              TechniqueRating.solid,
              TechniqueRating.unstable,
            ][random.nextInt(4)];
            await d.repository.setTechnique(day, id, technique);
            if (random.nextInt(5) != 0) {
              await d.repository.toggleExercise(day, id);
            }
          }
          if (random.nextInt(3) == 0) {
            await d.repository.saveCheckIn(
              day,
              CheckIn(feeling: Feeling.values[random.nextInt(5)]),
            );
          }
        }
        final result = ExpertCoach.evaluate(
          buildCoachInputs(
            today: today,
            workouts: d.repository,
            profiles: d.repository,
            plans: d.repository,
            progression: d.repository,
            catalog: d.repository,
            cardio: d.repository,
            nutrition: d.repository,
          ),
        );
        final screen = {
          for (final s in d.progression.suggestions) s.exerciseId: s,
        };
        expect(result.progression.keys.toSet(), screen.keys.toSet());
        for (final id in screen.keys) {
          expect(
            _describe(result.progression[id]!),
            _describe(screen[id]!),
            reason: 'round $round, $id',
          );
        }
        unawaited(d.dispose());
      }
    });
  });
}
