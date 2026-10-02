import '../../../core/date_utils.dart';
import '../../../core/ids.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/plan_generator.dart';
import '../../../domain/services/progress_stats.dart';
import '../../../domain/services/review_service.dart';
import '../../core/view_model.dart';

/// The monthly review: look back, answer, read the proposal, accept or
/// reject. Nothing is saved until the person decides, and neither choice
/// touches past sessions or the plan in use.
class ReviewViewModel extends ViewModel {
  ReviewViewModel(
    this._profiles,
    this._plans,
    this._workouts,
    this._catalog, {
    DateTime Function()? clock,
    IdGenerator? newId,
  }) : _clock = clock ?? DateTime.now,
       _newId = newId ?? randomId {
    watch(_profiles);
    watch(_plans);
    watch(_workouts);
  }
  final ProfileRepository _profiles;
  final PlanRepository _plans;
  final WorkoutRepository _workouts;
  final ExerciseRepository _catalog;
  final DateTime Function() _clock;
  final IdGenerator _newId;

  UserProfile get profile => _profiles.profile;
  List<MonthlyReview> get history => _profiles.reviews;
  DateTime get today => dateOnly(_clock());

  /// Offered discreetly; never blocks Hoy.
  ReviewStatus get status => ReviewService.status(profile, today);
  bool get due => status.due;

  late ReviewAnswers answers = ReviewAnswers.from(profile);
  ReviewProposal? proposal;
  GeneratedPlan? generated;
  List<String> comparison = const [];

  /// Starts a fresh review from the current profile.
  void begin() {
    answers = ReviewAnswers.from(profile);
    proposal = null;
    generated = null;
    comparison = const [];
    error = null;
    notifyListeners();
  }

  void answer(ReviewAnswers value) {
    answers = value;
    proposal = null;
    notifyListeners();
  }

  /// The last 30 days as the rules see them: completed against planned and
  /// already due, and the days with tiredness or an injury.
  ReviewMonth get month {
    final end = today, start = nextDay(end, -ReviewService.periodDays + 1);
    final c = ProgressStats.compliance(
      sessions: _workouts.history,
      reschedules: _workouts.reschedules,
      start: start,
      end: end,
      today: end,
      planned: (d) => _workouts.routineOn(d) != null,
    );
    var fatigue = 0, injury = 0;
    for (var d = start; !d.isAfter(end); d = nextDay(d)) {
      final feeling = _workouts.checkInOn(d)?.feeling;
      if (feeling == Feeling.injured) {
        injury++;
      } else if (feeling == Feeling.tired || feeling == Feeling.doms) {
        fatigue++;
      }
    }
    return ReviewMonth(
      done: c.done,
      due: c.due,
      fatigueDays: fatigue,
      injuryDays: injury,
    );
  }

  /// Builds the proposal and, if the answers change the plan, the draft it
  /// would create. Saves nothing.
  void propose() {
    final result = ReviewService.propose(
      current: profile,
      answers: answers,
      month: month,
    );
    proposal = result;
    generated = null;
    comparison = const [];
    final changed = _planFieldsChanged(profile, result.profile);
    final manual = _plans.draft?.source == PlanSource.manual;
    if (changed && !manual) {
      final plan = PlanGenerator.generate(
        result.profile,
        catalog: _catalog.exercises,
        now: _clock().toUtc(),
        newId: _newId,
      );
      generated = plan;
      if (plan.draft != null) {
        comparison = ReviewService.comparePlans(
          _workouts.planFor(today),
          plan.draft!,
        );
      }
    }
    notifyListeners();
  }

  /// True when something the plan is built from changed.
  bool get changesPlan =>
      proposal != null &&
      _planFieldsChanged(profile, proposal!.profile) &&
      _plans.draft?.source != PlanSource.manual;
  bool get keepsManualDraft =>
      proposal != null &&
      _planFieldsChanged(profile, proposal!.profile) &&
      _plans.draft?.source == PlanSource.manual;
  String? get failure => generated?.failure;

  static bool _planFieldsChanged(UserProfile a, UserProfile b) =>
      a.goal != b.goal ||
      a.energy != b.energy ||
      a.sessionMinutes != b.sessionMinutes ||
      a.equipment.length != b.equipment.length ||
      !a.equipment.containsAll(b.equipment) ||
      a.trainingDays.join(',') != b.trainingDays.join(',');

  MonthlyReview _record(ReviewOutcome outcome) {
    final m = month;
    return MonthlyReview(
      id: _newId(),
      reviewedOn: dateKey(today),
      outcome: outcome,
      rulesVersion: reviewRulesVersion,
      sessionsDone: m.done,
      sessionsDue: m.due,
      answers: answers.toJson(),
      proposal: proposal?.notes ?? const [],
      createdAt: _clock().toUtc(),
    );
  }

  /// Applies the answers and stores the proposed plan as a draft to review in
  /// Plan (it takes effect only from the date chosen there).
  Future<bool> accept() => run(() async {
    final p = proposal;
    if (p == null) throw StateError('Primero revisa la propuesta.');
    if (changesPlan && generated?.draft == null) {
      throw StateError(
        generated?.failure ?? 'No se pudo preparar el plan propuesto.',
      );
    }
    await _profiles.completeReview(
      _record(ReviewOutcome.accepted),
      profile: p.profile,
      draft: changesPlan ? generated?.draft : null,
    );
    announce(
      changesPlan
          ? 'Revisión guardada. Hay un borrador de plan para revisar.'
          : 'Revisión guardada.',
    );
  });

  /// Keeps everything as it is and records that the review was done.
  Future<bool> reject() => run(() async {
    await _profiles.completeReview(_record(ReviewOutcome.rejected));
    announce('Revisión guardada sin cambios.');
  });

  Future<bool> postpone() => run(
    () => _profiles.snoozeReview(ReviewService.snoozeUntil(today)),
    success: 'Te lo recordaremos dentro de ${ReviewService.snoozeDays} días.',
  );
}
