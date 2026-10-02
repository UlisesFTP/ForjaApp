import '../../core/ids.dart';
import '../models/models.dart';

/// A new editable draft that starts as a copy of [source]. Plan and routine
/// ids are fresh, so changing the copy can never alter a version that past
/// sessions point at.
PlanVersion cloneForEditing(
  PlanVersion source, {
  required DateTime now,
  IdGenerator newId = randomId,
}) => PlanVersion(
  id: newId(),
  status: PlanStatus.draft,
  source: PlanSource.manual,
  name: source.source == PlanSource.example ? 'Mi plan' : source.name,
  createdAt: now,
  days: [
    for (final day in source.days)
      PlanDay(
        day.weekday,
        Routine(
          id: newId(),
          name: day.routine.name,
          focus: day.routine.focus,
          warmup: day.routine.warmup,
          exercises: day.routine.exercises,
        ),
      ),
  ],
);
