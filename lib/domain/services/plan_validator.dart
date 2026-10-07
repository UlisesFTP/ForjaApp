import '../models/models.dart';

/// Checks a plan before it is stored or accepted. Messages are written for the
/// person editing the plan.
class PlanValidator {
  static const maxName = 40;

  /// Issues found; empty means valid. A draft may still be incomplete; a plan
  /// being accepted must give every routine at least one exercise.
  static List<String> validate(
    PlanVersion plan, {
    required bool forAcceptance,
    required bool Function(String exerciseId) isKnown,
  }) {
    final issues = <String>[];
    if (plan.name.trim().isEmpty || plan.name.length > maxName) {
      issues.add(
        'El nombre del plan debe tener entre 1 y $maxName caracteres.',
      );
    }
    // Any number of distinct weekdays (D45: the person's own plan may have
    // four days, or one); a draft may still have none.
    final weekdays = [for (final d in plan.days) d.weekday];
    if (weekdays.toSet().length != weekdays.length ||
        weekdays.any((d) => d < DateTime.monday || d > DateTime.sunday)) {
      issues.add('Cada día del plan debe ser un día distinto de la semana.');
    }
    if (forAcceptance && weekdays.isEmpty) {
      issues.add('Añade al menos un día de entrenamiento.');
    }
    final routineIds = <String>{};
    for (final routine in plan.routines) {
      if (!routineIds.add(routine.id)) {
        issues.add('Hay dos rutinas con el mismo identificador.');
      }
      final label = routine.name.trim().isEmpty ? 'Una rutina' : routine.name;
      if (routine.name.trim().isEmpty || routine.name.length > maxName) {
        issues.add(
          '$label: el nombre debe tener entre 1 y $maxName caracteres.',
        );
      }
      if (forAcceptance && routine.exercises.isEmpty) {
        issues.add('$label: añade al menos un ejercicio.');
      }
      final seen = <String>{};
      for (final e in routine.exercises) {
        if (!isKnown(e.exerciseId)) {
          issues.add(
            '$label: hay un ejercicio que ya no existe en el catálogo.',
          );
        }
        if (!seen.add(e.exerciseId)) {
          issues.add('$label: un ejercicio está repetido.');
        }
        if (e.sets < 1 || e.sets > 10) {
          issues.add('$label: las series deben estar entre 1 y 10.');
        }
        if (e.repsMin < 1 || e.repsMax > 300 || e.repsMin > e.repsMax) {
          issues.add('$label: el rango de repeticiones no es válido.');
        }
        if (e.rir < 0 || e.rir > 5) {
          issues.add('$label: las repeticiones en reserva van de 0 a 5.');
        }
        if (e.restSeconds < 0 || e.restSeconds > 600) {
          issues.add('$label: el descanso va de 0 a 600 segundos.');
        }
        if (!e.incrementKg.isFinite ||
            e.incrementKg < 0 ||
            e.incrementKg > 50) {
          issues.add('$label: el incremento de carga va de 0 a 50 kg.');
        }
        final weight = e.referenceWeightKg;
        if (weight != null &&
            (!weight.isFinite || weight < 0 || weight > 2000)) {
          issues.add('$label: el peso de referencia va de 0 a 2000 kg.');
        }
      }
    }
    return issues.toSet().toList();
  }
}
