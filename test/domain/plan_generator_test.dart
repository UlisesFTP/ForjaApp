import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/core/ids.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/plan_generator.dart';
import 'package:forja_app/domain/services/plan_validator.dart';

final now = DateTime.utc(2026, 10, 1);

IdGenerator counter() {
  var n = 0;
  return () => 'id${n++}';
}

GeneratedPlan generate(UserProfile profile) => PlanGenerator.generate(
  profile,
  catalog: exerciseCatalog,
  now: now,
  newId: counter(),
);

Iterable<Exercise> exercisesOf(PlanVersion plan) => [
  for (final r in plan.routines)
    for (final e in r.exercises) exerciseFor(e.exerciseId),
];

void main() {
  test('a beginner gets three full-body days on the chosen weekdays', () {
    final result = generate(
      const UserProfile(
        experience: Experience.beginner,
        trainingDays: [DateTime.saturday, DateTime.monday, DateTime.thursday],
      ),
    );
    final plan = result.draft!;
    expect(result.ok, isTrue);
    expect(plan.status, PlanStatus.draft);
    expect(plan.source, PlanSource.generated);
    expect(plan.effectiveFrom, isNull);
    expect(
      [for (final d in plan.days) d.weekday],
      [DateTime.monday, DateTime.thursday, DateTime.saturday],
    );
    expect(plan.routines.map((r) => r.name), [
      'Cuerpo completo A',
      'Cuerpo completo B',
      'Cuerpo completo C',
    ]);
    // Beginners start with fewer sets and more reserve.
    for (final e in plan.routines.expand((r) => r.exercises)) {
      expect(e.sets, lessThanOrEqualTo(2));
      expect(e.rir, 3);
    }
  });
  test('others get a push, pull and legs split', () {
    final plan = generate(const UserProfile()).draft!;
    expect(plan.routines.map((r) => r.name), ['Empuje', 'Tirón', 'Pierna']);
    expect(plan.name, 'Plan de 3 días · Ganar fuerza');
  });
  test('only exercises the equipment allows are chosen', () {
    final plan = generate(const UserProfile(equipment: {Equipment.dumbbell}))
        .draft!;
    expect(
      exercisesOf(plan).map((e) => e.equipment).toSet(),
      everyElement(isIn({Equipment.dumbbell, Equipment.bodyweight})),
    );
  });
  test('body weight is available even when no equipment is ticked', () {
    final result = generate(
      const UserProfile(experience: Experience.beginner, equipment: {}),
    );
    expect(result.ok, isTrue);
    expect(exercisesOf(result.draft!).map((e) => e.equipment).toSet(), {
      Equipment.bodyweight,
    });
  });
  test('an impossible combination explains itself instead of returning an empty plan', () {
    final result = generate(
      const UserProfile(experience: Experience.advanced, equipment: {}),
    );
    expect(result.ok, isFalse);
    expect(result.draft, isNull);
    expect(
      result.failure,
      contains('no hay suficientes ejercicios compatibles'),
    );
  });
  test('three distinct days are required', () {
    for (final days in [
      const [DateTime.monday, DateTime.monday, DateTime.friday],
      const [DateTime.monday, DateTime.friday],
      const [1, 2, 3, 4],
      const [0, 2, 4],
    ]) {
      final result = generate(UserProfile(trainingDays: days));
      expect(result.ok, isFalse, reason: '$days');
      expect(result.failure, contains('tres días'));
    }
  });
  test('more time means more exercises, and a session fits its time', () {
    int count(int minutes) =>
        generate(UserProfile(sessionMinutes: minutes)).draft!.routines
            .map((r) => r.exercises.length)
            .reduce((a, b) => a < b ? a : b);
    expect(count(30), lessThan(count(90)));
    for (final minutes in [30, 45, 60, 75, 90]) {
      final plan = generate(UserProfile(sessionMinutes: minutes)).draft!;
      for (final routine in plan.routines) {
        final estimate = PlanGenerator.routineMinutes(routine, exerciseFor);
        // Never over the budget unless already at the minimum of three.
        expect(
          estimate <= minutes || routine.exercises.length == 3,
          isTrue,
          reason: '$minutes min → ${routine.name} $estimate min',
        );
      }
    }
  });
  test('the goal sets the rep range, but never for timed holds', () {
    PlanExercise first(TrainingGoal goal, String id) =>
        generate(
              UserProfile(
                goal: goal,
                experience: Experience.intermediate,
                sessionMinutes: 90,
              ),
            ).draft!.routines
            .expand((r) => r.exercises)
            .firstWhere((e) => e.exerciseId == id);
    expect(first(TrainingGoal.muscle, 'bench').repsMin, 8);
    expect(first(TrainingGoal.muscle, 'bench').repsMax, 12);
    expect(first(TrainingGoal.fitness, 'bench').repsMin, 12);
    expect(first(TrainingGoal.fitness, 'bench').repsMax, 15);
    expect(first(TrainingGoal.strength, 'bench').repsMin, 6);
    final plank =
        generate(
              const UserProfile(
                goal: TrainingGoal.fitness,
                sessionMinutes: 90,
                equipment: {},
                experience: Experience.beginner,
              ),
            ).draft!.routines
            .expand((r) => r.exercises)
            .where((e) => e.exerciseId == 'plank');
    expect(plank, isNotEmpty);
    for (final e in plank) {
      expect([e.repsMin, e.repsMax], [30, 45]);
    }
  });
  test('low habitual energy trims sets and adds reserve', () {
    PlanExercise squat(Energy energy) =>
        generate(UserProfile(energy: energy)).draft!.routines
            .expand((r) => r.exercises)
            .firstWhere((e) => e.exerciseId == 'squat');
    expect(squat(Energy.normal).sets, 4);
    expect(squat(Energy.low).sets, 3);
    expect(squat(Energy.low).rir, 3);
  });
  test(
    'exercises are not repeated across days when there are alternatives',
    () {
      final plan = generate(const UserProfile(sessionMinutes: 75)).draft!;
      final ids = plan.routines.expand((r) => r.exerciseIds).toList();
      expect(ids.toSet().length, ids.length);
      for (final routine in plan.routines) {
        expect(routine.exerciseIds.toSet().length, routine.exerciseIds.length);
      }
    },
  );
  test('the same inputs always give the same plan', () {
    final a = generate(const UserProfile()).draft!;
    final b = generate(const UserProfile()).draft!;
    expect(jsonEncode(a.toJson()), jsonEncode(b.toJson()));
  });
  test('every combination is valid or explains why not', () {
    for (final experience in Experience.values) {
      for (final goal in TrainingGoal.values) {
        for (final energy in Energy.values) {
          for (final minutes in [30, 45, 60, 75, 90]) {
            for (final equipment in [
              <Equipment>{},
              {Equipment.dumbbell},
              {Equipment.barbell, Equipment.machine},
              {...Equipment.values},
            ]) {
              final result = generate(
                UserProfile(
                  experience: experience,
                  goal: goal,
                  energy: energy,
                  sessionMinutes: minutes,
                  equipment: equipment,
                ),
              );
              final label = '$experience $goal $energy $minutes $equipment';
              if (result.ok) {
                expect(
                  PlanValidator.validate(
                    result.draft!,
                    forAcceptance: true,
                    isKnown: (id) => !exerciseFor(id).archived,
                  ),
                  isEmpty,
                  reason: label,
                );
                for (final r in result.draft!.routines) {
                  expect(
                    r.exercises.length,
                    inInclusiveRange(3, 7),
                    reason: label,
                  );
                }
              } else {
                expect(result.failure, isNotEmpty, reason: label);
              }
            }
          }
        }
      }
    }
  });
  test('the draft says it is not a personalized prescription', () {
    final result = generate(const UserProfile());
    expect(
      result.notes.last,
      allOf(contains('no una prescripción personalizada'), contains('edítalo')),
    );
    expect(result.notes.length, 4);
  });
}
