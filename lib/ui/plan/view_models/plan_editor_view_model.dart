import '../../../core/date_utils.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/exercise_library.dart';
import '../../../domain/services/plan_generator.dart';
import '../../../domain/services/plan_validator.dart';
import '../../core/view_model.dart';

/// Edits a working copy of the draft. Nothing is stored until the person
/// saves, so leaving the editor never half-changes a plan.
class PlanEditorViewModel extends ViewModel {
  PlanEditorViewModel(
    this._plans,
    this._catalog,
    this._profiles, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    final stored = _plans.draft;
    if (stored == null) {
      throw StateError('Create a draft before editing it.');
    }
    _saved = stored;
    working = stored;
    watch(_plans);
  }
  final PlanRepository _plans;
  final ExerciseRepository _catalog;
  final ProfileRepository _profiles;
  final DateTime Function() _clock;
  late PlanVersion _saved;
  late PlanVersion working;

  bool get dirty => !identical(working, _saved);
  Exercise exercise(String id) => _catalog.exerciseById(id);
  List<Exercise> get catalog => _catalog.exercises;
  Set<Equipment> get myEquipment => {
    ..._profiles.profile.equipment,
    Equipment.bodyweight,
  };

  /// Compatible substitutes for the exercise at [index] of routine [day].
  List<Exercise> alternatives(int day, int index) {
    final current = exercise(
      working.days[day].routine.exercises[index].exerciseId,
    );
    final taken = working.days[day].routine.exerciseIds;
    return [
      for (final e in alternativesFor(current, catalog, myEquipment))
        if (!taken.contains(e.id)) e,
    ];
  }

  /// Problems that would stop the plan from being accepted.
  List<String> get issues => PlanValidator.validate(
    working,
    forAcceptance: true,
    isKnown: (id) => !exercise(id).archived,
  );

  int minutes(Routine routine) =>
      PlanGenerator.routineMinutes(routine, exercise);

  void _set(PlanVersion next) {
    working = next;
    notifyListeners();
  }

  void renamePlan(String name) => _set(working.copyWith(name: name));

  PlanVersion _withRoutine(int day, Routine Function(Routine) change) =>
      working.copyWith(
        days: [
          for (var i = 0; i < working.days.length; i++)
            i == day
                ? PlanDay(
                    working.days[i].weekday,
                    change(working.days[i].routine),
                  )
                : working.days[i],
        ],
      );

  void renameRoutine(int day, String name) =>
      _set(_withRoutine(day, (r) => r.copyWith(name: name)));

  /// Moves a routine to another weekday; the weekdays must stay distinct.
  bool setWeekday(int day, int weekday) {
    if (working.days.any((d) => d.weekday == weekday)) return false;
    _set(
      working.copyWith(
        days: [
          for (var i = 0; i < working.days.length; i++)
            i == day
                ? PlanDay(weekday, working.days[i].routine)
                : working.days[i],
        ],
      ),
    );
    return true;
  }

  void moveExercise(int day, int from, int to) => _set(
    _withRoutine(day, (r) {
      final list = [...r.exercises];
      if (from < 0 || from >= list.length || to < 0 || to >= list.length) {
        return r;
      }
      list.insert(to, list.removeAt(from));
      return r.copyWith(exercises: list);
    }),
  );

  void removeExercise(int day, int index) => _set(
    _withRoutine(
      day,
      (r) => r.copyWith(exercises: [...r.exercises]..removeAt(index)),
    ),
  );

  /// Adds [exercise] with its default prescription. Returns false when the
  /// routine already has it.
  bool addExercise(int day, Exercise exercise) {
    final routine = working.days[day].routine;
    if (routine.exerciseIds.contains(exercise.id)) return false;
    _set(
      _withRoutine(
        day,
        (r) => r.copyWith(
          exercises: [...r.exercises, PlanExercise.fromExercise(exercise)],
        ),
      ),
    );
    return true;
  }

  /// Swaps the exercise at [index] for [replacement], keeping its place.
  bool replaceExercise(int day, int index, Exercise replacement) {
    final routine = working.days[day].routine;
    final others = [...routine.exerciseIds]..removeAt(index);
    if (others.contains(replacement.id)) return false;
    _set(
      _withRoutine(day, (r) {
        final list = [...r.exercises];
        list[index] = PlanExercise.fromExercise(replacement);
        return r.copyWith(exercises: list);
      }),
    );
    return true;
  }

  void updateExercise(int day, int index, PlanExercise value) => _set(
    _withRoutine(day, (r) {
      final list = [...r.exercises];
      list[index] = value;
      return r.copyWith(exercises: list);
    }),
  );

  Future<bool> save() => run(() async {
    await _plans.saveDraft(working);
    _saved = _plans.draft ?? working;
    working = _saved;
  }, success: 'Borrador guardado');

  /// Dates the plan can start from: today, or the next Monday.
  List<DateTime> get startOptions {
    final today = dateOnly(_clock());
    final monday = nextDay(today, 8 - today.weekday);
    return [today, monday];
  }

  Future<bool> accept(DateTime from) => run(() async {
    await _plans.saveDraft(working);
    await _plans.acceptDraft(from);
  }, success: 'Plan aceptado');

  Future<bool> discard() =>
      run(_plans.discardDraft, success: 'Borrador descartado');
}
