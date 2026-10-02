// Immutable application models. These do not depend on Flutter widgets.
import 'exercise.dart';
import 'plan.dart';

export 'exercise.dart';
export 'plan.dart';

enum Experience { beginner, intermediate, advanced }

enum TrainingGoal { strength, muscle, fitness }

enum Energy { low, normal, high }

enum Feeling { tired, normal, energetic, doms, injured }

enum SessionStatus { scheduled, completed, partial, missed }

enum CardioActivity { walk, treadmill, bicycle, elliptical }

enum CardioIntensity { low, moderate, high }

/// An active session is running or paused; finishing makes it history.
enum CardioStatus { active, finished }

/// Why a profile version was recorded in the answer history.
enum ProfileChange { onboarding, skipped, edit, review, reviewRejected }

/// How the person reads and types weights. Storage is always kilograms.
enum WeightUnit { kg, lb }

enum SetKind { warmup, work }

enum SetStatus { done, skipped }

/// Which moment of the day a check-in describes.
enum CheckInPhase { before, after }

enum SessionEventKind { reopened }

/// Self-assessed technique of an exercise in one session. Unknown (null) is
/// not "solid": progression needs it said.
enum TechniqueRating { solid, unstable }

/// What the progression engine suggests for an exercise.
enum ProgressionKind { increase, hold, review, blocked }

enum DecisionStatus { accepted, rejected }

enum ReviewOutcome { accepted, rejected }

class UserProfile {
  const UserProfile({
    this.experience = Experience.intermediate,
    this.goal = TrainingGoal.strength,
    this.weightKg,
    this.age,
    this.energy = Energy.normal,
    this.note = '',
    this.onboarded = false,
    this.lastReview,
    this.equipment = const {...Equipment.values},
    this.trainingDays = const [
      DateTime.tuesday,
      DateTime.thursday,
      DateTime.saturday,
    ],
    this.sessionMinutes = 60,
    this.skippedSetup = false,
    this.setupStep = 0,
    this.unit = WeightUnit.kg,
    this.reviewSnoozeUntil,
  });
  final Experience experience;
  final TrainingGoal goal;
  // Unknown until the user says so: never a default that looks like data.
  final double? weightKg;
  final int? age;
  final Energy energy;
  final String note;
  final bool onboarded;
  final String? lastReview;
  final Set<Equipment> equipment;
  // Exactly three distinct weekdays (DateTime.monday … DateTime.sunday).
  final List<int> trainingDays;
  final int sessionMinutes;
  // The user chose the example plan and may finish the setup later.
  final bool skippedSetup;
  // First unanswered onboarding step, so it can be resumed.
  final int setupStep;
  final WeightUnit unit;
  // The monthly review is hidden until this date (a postponed review).
  final String? reviewSnoozeUntil;

  UserProfile copyWith({
    Experience? experience,
    TrainingGoal? goal,
    double? Function()? weightKg,
    int? Function()? age,
    Energy? energy,
    String? note,
    bool? onboarded,
    String? Function()? lastReview,
    Set<Equipment>? equipment,
    List<int>? trainingDays,
    int? sessionMinutes,
    bool? skippedSetup,
    int? setupStep,
    WeightUnit? unit,
    String? Function()? reviewSnoozeUntil,
  }) => UserProfile(
    experience: experience ?? this.experience,
    goal: goal ?? this.goal,
    weightKg: weightKg == null ? this.weightKg : weightKg(),
    age: age == null ? this.age : age(),
    energy: energy ?? this.energy,
    note: note ?? this.note,
    onboarded: onboarded ?? this.onboarded,
    lastReview: lastReview == null ? this.lastReview : lastReview(),
    equipment: equipment ?? this.equipment,
    trainingDays: trainingDays ?? this.trainingDays,
    sessionMinutes: sessionMinutes ?? this.sessionMinutes,
    skippedSetup: skippedSetup ?? this.skippedSetup,
    setupStep: setupStep ?? this.setupStep,
    unit: unit ?? this.unit,
    reviewSnoozeUntil: reviewSnoozeUntil == null
        ? this.reviewSnoozeUntil
        : reviewSnoozeUntil(),
  );

  /// The eight fields 0.1 stored.
  Map<String, dynamic> legacyJson() => {
    'experience': experience.name,
    'goal': goal.name,
    'weightKg': weightKg,
    'age': age,
    'energy': energy.name,
    'note': note,
    'onboarded': onboarded,
    'lastReview': lastReview,
  };
  Map<String, dynamic> toJson() => {
    ...legacyJson(),
    'equipment': [
      for (final e in Equipment.values)
        if (equipment.contains(e)) e.name,
    ],
    'trainingDays': trainingDays,
    'sessionMinutes': sessionMinutes,
    'skippedSetup': skippedSetup,
    'setupStep': setupStep,
    'unit': unit.name,
    'reviewSnoozeUntil': reviewSnoozeUntil,
  };

  /// Reads a profile written by [toJson]. Missing newer fields take defaults;
  /// a field of the wrong type is an error, never silently replaced.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    T pick<T extends Enum>(List<T> values, String key, T fallback) {
      final value = json[key];
      if (value == null) return fallback;
      return values.firstWhere(
        (e) => e.name == value,
        orElse: () => throw FormatException('Invalid $key'),
      );
    }

    T? typed<T>(String key) {
      final value = json[key];
      if (value == null) return null;
      if (value is! T) throw FormatException('Invalid $key');
      return value;
    }

    final equipment = typed<List>('equipment');
    final days = typed<List>('trainingDays');
    return UserProfile(
      experience: pick(
        Experience.values,
        'experience',
        Experience.intermediate,
      ),
      goal: pick(TrainingGoal.values, 'goal', TrainingGoal.strength),
      weightKg: typed<num>('weightKg')?.toDouble(),
      age: typed<int>('age'),
      energy: pick(Energy.values, 'energy', Energy.normal),
      note: typed<String>('note') ?? '',
      onboarded: typed<bool>('onboarded') ?? false,
      lastReview: typed<String>('lastReview'),
      equipment: equipment == null
          ? const {...Equipment.values}
          : {
              for (final name in equipment)
                Equipment.values.firstWhere(
                  (e) => e.name == name,
                  orElse: () =>
                      throw const FormatException('Invalid equipment'),
                ),
            },
      trainingDays: days == null
          ? const [DateTime.tuesday, DateTime.thursday, DateTime.saturday]
          : [for (final d in days) d as int],
      sessionMinutes: typed<int>('sessionMinutes') ?? 60,
      skippedSetup: typed<bool>('skippedSetup') ?? false,
      setupStep: typed<int>('setupStep') ?? 0,
      unit: pick(WeightUnit.values, 'unit', WeightUnit.kg),
      reviewSnoozeUntil: typed<String>('reviewSnoozeUntil'),
    );
  }
}

/// A profile as it was answered at one moment. Append-only history.
class ProfileAnswer {
  const ProfileAnswer({
    required this.id,
    required this.recordedAt,
    required this.reason,
    required this.profile,
    this.rulesVersion,
  });
  final String id;
  final DateTime recordedAt;
  final ProfileChange reason;
  final UserProfile profile;
  // Version of the coach rules that produced a review; null otherwise.
  final String? rulesVersion;
  Map<String, dynamic> toJson() => {
    'id': id,
    'recordedAt': recordedAt.toUtc().toIso8601String(),
    'reason': reason.name,
    'profile': profile.toJson(),
    'rulesVersion': rulesVersion,
  };
}

/// One recorded set. Weight, reps and effort are unknown (null) until the
/// person says so: an empty field is never stored as 0.
class SetLog {
  const SetLog({
    required this.id,
    required this.kind,
    required this.number,
    this.status = SetStatus.done,
    this.weightKg,
    this.reps,
    this.rir,
    this.skipReason,
  });
  final String id;
  final SetKind kind;
  // 1-based within its kind for the exercise.
  final int number;
  final SetStatus status;
  final double? weightKg;
  final int? reps;
  // Repetitions in reserve actually felt, 0–10.
  final int? rir;
  final String? skipReason;
  bool get isDone => status == SetStatus.done;

  SetLog copyWith({
    int? number,
    SetStatus? status,
    double? Function()? weightKg,
    int? Function()? reps,
    int? Function()? rir,
    String? Function()? skipReason,
  }) => SetLog(
    id: id,
    kind: kind,
    number: number ?? this.number,
    status: status ?? this.status,
    weightKg: weightKg == null ? this.weightKg : weightKg(),
    reps: reps == null ? this.reps : reps(),
    rir: rir == null ? this.rir : rir(),
    skipReason: skipReason == null ? this.skipReason : skipReason(),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'number': number,
    'status': status.name,
    'weightKg': weightKg,
    'reps': reps,
    'rir': rir,
    'skipReason': skipReason,
  };
}

/// What the person typed for a set; the repository assigns id and number.
/// Null weight, reps or effort mean "not recorded".
class SetEntry {
  const SetEntry({
    this.kind = SetKind.work,
    this.status = SetStatus.done,
    this.weightKg,
    this.reps,
    this.rir,
    this.skipReason,
  });
  final SetKind kind;
  final SetStatus status;
  final double? weightKg;
  final int? reps;
  final int? rir;
  final String? skipReason;
}

/// An exercise inside a session. One tap marks it [completed] without any
/// per-set data (compliance only); [skipped] is a deliberate "not done".
class ExerciseLog {
  ExerciseLog({
    required this.exerciseId,
    required this.weightKg,
    this.completed = false,
    this.skipped = false,
    this.skipReason,
    this.technique,
    List<SetLog> sets = const [],
  }) : sets = List.unmodifiable(sets),
       assert(!(completed && skipped), 'An exercise cannot be both');
  final String exerciseId;
  // Reference weight shown on the card, never a recorded performance.
  final double weightKg;
  final bool completed, skipped;
  final String? skipReason;
  final TechniqueRating? technique;
  final List<SetLog> sets;
  bool get resolved => completed || skipped;
  List<SetLog> get workSets => [
    for (final s in sets)
      if (s.kind == SetKind.work && s.isDone) s,
  ];
  ExerciseLog copyWith({
    double? weightKg,
    bool? completed,
    bool? skipped,
    String? Function()? skipReason,
    TechniqueRating? Function()? technique,
    List<SetLog>? sets,
  }) => ExerciseLog(
    exerciseId: exerciseId,
    weightKg: weightKg ?? this.weightKg,
    completed: completed ?? this.completed,
    skipped: skipped ?? this.skipped,
    skipReason: skipReason == null ? this.skipReason : skipReason(),
    technique: technique == null ? this.technique : technique(),
    sets: sets ?? this.sets,
  );

  /// The three fields 0.1 stored.
  Map<String, dynamic> legacyJson() => {
    'exerciseId': exerciseId,
    'weightKg': weightKg,
    'completed': completed,
  };
  Map<String, dynamic> toJson() => {
    ...legacyJson(),
    'skipped': skipped,
    'skipReason': skipReason,
    'technique': technique?.name,
    'sets': sets.map((s) => s.toJson()).toList(),
  };
}

class WorkoutSession {
  WorkoutSession({
    required this.dateKey,
    required this.routineId,
    required List<ExerciseLog> exercises,
    this.status = SessionStatus.scheduled,
    this.feeling,
    this.note = '',
  }) : exercises = List.unmodifiable(exercises);
  final String dateKey, routineId, note;
  final List<ExerciseLog> exercises;
  final SessionStatus status;
  final Feeling? feeling;
  int get completedCount => exercises.where((e) => e.completed).length;
  int get skippedCount => exercises.where((e) => e.skipped).length;
  int get resolvedCount => exercises.where((e) => e.resolved).length;
  bool get allCompleted =>
      exercises.isNotEmpty && completedCount == exercises.length;
  // Every exercise is done or deliberately skipped.
  bool get allResolved =>
      exercises.isNotEmpty && resolvedCount == exercises.length;
  WorkoutSession copyWith({
    List<ExerciseLog>? exercises,
    SessionStatus? status,
    Feeling? feeling,
    String? note,
  }) => WorkoutSession(
    dateKey: dateKey,
    routineId: routineId,
    exercises: exercises ?? this.exercises,
    status: status ?? this.status,
    feeling: feeling ?? this.feeling,
    note: note ?? this.note,
  );
  Map<String, dynamic> legacyJson() => {
    'dateKey': dateKey,
    'routineId': routineId,
    'exercises': exercises.map((e) => e.legacyJson()).toList(),
    'status': status.name,
    'feeling': feeling?.name,
    'note': note,
  };
  Map<String, dynamic> toJson() => {
    ...legacyJson(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}

enum RescheduleKind { missed, partial }

/// A session moved to another date. Lineage is kept: moving an already moved
/// session points back at the earlier move through [parentId].
class Reschedule {
  const Reschedule({
    required this.id,
    required this.sourceDate,
    required this.targetDate,
    required this.kind,
    required this.createdAt,
    this.undoneAt,
    this.parentId,
  });
  final String id, sourceDate, targetDate;
  final RescheduleKind kind;
  final DateTime createdAt;
  final DateTime? undoneAt;
  final String? parentId;
  bool get active => undoneAt == null;
  Reschedule copyWith({DateTime? undoneAt}) => Reschedule(
    id: id,
    sourceDate: sourceDate,
    targetDate: targetDate,
    kind: kind,
    createdAt: createdAt,
    undoneAt: undoneAt ?? this.undoneAt,
    parentId: parentId,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceDate': sourceDate,
    'targetDate': targetDate,
    'kind': kind.name,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'undoneAt': undoneAt?.toUtc().toIso8601String(),
    'parentId': parentId,
  };
}

/// Audit trail of changes to a finished session.
class SessionEvent {
  const SessionEvent({
    required this.id,
    required this.dateKey,
    required this.kind,
    required this.at,
  });
  final String id, dateKey;
  final SessionEventKind kind;
  final DateTime at;
  Map<String, dynamic> toJson() => {
    'id': id,
    'dateKey': dateKey,
    'kind': kind.name,
    'at': at.toUtc().toIso8601String(),
  };
}

/// A suggestion the person accepted or rejected. Append-only: the first
/// decision about an exercise at a given point is final, so deciding twice
/// never applies it twice.
class ProgressionDecision {
  const ProgressionDecision({
    required this.id,
    required this.exerciseId,
    required this.ruleVersion,
    required this.kind,
    required this.basedOn,
    required this.status,
    required this.decidedAt,
    this.fromKg,
    this.toKg,
  });
  final String id, exerciseId, ruleVersion;
  final ProgressionKind kind;
  // Date of the latest session the suggestion was based on.
  final String basedOn;
  final DecisionStatus status;
  final DateTime decidedAt;
  final double? fromKg, toKg;
  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'ruleVersion': ruleVersion,
    'kind': kind.name,
    'basedOn': basedOn,
    'status': status.name,
    'decidedAt': decidedAt.toUtc().toIso8601String(),
    'fromKg': fromKg,
    'toKg': toKg,
  };
}

/// A finished monthly review: what was answered, what the rules proposed and
/// what the person decided. Immutable once stored.
class MonthlyReview {
  const MonthlyReview({
    required this.id,
    required this.reviewedOn,
    required this.outcome,
    required this.rulesVersion,
    required this.sessionsDone,
    required this.sessionsDue,
    required this.answers,
    required this.proposal,
    required this.createdAt,
  });
  final String id, reviewedOn, rulesVersion;
  final ReviewOutcome outcome;
  // Adherence over the reviewed month: completed / planned and already due.
  final int sessionsDone, sessionsDue;
  final Map<String, Object?> answers;
  // Plain-language lines of what was proposed.
  final List<String> proposal;
  final DateTime createdAt;
  Map<String, dynamic> toJson() => {
    'id': id,
    'reviewedOn': reviewedOn,
    'outcome': outcome.name,
    'rulesVersion': rulesVersion,
    'sessionsDone': sessionsDone,
    'sessionsDue': sessionsDue,
    'answers': answers,
    'proposal': proposal,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}

/// A stretch of a cardio session with one intensity and one body weight.
/// Pausing closes the segment; continuing opens a new one. The session's time
/// is the sum of its segments, so it can be rebuilt from timestamps alone.
class CardioSegment {
  const CardioSegment({
    required this.id,
    required this.startedAt,
    required this.intensity,
    this.endedAt,
    this.weightKg,
  });
  final String id;
  // UTC.
  final DateTime startedAt;
  // Null while the segment is running.
  final DateTime? endedAt;
  final CardioIntensity intensity;
  // Body weight when the segment started; null if the person never gave one.
  // Later profile edits never change it.
  final double? weightKg;
  bool get running => endedAt == null;
  Duration duration(DateTime now) {
    final d = (endedAt ?? now).difference(startedAt);
    return d.isNegative ? Duration.zero : d;
  }

  CardioSegment closedAt(DateTime end) => CardioSegment(
    id: id,
    startedAt: startedAt,
    endedAt: end,
    intensity: intensity,
    weightKg: weightKg,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'endedAt': endedAt?.toUtc().toIso8601String(),
    'intensity': intensity.name,
    'weightKg': weightKg,
  };
}

class CardioSession {
  CardioSession({
    required this.id,
    required this.activity,
    required this.startedAt,
    required List<CardioSegment> segments,
    this.targetMinutes,
    this.status = CardioStatus.active,
    this.finishedAt,
    this.feedback,
    this.note = '',
    this.durationCorrected = false,
  }) : segments = List.unmodifiable(segments);
  final String id;
  final CardioActivity activity;
  final DateTime startedAt;
  final List<CardioSegment> segments;
  final int? targetMinutes;
  final CardioStatus status;
  final DateTime? finishedAt;
  // How the person felt afterwards; null if not said.
  final Feeling? feedback;
  final String note;
  // The duration was fixed by hand after an incoherent clock.
  final bool durationCorrected;

  bool get active => status == CardioStatus.active;
  bool get running =>
      active && segments.isNotEmpty && segments.last.endedAt == null;
  bool get paused => active && !running;
  CardioSegment? get current => running ? segments.last : null;
  Duration duration(DateTime now) =>
      segments.fold(Duration.zero, (sum, s) => sum + s.duration(now));

  CardioSession copyWith({
    List<CardioSegment>? segments,
    CardioStatus? status,
    DateTime? finishedAt,
    Feeling? Function()? feedback,
    String? note,
    bool? durationCorrected,
  }) => CardioSession(
    id: id,
    activity: activity,
    startedAt: startedAt,
    segments: segments ?? this.segments,
    targetMinutes: targetMinutes,
    status: status ?? this.status,
    finishedAt: finishedAt ?? this.finishedAt,
    feedback: feedback == null ? this.feedback : feedback(),
    note: note ?? this.note,
    durationCorrected: durationCorrected ?? this.durationCorrected,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'activity': activity.name,
    'startedAt': startedAt.toUtc().toIso8601String(),
    'targetMinutes': targetMinutes,
    'status': status.name,
    'finishedAt': finishedAt?.toUtc().toIso8601String(),
    'feedback': feedback?.name,
    'note': note,
    'durationCorrected': durationCorrected,
    'segments': segments.map((s) => s.toJson()).toList(),
  };
}

class CheckIn {
  const CheckIn({required this.feeling, this.note = ''});
  final Feeling feeling;
  final String note;
  Map<String, dynamic> toJson() => {'feeling': feeling.name, 'note': note};
}

/// Where an entry's calories came from. A manual number is explicit data and
/// is never overwritten; one worked out from macros says so.
enum CaloriesSource { manual, macros, recipe }

class FoodEntry {
  const FoodEntry({
    required this.id,
    required this.dateKey,
    required this.name,
    required this.calories,
    this.portion,
    this.unit,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.caloriesSource = CaloriesSource.manual,
    this.recipeId,
  });
  final String id, dateKey, name;
  final int calories;
  // Quantity eaten and its unit ("g", "ml", "porción"); unknown is null.
  final double? portion;
  final String? unit;
  // Macros in grams. Unknown is null: it is never counted as 0 g.
  final double? proteinG, carbsG, fatG;
  final CaloriesSource caloriesSource;
  // The recipe this entry was logged from, if any.
  final String? recipeId;
  bool get hasMacros => proteinG != null || carbsG != null || fatG != null;

  FoodEntry copyWith({
    String? dateKey,
    String? name,
    int? calories,
    double? Function()? portion,
    String? Function()? unit,
    double? Function()? proteinG,
    double? Function()? carbsG,
    double? Function()? fatG,
    CaloriesSource? caloriesSource,
  }) => FoodEntry(
    id: id,
    dateKey: dateKey ?? this.dateKey,
    name: name ?? this.name,
    calories: calories ?? this.calories,
    portion: portion == null ? this.portion : portion(),
    unit: unit == null ? this.unit : unit(),
    proteinG: proteinG == null ? this.proteinG : proteinG(),
    carbsG: carbsG == null ? this.carbsG : carbsG(),
    fatG: fatG == null ? this.fatG : fatG(),
    caloriesSource: caloriesSource ?? this.caloriesSource,
    recipeId: recipeId,
  );

  /// The four fields 0.1 stored.
  Map<String, dynamic> legacyJson() => {
    'id': id,
    'dateKey': dateKey,
    'name': name,
    'calories': calories,
  };
  Map<String, dynamic> toJson() => {
    ...legacyJson(),
    'portion': portion,
    'unit': unit,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
    'caloriesSource': caloriesSource.name,
    'recipeId': recipeId,
  };
}

/// kcal from macros with the general Atwater factors (4·protein + 4·carbs +
/// 9·fat). Null unless all three are known: a missing macro is not 0 g.
int? caloriesFromMacros(double? protein, double? carbs, double? fat) =>
    protein == null || carbs == null || fat == null
    ? null
    : (4 * protein + 4 * carbs + 9 * fat).round();

/// A food saved to log again in one tap.
class FavoriteFood {
  const FavoriteFood({
    required this.id,
    required this.name,
    required this.calories,
    this.portion,
    this.unit,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });
  final String id, name;
  final int calories;
  final double? portion;
  final String? unit;
  final double? proteinG, carbsG, fatG;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'calories': calories,
    'portion': portion,
    'unit': unit,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
  };
}

class Ingredient {
  const Ingredient({
    required this.name,
    this.quantity,
    this.unit,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });
  final String name;
  final double? quantity;
  final String? unit;
  // For the quantity listed; unknown is null.
  final int? calories;
  final double? proteinG, carbsG, fatG;
  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'calories': calories,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
  };
}

/// The person's own recipe. Totals exist only when every ingredient has the
/// value: a recipe with a missing ingredient says "unknown", not a smaller
/// number.
class Recipe {
  Recipe({
    required this.id,
    required this.name,
    required this.servings,
    required List<Ingredient> ingredients,
    required this.createdAt,
    this.notes = '',
    List<String> tags = const [],
    List<String>? allergens,
  }) : ingredients = List.unmodifiable(ingredients),
       tags = List.unmodifiable(tags),
       allergens = allergens == null ? null : List.unmodifiable(allergens);
  final String id, name, notes;
  final double servings;
  final List<Ingredient> ingredients;
  final DateTime createdAt;
  // Preferences the person declared ("vegetariana", "sin gluten", ...).
  final List<String> tags;
  // Declared allergens; null means "not declared", which is not "none".
  final List<String>? allergens;

  int? get totalCalories => _sumInt((i) => i.calories);
  double? get totalProteinG => _sum((i) => i.proteinG);
  double? get totalCarbsG => _sum((i) => i.carbsG);
  double? get totalFatG => _sum((i) => i.fatG);
  int? get caloriesPerServing {
    final t = totalCalories;
    return t == null ? null : (t / servings).round();
  }

  double? _sum(double? Function(Ingredient) pick) {
    if (ingredients.isEmpty) return null;
    var total = 0.0;
    for (final i in ingredients) {
      final v = pick(i);
      if (v == null) return null;
      total += v;
    }
    return total;
  }

  int? _sumInt(int? Function(Ingredient) pick) {
    if (ingredients.isEmpty) return null;
    var total = 0;
    for (final i in ingredients) {
      final v = pick(i);
      if (v == null) return null;
      total += v;
    }
    return total;
  }

  Recipe copyWith({
    String? name,
    double? servings,
    List<Ingredient>? ingredients,
    String? notes,
    List<String>? tags,
    List<String>? Function()? allergens,
  }) => Recipe(
    id: id,
    name: name ?? this.name,
    servings: servings ?? this.servings,
    ingredients: ingredients ?? this.ingredients,
    createdAt: createdAt,
    notes: notes ?? this.notes,
    tags: tags ?? this.tags,
    allergens: allergens == null ? this.allergens : allergens(),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'servings': servings,
    'ingredients': ingredients.map((i) => i.toJson()).toList(),
    'createdAt': createdAt.toUtc().toIso8601String(),
    'notes': notes,
    'tags': tags,
    'allergens': allergens,
  };
}

/// Optional daily targets, set by hand. With none set the app gives no
/// advice.
class NutritionGoals {
  const NutritionGoals({this.kcal, this.proteinG, this.carbsG, this.fatG});
  final int? kcal;
  final double? proteinG, carbsG, fatG;
  bool get isEmpty =>
      kcal == null && proteinG == null && carbsG == null && fatG == null;
  Map<String, dynamic> toJson() => {
    'kcal': kcal,
    'proteinG': proteinG,
    'carbsG': carbsG,
    'fatG': fatG,
  };
}

class ReminderSettings {
  const ReminderSettings({
    this.enabled = false,
    this.hour = 18,
    this.minute = 0,
  });
  final bool enabled;
  final int hour, minute;
  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'hour': hour,
    'minute': minute,
  };
}

class AppSnapshot {
  AppSnapshot({
    this.profile = const UserProfile(),
    this.reminder = const ReminderSettings(),
    Map<String, WorkoutSession> sessions = const {},
    Map<String, String?> overrides = const {},
    Map<String, CheckIn> checkIns = const {},
    List<FoodEntry> food = const [],
    List<PlanVersion> plans = const [],
    List<ProfileAnswer> profileHistory = const [],
    Map<String, CheckIn> afterCheckIns = const {},
    Map<String, bool> adjustments = const {},
    List<Reschedule> reschedules = const [],
    List<SessionEvent> sessionEvents = const [],
    List<ProgressionDecision> progressionDecisions = const [],
    List<MonthlyReview> reviews = const [],
    List<CardioSession> cardio = const [],
    List<FavoriteFood> favorites = const [],
    List<Recipe> recipes = const [],
    this.goals = const NutritionGoals(),
  }) : sessions = Map.unmodifiable(sessions),
       overrides = Map.unmodifiable(overrides),
       checkIns = Map.unmodifiable(checkIns),
       food = List.unmodifiable(food),
       plans = List.unmodifiable(plans),
       profileHistory = List.unmodifiable(profileHistory),
       afterCheckIns = Map.unmodifiable(afterCheckIns),
       adjustments = Map.unmodifiable(adjustments),
       reschedules = List.unmodifiable(reschedules),
       sessionEvents = List.unmodifiable(sessionEvents),
       progressionDecisions = List.unmodifiable(progressionDecisions),
       reviews = List.unmodifiable(reviews),
       cardio = List.unmodifiable(cardio),
       favorites = List.unmodifiable(favorites),
       recipes = List.unmodifiable(recipes);
  final UserProfile profile;
  final ReminderSettings reminder;
  final Map<String, WorkoutSession> sessions;
  // Presence with null explicitly means rest; absence uses the weekly plan.
  final Map<String, String?> overrides;
  // How the person felt before training (the 0.1 check-in) and after.
  final Map<String, CheckIn> checkIns, afterCheckIns;
  final List<FoodEntry> food;
  // Appended in creation order; the built-in example plan is not stored.
  final List<PlanVersion> plans;
  final List<ProfileAnswer> profileHistory;
  // A proposed lighter session, per date: true applied, false declined.
  // Absent means undecided.
  final Map<String, bool> adjustments;
  // Appended in creation order; undoing marks an entry, never removes it.
  final List<Reschedule> reschedules;
  final List<SessionEvent> sessionEvents;
  // Both append-only, in the order they were made.
  final List<ProgressionDecision> progressionDecisions;
  final List<MonthlyReview> reviews;
  // Cardio sessions in creation order: finished ones and at most one active.
  final List<CardioSession> cardio;
  final List<FavoriteFood> favorites;
  final List<Recipe> recipes;
  final NutritionGoals goals;
  AppSnapshot copyWith({
    UserProfile? profile,
    ReminderSettings? reminder,
    Map<String, WorkoutSession>? sessions,
    Map<String, String?>? overrides,
    Map<String, CheckIn>? checkIns,
    List<FoodEntry>? food,
    List<PlanVersion>? plans,
    List<ProfileAnswer>? profileHistory,
    Map<String, CheckIn>? afterCheckIns,
    Map<String, bool>? adjustments,
    List<Reschedule>? reschedules,
    List<SessionEvent>? sessionEvents,
    List<ProgressionDecision>? progressionDecisions,
    List<MonthlyReview>? reviews,
    List<CardioSession>? cardio,
    List<FavoriteFood>? favorites,
    List<Recipe>? recipes,
    NutritionGoals? goals,
  }) => AppSnapshot(
    profile: profile ?? this.profile,
    reminder: reminder ?? this.reminder,
    sessions: sessions ?? this.sessions,
    overrides: overrides ?? this.overrides,
    checkIns: checkIns ?? this.checkIns,
    food: food ?? this.food,
    plans: plans ?? this.plans,
    profileHistory: profileHistory ?? this.profileHistory,
    afterCheckIns: afterCheckIns ?? this.afterCheckIns,
    adjustments: adjustments ?? this.adjustments,
    reschedules: reschedules ?? this.reschedules,
    sessionEvents: sessionEvents ?? this.sessionEvents,
    progressionDecisions: progressionDecisions ?? this.progressionDecisions,
    reviews: reviews ?? this.reviews,
    cardio: cardio ?? this.cardio,
    favorites: favorites ?? this.favorites,
    recipes: recipes ?? this.recipes,
    goals: goals ?? this.goals,
  );

  /// The exact shape of the 0.1 snapshot, to compare imports with the
  /// original data.
  Map<String, dynamic> legacyJson() => {
    'schemaVersion': 1,
    'profile': profile.legacyJson(),
    'reminder': reminder.toJson(),
    'sessions': sessions.map((k, v) => MapEntry(k, v.legacyJson())),
    'overrides': overrides,
    'checkIns': checkIns.map((k, v) => MapEntry(k, v.toJson())),
    'food': food.map((e) => e.legacyJson()).toList(),
  };

  /// Every field: the oracle that import verification and tests compare.
  Map<String, dynamic> toJson() => {
    ...legacyJson(),
    'profile': profile.toJson(),
    'sessions': sessions.map((k, v) => MapEntry(k, v.toJson())),
    'plans': plans.map((p) => p.toJson()).toList(),
    'profileHistory': profileHistory.map((a) => a.toJson()).toList(),
    'afterCheckIns': afterCheckIns.map((k, v) => MapEntry(k, v.toJson())),
    'adjustments': adjustments,
    'reschedules': reschedules.map((r) => r.toJson()).toList(),
    'sessionEvents': sessionEvents.map((e) => e.toJson()).toList(),
    'progressionDecisions': progressionDecisions
        .map((d) => d.toJson())
        .toList(),
    'reviews': reviews.map((r) => r.toJson()).toList(),
    'cardio': cardio.map((c) => c.toJson()).toList(),
    'food': food.map((e) => e.toJson()).toList(),
    'favorites': favorites.map((f) => f.toJson()).toList(),
    'recipes': recipes.map((r) => r.toJson()).toList(),
    'goals': goals.toJson(),
  };
}
