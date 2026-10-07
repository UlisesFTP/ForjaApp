import '../../../core/date_utils.dart';
import '../../../core/ids.dart';
import '../../../domain/models/models.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/plan_generator.dart';
import '../../../domain/services/plan_proposal.dart';
import '../../core/view_model.dart';

/// Profile, onboarding and the plan proposal that follows a profile change.
class CoachViewModel extends ViewModel {
  CoachViewModel(
    this._profiles,
    this._plans,
    this._catalog, {
    DateTime Function()? clock,
    IdGenerator? newId,
  }) : _clock = clock ?? DateTime.now,
       _newId = newId ?? randomId {
    watch(_profiles);
    watch(_plans);
  }
  final ProfileRepository _profiles;
  final PlanRepository _plans;
  final ExerciseRepository _catalog;
  final DateTime Function() _clock;
  final IdGenerator _newId;

  /// What the last save produced, so the form can explain it.
  GeneratedPlan? proposal;

  /// Number of onboarding steps; see the onboarding sheet.
  static const steps = 7;

  UserProfile get profile => _profiles.profile;
  List<ProfileAnswer> get history => _profiles.profileHistory;
  PlanVersion? get draft => _plans.draft;

  /// The first run offers onboarding until it is finished or skipped.
  bool get needsOnboarding => !profile.onboarded && !profile.skippedSetup;

  /// Whether the user is on the example plan because they skipped the setup.
  bool get usingExample => !profile.onboarded && profile.skippedSetup;

  /// Remembers the answers so far and the step to resume at.
  Future<bool> saveProgress(UserProfile answers, int nextStep) =>
      run(() => _profiles.saveProfile(answers.copyWith(setupStep: nextStep)));

  Future<bool> skipSetup() => run(
    () => _profiles.saveProfile(
      profile.copyWith(skippedSetup: true),
      record: ProfileChange.skipped,
    ),
    success: 'Sin plan por ahora: créalo en Plan o completa tu perfil cuando quieras.',
  );

  /// Saves the finished onboarding and proposes a plan from it.
  Future<bool> finishOnboarding(UserProfile answers) => _saveAndPropose(
    answers.copyWith(
      onboarded: true,
      skippedSetup: false,
      setupStep: steps,
      lastReview: () => dateKey(_clock()),
    ),
    ProfileChange.onboarding,
    'Perfil guardado',
  );

  /// Saves an edit. Changing the profile proposes a draft; it never touches
  /// past sessions or the plan in use.
  Future<bool> saveEdit(UserProfile edited) => _saveAndPropose(
    edited.copyWith(
      onboarded: true,
      skippedSetup: false,
      setupStep: steps,
      lastReview: () => dateKey(_clock()),
    ),
    ProfileChange.edit,
    'Perfil guardado',
  );

  Future<bool> _saveAndPropose(
    UserProfile next,
    ProfileChange reason,
    String success,
  ) => run(() async {
    await _profiles.saveProfile(next, record: reason);
    proposal = await proposeDraft(
      plans: _plans,
      profile: next,
      catalog: _catalog,
      now: _clock().toUtc(),
      newId: _newId,
    );
    announce(
      proposal!.ok
          ? '$success. Hay un borrador de plan para revisar.'
          : '$success. ${proposal!.failure}',
    );
  });
}
