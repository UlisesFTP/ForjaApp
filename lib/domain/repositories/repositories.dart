import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/reschedule_planner.dart';

// Views and ViewModels depend on these contracts, never on a storage plugin.
abstract class WorkoutRepository implements Listenable {
  Routine? routineOn(DateTime date);
  Routine routineById(String id);
  PlanVersion planFor(DateTime date);
  WorkoutSession? sessionOn(DateTime date);
  List<WorkoutSession> get history;

  /// How the person felt before training / after it. Null: no answer.
  CheckIn? checkInOn(DateTime date);
  CheckIn? afterCheckInOn(DateTime date);

  /// The decision about the lighter-session proposal: true accepted, false
  /// reverted, null undecided (the proposal stands).
  bool? adjustmentOn(DateTime date);
  List<SessionEvent> eventsOn(DateTime date);

  /// All moves ever made, oldest first (undone ones are marked).
  List<Reschedule> get reschedules;

  /// The load a new session starts from for this exercise: the latest
  /// accepted progression, else null (the plan's reference weight applies).
  double? workingWeight(String exerciseId);

  /// Self-assessed technique of an exercise in a session (null = unknown).
  Future<void> setTechnique(
    DateTime date,
    String exerciseId,
    TechniqueRating? rating,
  );

  /// Moves that still stand and bring a session onto / out of [date].
  Reschedule? rescheduleInto(DateTime date);
  Reschedule? rescheduleFrom(DateTime date);
  Future<void> toggleExercise(DateTime date, String exerciseId);
  Future<void> updateWeight(DateTime date, String exerciseId, double weight);
  Future<void> reorder(DateTime date, List<String> exerciseIds);

  /// Records one set. Editing a finished session reopens it (audited).
  Future<void> addSet(DateTime date, String exerciseId, SetEntry entry);
  Future<void> updateSet(
    DateTime date,
    String exerciseId,
    String setId,
    SetEntry entry,
  );
  Future<void> removeSet(DateTime date, String exerciseId, String setId);

  /// Marks the exercise as deliberately not done (a reason is required) or
  /// brings it back to pending.
  Future<void> setSkipped(
    DateTime date,
    String exerciseId,
    bool skipped, {
    String? reason,
  });

  /// Puts a completed session back in progress and records it.
  Future<void> reopenSession(DateTime date);
  Future<void> saveCheckIn(
    DateTime date,
    CheckIn checkIn, {
    CheckInPhase phase = CheckInPhase.before,
  });
  Future<void> setAdjustment(DateTime date, bool applied);

  /// What [finishSession] would move and where, without saving anything.
  ReschedulePreview previewReschedule(DateTime date, SessionStatus status);

  /// Why [target] cannot be picked by hand for a move out of [source], or
  /// null when it can; and the back-to-back warnings of any date.
  String? rescheduleProblem(DateTime source, DateTime target);
  List<String> rescheduleWarnings(
    DateTime source,
    SessionStatus status,
    DateTime target,
  );

  /// Whether the destination of [move] is still untouched, so it can be
  /// undone.
  bool canUndo(Reschedule move);

  /// Finishes the session. Returns the date pending work moved to, or null
  /// when nothing moved. [moveTo] overrides the suggested date; with
  /// [reschedule] false the result is saved and the pending stay in place.
  Future<DateTime?> finishSession(
    DateTime date,
    SessionStatus status, {
    DateTime? moveTo,
    bool reschedule = true,
  });

  /// Cancels a move while its destination has not been started. Repeating it
  /// does nothing.
  Future<void> undoReschedule(String id);
}

abstract class ProgressionRepository implements Listenable {
  /// Accepted and rejected suggestions, oldest first.
  List<ProgressionDecision> get progressionDecisions;

  /// Records a decision. The first one for a suggestion (exercise, last
  /// session it was based on, rules version) is final: deciding again does
  /// nothing, so an increase is never applied twice.
  Future<void> decideProgression({
    required String exerciseId,
    required ProgressionKind kind,
    required String basedOn,
    required String ruleVersion,
    required DecisionStatus status,
    double? fromKg,
    double? toKg,
  });
}

abstract class CardioRepository implements Listenable {
  /// The running or paused session, if any.
  CardioSession? get activeCardio;

  /// Finished sessions, newest first.
  List<CardioSession> get cardioHistory;

  /// Starts a session. Only one can be active. [at] is the start instant
  /// (UTC); the body weight of the profile is captured with the segment.
  Future<void> startCardio({
    required CardioActivity activity,
    required CardioIntensity intensity,
    required DateTime at,
    int? targetMinutes,
  });

  /// Closes the running segment at [at] (the session is paused).
  Future<void> pauseCardio(DateTime at);

  /// Opens a new segment, optionally at another intensity.
  Future<void> resumeCardio(DateTime at, {CardioIntensity? intensity});

  /// Closes the running segment and opens another at the new intensity.
  Future<void> changeCardioIntensity(DateTime at, CardioIntensity intensity);

  /// Saves the session once. [correctedDuration] replaces the measured time
  /// (for an incoherent clock) by shortening or lengthening the last segment.
  /// Finishing an already finished session does nothing.
  Future<void> finishCardio(
    String id,
    DateTime at, {
    Duration? correctedDuration,
    Feeling? feedback,
    String note = '',
  });

  /// Throws the active session away. Discarding it twice does nothing.
  Future<void> discardCardio(String id);
}

abstract class ExerciseRepository {
  List<Exercise> get exercises;
  Exercise exerciseById(String id);
}

abstract class PlanRepository implements Listenable {
  /// Stored versions in creation order (the built-in example is not included).
  List<PlanVersion> get plans;
  PlanVersion? get draft;
  PlanVersion planFor(DateTime date);

  /// Stores [draft], replacing the current one. A different draft that was
  /// pending is kept as rejected.
  Future<void> saveDraft(PlanVersion draft);
  Future<void> discardDraft();

  /// Turns the draft into an accepted version that applies from
  /// [effectiveFrom]. Earlier dates and past sessions are never touched.
  Future<void> acceptDraft(DateTime effectiveFrom);
}

abstract class ProfileRepository implements Listenable {
  UserProfile get profile;
  List<ProfileAnswer> get profileHistory;

  /// Saves [profile]. A non-null [record] also appends it to the answer
  /// history with that reason; null is used for onboarding progress.
  Future<void> saveProfile(UserProfile profile, {ProfileChange? record});

  /// Finished monthly reviews, oldest first.
  List<MonthlyReview> get reviews;

  /// Hides the review until [until] (a postponement).
  Future<void> snoozeReview(DateTime until);

  /// Stores a review in one step. Accepted: [profile] (the answers applied)
  /// and [draft] (the proposed plan, if any) are saved with it. Rejected:
  /// nothing changes except the review date. Repeating it does nothing.
  Future<void> completeReview(
    MonthlyReview review, {
    UserProfile? profile,
    PlanVersion? draft,
  });
}

abstract class NutritionRepository implements Listenable {
  List<FoodEntry> foodOn(DateTime date);
  Future<void> addFood(FoodEntry entry);

  /// Replaces an entry of the same id in one step (an edit is atomic).
  Future<void> updateFood(FoodEntry entry);
  Future<void> removeFood(String id);

  /// Puts back an entry that was just removed (undo). Nothing happens if an
  /// entry with that id exists.
  Future<void> restoreFood(FoodEntry entry);

  List<FavoriteFood> get favorites;
  Future<void> addFavorite(FavoriteFood food);
  Future<void> removeFavorite(String id);

  List<Recipe> get recipes;

  /// Creates or replaces a recipe (matched by id).
  Future<void> saveRecipe(Recipe recipe);
  Future<void> deleteRecipe(String id);

  NutritionGoals get goals;
  Future<void> saveGoals(NutritionGoals goals);
}

abstract class SettingsRepository implements Listenable {
  ReminderSettings get reminder;
  Future<void> saveReminder(ReminderSettings settings);
}
