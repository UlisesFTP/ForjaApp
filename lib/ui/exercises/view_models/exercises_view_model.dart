import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/exercise_library.dart';
import '../../core/view_model.dart';

class ExercisesViewModel extends ViewModel {
  ExercisesViewModel(this._repository, this._profiles) {
    watch(_profiles);
  }
  final ExerciseRepository _repository;
  final ProfileRepository _profiles;
  String query = '', category = 'Todos';
  // Only exercises the person's equipment allows, when on.
  bool onlyMyEquipment = false;
  Equipment? equipmentFilter;

  /// Muscle groups, "Todos" first.
  List<String> get categories => [
    'Todos',
    ..._repository.exercises.map((e) => e.group).toSet(),
  ];

  Set<Equipment> get myEquipment => {
    ..._profiles.profile.equipment,
    Equipment.bodyweight,
  };

  List<Exercise> get filtered => searchExercises(
    _repository.exercises,
    query: query,
    group: category == 'Todos' ? null : category,
    equipment: equipmentFilter != null
        ? {equipmentFilter!}
        : onlyMyEquipment
        ? myEquipment
        : null,
  );

  /// Substitutes for [exercise] that the person's equipment allows.
  List<Exercise> alternatives(Exercise exercise) =>
      alternativesFor(exercise, _repository.exercises, myEquipment);

  void search(String value) {
    query = value;
    notifyListeners();
  }

  void filter(String value) {
    category = value;
    notifyListeners();
  }

  void filterEquipment(Equipment? value) {
    equipmentFilter = value;
    notifyListeners();
  }

  void toggleMyEquipment(bool value) {
    onlyMyEquipment = value;
    notifyListeners();
  }
}
