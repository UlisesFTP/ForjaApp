/// What a recommendation lets the person do. Every action goes through an
/// existing flow and the person's own confirmation: nothing here saves data.
sealed class CoachAction {
  const CoachAction();

  /// Button text.
  String get label;

  /// Raises a training load or the volume of the plan. The safety gate blocks
  /// these under a matching veto.
  bool get raisesLoad => false;
  bool get raisesVolume => false;

  /// The exercise the action is about, when it is about one.
  String? get exerciseId => null;
}

/// Accept a progression suggestion (the same decision the Progress screen
/// records: first decision final, applied to new sessions only).
final class IncreaseLoad extends CoachAction {
  const IncreaseLoad({
    required this.exercise,
    required this.basedOn,
    required this.fromKg,
    required this.toKg,
  });
  final String exercise, basedOn;
  final double fromKg, toKg;
  @override
  String get label => 'Aceptar aumento';
  @override
  bool get raisesLoad => true;
  @override
  String get exerciseId => exercise;
}

/// Open the plan editor to add sets (more weekly volume).
final class AddVolume extends CoachAction {
  const AddVolume();
  @override
  String get label => 'Editar el plan';
  @override
  bool get raisesVolume => true;
}

/// Make a bodyweight or timed exercise harder in the plan editor (more reps,
/// more seconds or one more set): a raise of that exercise's load and of the
/// plan's volume.
final class AdvanceExercise extends CoachAction {
  const AdvanceExercise(this.exercise);
  final String exercise;
  @override
  String get label => 'Editar el plan';
  @override
  bool get raisesLoad => true;
  @override
  bool get raisesVolume => true;
  @override
  String get exerciseId => exercise;
}

/// Open the plan editor (or the plan) for any other change.
final class OpenPlanEditor extends CoachAction {
  const OpenPlanEditor();
  @override
  String get label => 'Revisar el plan';
}

/// Open a day of the calendar.
final class OpenDay extends CoachAction {
  const OpenDay(this.dateKey);
  final String dateKey;
  @override
  String get label => 'Abrir el día';
}

final class OpenReview extends CoachAction {
  const OpenReview();
  @override
  String get label => 'Abrir la revisión';
}

final class OpenCardio extends CoachAction {
  const OpenCardio();
  @override
  String get label => 'Ir a cardio';
}

final class OpenNutritionGoals extends CoachAction {
  const OpenNutritionGoals();
  @override
  String get label => 'Fijar mis objetivos';
}

/// Show compatible alternatives for an exercise.
final class OpenAlternatives extends CoachAction {
  const OpenAlternatives(this.exercise);
  final String exercise;
  @override
  String get label => 'Ver alternativas';
  @override
  String get exerciseId => exercise;
}

/// Open the profile (for example to add the body weight).
final class OpenProfile extends CoachAction {
  const OpenProfile();
  @override
  String get label => 'Abrir mi perfil';
}
