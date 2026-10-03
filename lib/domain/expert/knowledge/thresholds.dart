/// Every number the knowledge base uses, in one place, so each can be
/// reviewed against its source. The level of support is in the rule that
/// uses it (see `evidence.dart`).
class Thresholds {
  const Thresholds._();

  // Safety.
  /// An injury check-in (before or after training) vetoes increases this long.
  static const injuryVetoDays = 14;

  /// A review that answered "pain" vetoes increases this long after it.
  static const reviewPainVetoDays = 14;

  /// Days without training after which loads are kept, and after which they
  /// are rebuilt.
  static const breakKeepLoadDays = 8;
  static const breakRebuildDays = 21;

  /// Injury check-ins on at least this many dates, the first and last this
  /// far apart, within this window: suggest seeing a professional.
  static const painPersistsDates = 2;
  static const painPersistsGapDays = 7;
  static const painPersistsWindowDays = 28;

  static const adultAge = 18;

  /// The person's own daily calorie goal under these values gets a caution.
  static const kcalGoalCaution = 1200;
  static const kcalGoalMedical = 800;

  // Progression.
  /// A suggested step larger than this share of the load gets a caution.
  static const bigStepShare = 0.10;

  /// Complete sessions in a row at the same load without more reps.
  static const stallSessions = 3;

  // Fatigue.
  static const deloadWindowDays = 14;
  static const deloadMinSignalKinds = 2;
  static const fatigueDays = 2;
  static const reviewExercises = 2;
  static const rirZeroSessions = 2;
  static const rirZeroTargetAtLeast = 2;

  // Plan and volume.
  static const minWeeklySets = 4;
  static const maxWeeklySets = 20;
  static const extraMinutes = 15;
  static const draftReviewDays = 3;

  // Adherence.
  static const unrecordedDays = 7;
  static const lowAdherence = 0.6;

  // Cardio (WHO 2020).
  static const whoWeeklyMin = 150;
  static const whoWeeklyMax = 300;
  static const moderateMet = 3.0;
  static const vigorousMet = 6.0;
  static const comparableCardioDays = 21;
  static const comparableDurationShare = 0.10;

  // Nutrition.
  static const loggedDaysForAverage = 4;
  static const unloggedDaysTip = 3;
  static const macroCoverageTip = 0.5;
  static const proteinMinGPerKg = 1.6;
  static const proteinMaxGPerKg = 2.2;

  // Logging.
  static const missingDataExercises = 2;
  static const doneWithoutSets = 3;
}
