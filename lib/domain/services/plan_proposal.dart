import '../../core/ids.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import 'plan_generator.dart';

/// Generates a draft from the profile and stores it. A draft the person
/// already edited by hand is kept: a profile change never overwrites work.
Future<GeneratedPlan> proposeDraft({
  required PlanRepository plans,
  required UserProfile profile,
  required ExerciseRepository catalog,
  required DateTime now,
  IdGenerator newId = randomId,
}) async {
  final existing = plans.draft;
  if (existing != null && existing.source == PlanSource.manual) {
    return GeneratedPlan(
      draft: existing,
      notes: const [
        'Ya tienes un borrador editado a mano; no se reemplazó. Puedes generar otro desde el plan.',
      ],
    );
  }
  final result = PlanGenerator.generate(
    profile,
    catalog: catalog.exercises,
    now: now,
    newId: newId,
  );
  if (result.draft != null) await plans.saveDraft(result.draft!);
  return result;
}
