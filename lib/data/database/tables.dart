// Drift's `check()` references the column being defined, which the analyzer
// reports as a recursive getter.
// ignore_for_file: recursive_getters
import 'package:drift/drift.dart';

import '../../domain/models/models.dart';

// Where a stored session came from. Imported 0.1 sessions have no per-set data.
enum SessionOrigin { legacySnapshotV1, app }

enum LegacyImportStatus { imported, skipped, absent }

// Enums are stored by name and not constrained in SQL, so new values do not
// need a table rebuild. Ranges are validated in Dart.

/// Single row (id = 1).
@DataClassName('ProfileRow')
class Profiles extends Table {
  IntColumn get id =>
      integer().withDefault(const Constant(1)).check(id.equals(1))();
  TextColumn get experience => textEnum<Experience>()();
  TextColumn get goal => textEnum<TrainingGoal>()();
  // Unknown stays null: it is never replaced by a default that looks real.
  RealColumn get weightKg => real().nullable()();
  IntColumn get age => integer().nullable()();
  TextColumn get energy => textEnum<Energy>()();
  TextColumn get note => text()();
  BoolColumn get onboarded => boolean()();
  TextColumn get lastReview => text().nullable()();
  // Comma-separated enum names / weekdays, in a fixed order.
  TextColumn get equipment => text().withDefault(
    const Constant('barbell,dumbbell,machine,cable,bodyweight'),
  )();
  TextColumn get trainingDays => text().withDefault(const Constant('2,4,6'))();
  IntColumn get sessionMinutes => integer().withDefault(const Constant(60))();
  BoolColumn get setupSkipped => boolean().withDefault(const Constant(false))();
  IntColumn get setupStep => integer().withDefault(const Constant(0))();
  // Display unit only; weights are always stored in kilograms.
  TextColumn get weightUnit =>
      textEnum<WeightUnit>().withDefault(const Constant('kg'))();
  // Date key until which the monthly review is postponed.
  TextColumn get reviewSnoozeUntil => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Append-only answers; [payload] is the profile as JSON.
@DataClassName('ProfileHistoryRow')
class ProfileHistory extends Table {
  TextColumn get id => text()();
  IntColumn get seq => integer().unique()();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get reason => textEnum<ProfileChange>()();
  TextColumn get payload => text()();
  // Coach rules version of a monthly review entry.
  TextColumn get rulesVersion => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Stored plan versions; [seq] is creation order (later versions win ties).
@DataClassName('PlanRow')
class PlanVersions extends Table {
  TextColumn get id => text()();
  IntColumn get seq => integer().unique()();
  TextColumn get status => textEnum<PlanStatus>()();
  TextColumn get source => textEnum<PlanSource>()();
  TextColumn get name => text()();
  TextColumn get effectiveFrom => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get acceptedAt => dateTime().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// A routine is one training day of one plan version. Sessions point at its
/// opaque [id] without a foreign key, so history never blocks plan changes.
@DataClassName('PlanRoutineRow')
class PlanRoutines extends Table {
  TextColumn get id => text()();
  TextColumn get planId =>
      text().references(PlanVersions, #id, onDelete: KeyAction.cascade)();
  IntColumn get weekday => integer().check(weekday.isBetweenValues(1, 7))();
  TextColumn get name => text()();
  TextColumn get focus => text()();
  TextColumn get warmup => text()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {planId, weekday},
  ];
}

@DataClassName('PlanExerciseRow')
class PlanRoutineExercises extends Table {
  TextColumn get routineId =>
      text().references(PlanRoutines, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().check(position.isBiggerOrEqualValue(0))();
  TextColumn get exerciseId => text()();
  IntColumn get sets => integer()();
  IntColumn get repsMin => integer()();
  IntColumn get repsMax => integer()();
  IntColumn get rir => integer()();
  IntColumn get restSeconds => integer()();
  RealColumn get incrementKg => real()();
  RealColumn get referenceWeightKg => real().nullable()();
  @override
  Set<Column> get primaryKey => {routineId, position};
}

/// Single row (id = 1).
@DataClassName('ReminderRow')
class Reminders extends Table {
  IntColumn get id =>
      integer().withDefault(const Constant(1)).check(id.equals(1))();
  BoolColumn get enabled => boolean()();
  IntColumn get hour => integer().check(hour.isBetweenValues(0, 23))();
  IntColumn get minute => integer().check(minute.isBetweenValues(0, 59))();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

/// One row per calendar date. [id] is opaque and stable.
@DataClassName('SessionRow')
class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get dateKey => text().unique()();
  TextColumn get routineId => text()();
  TextColumn get status => textEnum<SessionStatus>()();
  TextColumn get feeling => textEnum<Feeling>().nullable()();
  TextColumn get note => text()();
  TextColumn get origin => textEnum<SessionOrigin>()();
  // Null when the source had no timestamps (imported 0.1 data).
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Checklist entries of a session. [weightKg] is the reference weight shown
/// in Hoy, not a recorded performance.
@DataClassName('SessionExerciseRow')
@TableIndex(name: 'session_exercises_exercise', columns: {#exerciseId})
class SessionExercises extends Table {
  TextColumn get sessionId =>
      text().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text()();
  IntColumn get position => integer().check(position.isBiggerOrEqualValue(0))();
  RealColumn get weightKg => real().check(weightKg.isBiggerOrEqualValue(0))();
  BoolColumn get completed => boolean()();
  // Deliberately not done; never true together with [completed] (checked in
  // Dart, like the other cross-field rules).
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
  TextColumn get skipReason => text().nullable()();
  // Self-assessed technique; null until the person says so.
  TextColumn get technique => textEnum<TechniqueRating>().nullable()();
  @override
  Set<Column> get primaryKey => {sessionId, exerciseId};
}

/// Recorded sets of a session exercise, in [position] order. Weight, reps and
/// effort stay null until the person says so. Rows are matched to their
/// exercise by ([sessionId], [exerciseId]), never by position, so reordering
/// the checklist cannot move a log to another exercise.
@DataClassName('SetLogRow')
@TableIndex(name: 'set_logs_exercise', columns: {#sessionId, #exerciseId})
class SetLogs extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text()();
  IntColumn get position => integer().check(position.isBiggerOrEqualValue(0))();
  TextColumn get kind => textEnum<SetKind>()();
  IntColumn get number => integer().check(number.isBiggerOrEqualValue(1))();
  TextColumn get status => textEnum<SetStatus>()();
  RealColumn get weightKg =>
      real().nullable().check(weightKg.isBiggerOrEqualValue(0))();
  IntColumn get reps =>
      integer().nullable().check(reps.isBiggerOrEqualValue(0))();
  IntColumn get rir => integer().nullable().check(rir.isBetweenValues(0, 10))();
  TextColumn get skipReason => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {sessionId, exerciseId, position},
  ];
}

/// Audit trail of finished sessions that were edited again.
@DataClassName('SessionEventRow')
class SessionEvents extends Table {
  TextColumn get id => text()();
  IntColumn get seq => integer().unique()();
  TextColumn get dateKey => text()();
  TextColumn get kind => textEnum<SessionEventKind>()();
  DateTimeColumn get at => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

/// A session moved to another date. Undoing sets [undoneAt]; rows are never
/// deleted so the lineage ([parentId]) stays readable.
@DataClassName('RescheduleRow')
class Reschedules extends Table {
  TextColumn get id => text()();
  IntColumn get seq => integer().unique()();
  TextColumn get sourceDate => text()();
  TextColumn get targetDate => text()();
  TextColumn get kind => textEnum<RescheduleKind>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get undoneAt => dateTime().nullable()();
  TextColumn get parentId => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Accepted or rejected progression suggestions. The unique key makes a
/// second decision about the same suggestion impossible.
@DataClassName('ProgressionDecisionRow')
class ProgressionDecisions extends Table {
  TextColumn get id => text()();
  IntColumn get seq => integer().unique()();
  TextColumn get exerciseId => text()();
  TextColumn get ruleVersion => text()();
  TextColumn get kind => textEnum<ProgressionKind>()();
  TextColumn get basedOn => text()();
  TextColumn get status => textEnum<DecisionStatus>()();
  DateTimeColumn get decidedAt => dateTime()();
  RealColumn get fromKg => real().nullable()();
  RealColumn get toKg => real().nullable()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {exerciseId, basedOn, ruleVersion},
  ];
}

/// Finished monthly reviews, append-only. [answers] and [proposal] are JSON.
@DataClassName('MonthlyReviewRow')
class MonthlyReviews extends Table {
  TextColumn get id => text()();
  IntColumn get seq => integer().unique()();
  TextColumn get reviewedOn => text()();
  TextColumn get outcome => textEnum<ReviewOutcome>()();
  TextColumn get rulesVersion => text()();
  IntColumn get sessionsDone => integer()();
  IntColumn get sessionsDue => integer()();
  TextColumn get answers => text()();
  TextColumn get proposal => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

/// One row per cardio session; at most one is active (enforced by the
/// repository, whose writes are serialized). Segments hold the time.
@DataClassName('CardioSessionRow')
class CardioSessions extends Table {
  TextColumn get id => text()();
  IntColumn get seq => integer().unique()();
  TextColumn get activity => textEnum<CardioActivity>()();
  IntColumn get targetMinutes => integer().nullable()();
  TextColumn get status => textEnum<CardioStatus>()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  TextColumn get feedback => textEnum<Feeling>().nullable()();
  TextColumn get note => text()();
  BoolColumn get durationCorrected =>
      boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

/// A null [endedAt] is the segment running now.
@DataClassName('CardioSegmentRow')
class CardioSegments extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(CardioSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().check(position.isBiggerOrEqualValue(0))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get intensity => textEnum<CardioIntensity>()();
  RealColumn get weightKg =>
      real().nullable().check(weightKg.isBiggerOrEqualValue(0))();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {sessionId, position},
  ];
}

/// Per-date decision about the proposed lighter session: true accepted,
/// false reverted. No row means undecided.
@DataClassName('AdjustmentRow')
class SessionAdjustments extends Table {
  TextColumn get dateKey => text()();
  BoolColumn get applied => boolean()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {dateKey};
}

/// A null [routineId] is an explicit rest day.
@DataClassName('OverrideRow')
class CalendarOverrides extends Table {
  TextColumn get dateKey => text()();
  TextColumn get routineId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {dateKey};
}

@DataClassName('CheckInRow')
class CheckIns extends Table {
  TextColumn get id => text()();
  TextColumn get dateKey => text()();
  // Before training (the 0.1 check-in) or after it.
  TextColumn get phase =>
      textEnum<CheckInPhase>().withDefault(const Constant('before'))();
  TextColumn get feeling => textEnum<Feeling>()();
  TextColumn get note => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Set<Column>> get uniqueKeys => [
    {dateKey, phase},
  ];
}

/// [seq] keeps insertion order, which the UI reads as list order.
@DataClassName('FoodRow')
@TableIndex(name: 'food_entries_date_key', columns: {#dateKey})
class FoodEntries extends Table {
  TextColumn get id => text()();
  IntColumn get seq => integer().unique()();
  TextColumn get dateKey => text()();
  TextColumn get name => text()();
  IntColumn get calories => integer().check(calories.isBiggerOrEqualValue(0))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  // Portion and macros: null is "unknown", never zero.
  RealColumn get portion => real().nullable()();
  TextColumn get unit => text().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get carbsG => real().nullable()();
  RealColumn get fatG => real().nullable()();
  TextColumn get caloriesSource =>
      textEnum<CaloriesSource>().withDefault(const Constant('manual'))();
  TextColumn get recipeId => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Foods saved to log again; [seq] is the order they were added.
@DataClassName('FavoriteRow')
class FoodFavorites extends Table {
  TextColumn get id => text()();
  IntColumn get seq => integer().unique()();
  TextColumn get name => text()();
  IntColumn get calories => integer().check(calories.isBiggerOrEqualValue(0))();
  RealColumn get portion => real().nullable()();
  TextColumn get unit => text().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get carbsG => real().nullable()();
  RealColumn get fatG => real().nullable()();
  // Schema 7: favorites keep where their calories came from (D40).
  TextColumn get caloriesSource =>
      textEnum<CaloriesSource>().withDefault(const Constant('manual'))();
  @override
  Set<Column> get primaryKey => {id};
}

/// What the person did with the expert system's recommendations (schema 7,
/// D40). Append-only; accepting is final per [recKey] (checked by the
/// repository, since "Ahora no" can repeat).
@DataClassName('CoachDecisionRow')
class CoachDecisions extends Table {
  TextColumn get id => text()();
  IntColumn get seq => integer().unique()();
  TextColumn get recKey => text()();
  TextColumn get ruleId => text()();
  TextColumn get kbVersion => text()();
  TextColumn get subject => text()();
  TextColumn get anchor => text()();
  TextColumn get status => textEnum<CoachDecisionStatus>()();
  DateTimeColumn get decidedAt => dateTime()();
  TextColumn get summary => text()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Families of advice the person silenced (schema 7). [seq] keeps the order
/// they were first set.
@DataClassName('CoachPreferenceRow')
class CoachPreferences extends Table {
  TextColumn get family => text()();
  IntColumn get seq => integer().unique()();
  BoolColumn get muted => boolean()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {family};
}

/// [tags] and [allergens] are JSON lists; a null [allergens] means "not
/// declared".
@DataClassName('RecipeRow')
class Recipes extends Table {
  TextColumn get id => text()();
  IntColumn get seq => integer().unique()();
  TextColumn get name => text()();
  RealColumn get servings => real().check(servings.isBiggerThanValue(0))();
  TextColumn get notes => text()();
  TextColumn get tags => text()();
  TextColumn get allergens => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('IngredientRow')
class RecipeIngredients extends Table {
  TextColumn get recipeId =>
      text().references(Recipes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer().check(position.isBiggerOrEqualValue(0))();
  TextColumn get name => text()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  IntColumn get calories => integer().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get carbsG => real().nullable()();
  RealColumn get fatG => real().nullable()();
  @override
  Set<Column> get primaryKey => {recipeId, position};
}

/// Single row (id = 1); every target is optional.
@DataClassName('GoalsRow')
class NutritionGoalsTable extends Table {
  @override
  String get tableName => 'nutrition_goals';
  IntColumn get id =>
      integer().withDefault(const Constant(1)).check(id.equals(1))();
  IntColumn get kcal => integer().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get carbsG => real().nullable()();
  RealColumn get fatG => real().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

/// Idempotency marker: a source with a row here is never imported again.
/// [notes] holds repair codes only, never personal content.
@DataClassName('LegacyImportRow')
class LegacyImports extends Table {
  TextColumn get source => text()();
  TextColumn get status => textEnum<LegacyImportStatus>()();
  DateTimeColumn get importedAt => dateTime()();
  IntColumn get sessionCount => integer()();
  IntColumn get overrideCount => integer()();
  IntColumn get checkInCount => integer()();
  IntColumn get foodCount => integer()();
  TextColumn get notes => text()();
  @override
  Set<Column> get primaryKey => {source};
}
