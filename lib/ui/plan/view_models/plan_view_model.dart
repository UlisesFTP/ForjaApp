import '../../../core/date_utils.dart';
import '../../../core/ids.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/plan_editing.dart';
import '../../../domain/services/plan_generator.dart';
import '../../../domain/services/plan_proposal.dart';
import '../../core/view_model.dart';

class PlanViewModel extends ViewModel {
  PlanViewModel(
    this._workouts,
    this._plans,
    this._profiles,
    this._catalog, {
    DateTime Function()? clock,
    IdGenerator? newId,
  }) : _clock = clock ?? DateTime.now,
       _newId = newId ?? randomId {
    anchor = dateOnly(_clock());
    watch(_workouts);
    watch(_plans);
  }
  final WorkoutRepository _workouts;
  final PlanRepository _plans;
  final ProfileRepository _profiles;
  final ExerciseRepository _catalog;
  final DateTime Function() _clock;
  final IdGenerator _newId;
  late DateTime anchor;

  /// What the last "generate" produced, to show its notes.
  GeneratedPlan? proposal;

  List<DateTime> get week => weekOf(anchor);
  Routine? routineOn(DateTime date) => _workouts.routineOn(date);
  SessionStatus? statusOn(DateTime date) => _workouts.sessionOn(date)?.status;
  void changeWeek(int direction) {
    anchor = nextDay(anchor, direction * 7);
    notifyListeners();
  }

  DateTime get today => dateOnly(_clock());
  PlanVersion get activePlan => _plans.planFor(today);
  PlanVersion? get draft => _plans.draft;

  /// Accepted versions, newest first, including the built-in example only
  /// while no plan of the user's own applies.
  List<PlanVersion> get versions => [
    for (final p in _plans.plans.reversed)
      if (p.status == PlanStatus.accepted) p,
  ];

  /// A draft to edit: the pending one, or a copy of the plan in use.
  Future<bool> startEditing() => run(() async {
    if (_plans.draft != null) return;
    await _plans.saveDraft(
      cloneForEditing(activePlan, now: _clock().toUtc(), newId: _newId),
    );
  });

  Future<bool> generateFromProfile() => run(() async {
    proposal = await proposeDraft(
      plans: _plans,
      profile: _profiles.profile,
      catalog: _catalog,
      now: _clock().toUtc(),
      newId: _newId,
    );
    announce(
      proposal!.ok
          ? 'Borrador creado a partir de tu perfil.'
          : proposal!.failure!,
    );
  });

  Future<bool> discardDraft() =>
      run(_plans.discardDraft, success: 'Borrador descartado');
}
