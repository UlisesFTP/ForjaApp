import '../data/repositories/local_forja_repository.dart';
import '../data/backup/backup_codec.dart';
import '../data/database/forja_database.dart' show currentSchemaVersion;
import '../data/seed/catalog.dart' show exerciseCatalog;
import '../data/services/backup_service.dart';
import '../data/services/forja_store.dart';
import '../data/services/reminder_coordinator.dart';
import '../domain/services/notification_service.dart';
import '../data/services/local_store_opener.dart';
import '../data/services/tutorial_launcher.dart';
import '../domain/models/storage_failure.dart';
import '../ui/today/view_models/today_view_model.dart';
import '../ui/plan/view_models/plan_editor_view_model.dart';
import '../ui/plan/view_models/plan_view_model.dart';
import '../ui/progress/view_models/progress_view_model.dart';
import '../ui/streak/view_models/streak_view_model.dart';
import '../ui/progress/view_models/progression_view_model.dart';
import '../ui/coach/view_models/review_view_model.dart';
import '../ui/exercises/view_models/exercises_view_model.dart';
import '../ui/coach/view_models/coach_view_model.dart';
import '../ui/cardio/view_models/cardio_view_model.dart';
import '../ui/nutrition/view_models/nutrition_view_model.dart';
import '../ui/settings/view_models/data_view_model.dart';
import '../ui/settings/view_models/settings_view_model.dart';
import '../ui/shell/view_models/shell_view_model.dart';

/// Composition root. Swap repository implementations here to integrate a backend.
/// Screen/ViewModel constructors accept contracts, not this local storage adapter.
class AppDependencies {
  AppDependencies._(
    this.repository,
    this.launcher,
    NotificationService notifications,
    BackupFiles backupFiles,
    BackupVault backupVault, {
    DateTime Function()? clock,
  }) : _clock = clock {
    final known = {for (final e in exerciseCatalog) e.id};
    backups = BackupService(
      repository: repository,
      codec: BackupCodec(isKnownExercise: known.contains),
      vault: backupVault,
      files: backupFiles,
      schema: currentSchemaVersion,
      clock: clock,
    );
    data = DataViewModel(backups);
    reminders = ReminderCoordinator(
      notifications,
      repository,
      repository,
      clock: clock,
    );
    today = TodayViewModel(repository, repository, repository, clock: clock);
    plan = PlanViewModel(
      repository,
      repository,
      repository,
      repository,
      clock: clock,
    );
    progress = ProgressViewModel(
      repository,
      repository,
      repository,
      clock: clock,
    );
    streak = StreakViewModel(repository, clock: clock);
    progression = ProgressionViewModel(
      repository,
      repository,
      repository,
      clock: clock,
    );
    review = ReviewViewModel(
      repository,
      repository,
      repository,
      repository,
      clock: clock,
    );
    exercises = ExercisesViewModel(repository, repository);
    coach = CoachViewModel(repository, repository, repository, clock: clock);
    cardio = CardioViewModel(repository, repository, clock: clock);
    nutrition = NutritionViewModel(repository, clock: clock);
    settings = SettingsViewModel(repository, repository, reminders);
  }
  final LocalForjaRepository repository;
  final TutorialLauncher launcher;
  final DateTime Function()? _clock;
  late final TodayViewModel today;
  late final PlanViewModel plan;
  late final ProgressViewModel progress;
  late final StreakViewModel streak;
  late final ProgressionViewModel progression;
  late final ReviewViewModel review;
  late final ExercisesViewModel exercises;
  late final CoachViewModel coach;
  late final CardioViewModel cardio;
  late final NutritionViewModel nutrition;
  late final SettingsViewModel settings;
  late final ReminderCoordinator reminders;
  late final BackupService backups;
  late final DataViewModel data;
  final shell = ShellViewModel();

  /// Opens the local database unless a [store] is given. Throws a
  /// [StorageFailure] when the data cannot be read; nothing is deleted.
  static Future<AppDependencies> create({
    ForjaStore? store,
    bool skipLegacyImport = false,
    TutorialLauncher? launcher,
    DateTime Function()? clock,
    // Native notifications; without one nothing is scheduled (tests).
    NotificationService? notifications,
    BackupFiles? backupFiles,
    BackupVault? backupVault,
  }) async {
    final repository = LocalForjaRepository(
      store ??
          await LocalStoreOpener().open(skipLegacyImport: skipLegacyImport),
      clock: clock,
    );
    try {
      await repository.initialize();
      return AppDependencies._(
        repository,
        launcher ?? ExternalTutorialLauncher(),
        notifications ?? NoopNotificationService(),
        backupFiles ?? FilePickerBackupFiles(),
        backupVault ?? FileBackupVault(),
        clock: clock,
      );
    } catch (error, stack) {
      repository.dispose();
      await repository.close();
      Error.throwWithStackTrace(
        error is StorageFailure ? error : StorageUnavailable(error),
        stack,
      );
    }
  }

  /// An editor over the pending draft; the draft must exist.
  PlanEditorViewModel createPlanEditor() =>
      PlanEditorViewModel(repository, repository, repository, clock: _clock);

  /// Releases the ViewModels, then waits for pending writes and closes storage.
  Future<void> dispose() async {
    today.dispose();
    plan.dispose();
    progress.dispose();
    streak.dispose();
    progression.dispose();
    review.dispose();
    exercises.dispose();
    coach.dispose();
    cardio.dispose();
    nutrition.dispose();
    data.dispose();
    reminders.dispose();
    settings.dispose();
    shell.dispose();
    repository.dispose();
    await repository.close();
  }
}
