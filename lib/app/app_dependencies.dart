import '../data/repositories/local_forja_repository.dart';
import '../data/backup/backup_codec.dart';
import '../data/database/forja_database.dart' show currentSchemaVersion;
import '../data/seed/catalog.dart' show exerciseCatalog;
import '../data/services/ai/ai_gateway.dart';
import '../data/services/backup_service.dart';
import '../data/services/forja_store.dart';
import '../data/services/reminder_coordinator.dart';
import '../domain/services/ai/ai_client.dart';
import '../domain/services/ai/ai_settings.dart';
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
import '../data/services/ai/coach_agent.dart';
import '../domain/expert/expert_coach.dart';
import '../domain/services/ai/mcp/forja_mcp_server.dart';
import '../domain/services/ai/mcp/forja_tools.dart';
import '../domain/services/ai/mcp/proposal_inbox.dart';
import '../ui/coach/view_models/coach_advice_view_model.dart';
import '../ui/coach/view_models/coach_chat_view_model.dart';
import '../ui/coach/view_models/coach_inputs_builder.dart';
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
    BackupVault backupVault,
    this.ai, {
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
      forgetOutsideDatabase: ai.forgetAll,
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
      profiles: repository,
      plans: repository,
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

  /// The optional external assistant's only way to the network (F17).
  final AiGateway ai;
  final DateTime Function()? _clock;

  /// The injected clock (tests), or null for the real time.
  DateTime Function()? get clock => _clock;
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
    // The assistant: disabled client and memory stores unless given, so
    // tests never touch the network or the platform.
    AiChatClient? aiClient,
    SecretStore? secrets,
    AiSettingsStore? aiSettings,
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
        AiGateway(
          client: aiClient ?? const DisabledAiChatClient(),
          secrets: secrets ?? MemorySecretStore(),
          store: aiSettings ?? MemoryAiSettingsStore(),
          clock: clock,
        ),
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

  /// The expert system's advice for the Coach page. A new one per opening:
  /// it evaluates only while the page is shown, and the page releases it.
  CoachAdviceViewModel createCoachAdvice() => CoachAdviceViewModel(
    workouts: repository,
    profiles: repository,
    plans: repository,
    progression: repository,
    catalog: repository,
    coach: repository,
    cardio: repository,
    nutrition: repository,
    clock: _clock,
  );

  ExpertResult _expertNow() => ExpertCoach.evaluate(
    buildCoachInputs(
      today: (_clock ?? DateTime.now)(),
      workouts: repository,
      profiles: repository,
      plans: repository,
      progression: repository,
      catalog: repository,
      cardio: repository,
      nutrition: repository,
    ),
  );

  /// The coach chat (F17): a new conversation per opening, with the tools
  /// limited to what the person allowed when it opened.
  CoachChatViewModel createCoachChat() {
    final clock = _clock ?? DateTime.now;
    final server = ForjaMcpServer(
      ForjaToolContext(
        workouts: repository,
        profiles: repository,
        plans: repository,
        catalog: repository,
        cardio: repository,
        nutrition: repository,
        coach: repository,
        categories: {...ai.categories},
        today: clock(),
        expert: _expertNow,
        inbox: ProposalInbox(clock: clock),
      ),
    );
    return CoachChatViewModel(
      gateway: ai,
      agent: CoachAgent(gateway: ai, server: server),
      expert: _expertNow,
      clock: clock,
    );
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
    ai.dispose();
    repository.dispose();
    await repository.close();
  }
}
