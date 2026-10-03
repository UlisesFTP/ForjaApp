import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/theme/forja_theme.dart';
import '../../../domain/models/models.dart';
import '../../core/widgets.dart';
import '../../core/droplet_navigation.dart';
import '../../core/responsive.dart';
import '../../today/widgets/today_view.dart';
import '../../plan/widgets/plan_editor_page.dart';
import '../../plan/widgets/plan_view.dart';
import '../../progress/widgets/progress_view.dart';
import '../../exercises/widgets/exercises_view.dart';
import '../../../core/date_utils.dart';
import '../../../domain/expert/expert_coach.dart';
import '../../coach/widgets/coach_form.dart';
import '../../coach/widgets/coach_chat_page.dart';
import '../../coach/widgets/coach_page.dart';
import '../../nutrition/view_models/nutrition_view_model.dart';
import '../../coach/widgets/review_sheet.dart';
import '../../exercises/widgets/exercise_details.dart';
import '../../nutrition/view_models/meal_estimate_view_model.dart';
import '../../nutrition/widgets/food_form.dart';
import '../../nutrition/widgets/goals_sheet.dart';
import '../../nutrition/widgets/meal_estimate_sheet.dart';
import '../../../domain/services/ai/ai_settings.dart';
import '../../cardio/widgets/cardio_view.dart';
import '../../nutrition/widgets/nutrition_view.dart';
import '../../settings/widgets/reminder_sheet.dart';
import '../../settings/view_models/ai_settings_view_model.dart';
import '../../settings/widgets/ai_sheet.dart';
import '../../settings/widgets/data_sheet.dart';
import '../../settings/widgets/unit_sheet.dart';
import '../../streak/widgets/streak_badge.dart';
import '../../streak/widgets/streak_page.dart';
import '../view_models/shell_view_model.dart';

class ShellView extends StatefulWidget {
  const ShellView({
    super.key,
    required this.dependencies,
    this.offerOnboarding = true,
  });
  final AppDependencies dependencies;
  final bool offerOnboarding;
  @override
  State<ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends State<ShellView> with WidgetsBindingObserver {
  // The pages live in an IndexedStack, so all of them stay built. They are
  // created once: the shell rebuilds on every tab change, and a new widget
  // instance each time made Flutter rebuild every page (the worst frame of a
  // tab change was ≈169 ms on a phone). Each page listens to its own
  // ViewModel, so it still updates when its data changes.
  late Widget _today, _plan, _progress, _exercises, _cardio, _nutrition;

  void _createPages() {
    final d = widget.dependencies;
    _today = TodayView(
      vm: d.today,
      progression: d.progression,
      launcher: d.launcher,
      onProgress: () => d.shell.open(AppPage.progress),
      onCoach: () => _openCoach(),
      onCardio: () => d.shell.open(AppPage.cardio),
    );
    _plan = PlanView(
      vm: d.plan,
      onDate: (date) {
        d.today.selectDate(date);
        d.shell.open(AppPage.today);
      },
      onEdit: () => editPlan(context, d.plan, d.createPlanEditor),
      onReview: () => _openCoach(only: RuleFamily.plan),
    );
    _progress = ProgressView(vm: d.progress, progression: d.progression);
    _exercises = ExercisesView(vm: d.exercises, launcher: d.launcher);
    _cardio = CardioView(vm: d.cardio);
    _nutrition = NutritionView(
      vm: d.nutrition,
      assist: MealAssist(
        listenable: d.ai,
        available: () => d.ai.featureOn(AiFeature.mealEstimate),
        describe: (context) async {
          final vm = MealEstimateViewModel(d.ai, clock: d.clock);
          try {
            return await showMealEstimate(context, vm);
          } finally {
            vm.dispose();
          }
        },
      ),
    );
  }

  @override
  void didUpdateWidget(ShellView old) {
    super.didUpdateWidget(old);
    if (old.dependencies != widget.dependencies) _createPages();
  }

  @override
  void initState() {
    super.initState();
    _createPages();
    WidgetsBinding.instance.addObserver(this);
    final d = widget.dependencies;
    d.reminders.taps.addListener(_openTapped);
    // Cold start: the plugin may already know which reminder was tapped.
    unawaited(d.reminders.start().then((_) => _openTapped()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.offerOnboarding &&
          widget.dependencies.coach.needsOnboarding) {
        showCoach(context, widget.dependencies.coach);
      }
    });
  }

  /// The minicoach page (F16): its advice is evaluated only while it is open.
  Future<void> _openCoach({RuleFamily? only}) {
    final d = widget.dependencies;
    return showCoachPage(
      context,
      vm: d.createCoachAdvice(),
      only: only,
      onAction: _coachAction,
      onProfile: () => showCoach(context, d.coach, review: d.review),
      extra: only != null
          ? null
          : ListenableBuilder(
              listenable: d.ai,
              builder: (context, _) => d.ai.featureOn(AiFeature.chat)
                  ? SurfaceCard(
                      child: QuickRow(
                        key: const ValueKey('coach-ask-ai'),
                        icon: Icons.cloud_outlined,
                        title: 'Preguntar al asistente (IA)',
                        subtitle: 'Externo, con tu clave. Consulta lo que permitiste.',
                        onTap: _openChat,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
    );
  }

  /// The coach chat (F17): memory only, released when it closes.
  Future<void> _openChat() {
    final d = widget.dependencies;
    return showCoachChat(
      context,
      vm: d.createCoachChat(),
      onFood: (context, p) async {
        d.nutrition.selectDate(parseDateKey(p.dateKey));
        await showFoodForm(
          context,
          d.nutrition,
          initial: FoodDraft(
            name: p.name,
            calories: p.kcal,
            portion: p.portion,
            unit: p.unit,
            proteinG: p.proteinG,
            carbsG: p.carbsG,
            fatG: p.fatG,
            source: CaloriesSource.estimated,
          ),
        );
      },
      onRecommendation: (_) => _openCoach(),
    );
  }

  /// Carries out a recommendation's action through the existing screens and
  /// sheets; nothing is saved here.
  Future<void> _coachAction(BuildContext context, CoachAction action) async {
    final d = widget.dependencies;
    void leaveTo(AppPage page) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      d.shell.open(page);
    }

    switch (action) {
      case OpenDay(:final dateKey):
        Navigator.of(context).popUntil((route) => route.isFirst);
        d.today.selectDate(parseDateKey(dateKey));
        d.shell.open(AppPage.today);
      case OpenPlanEditor() || AddVolume() || AdvanceExercise():
        leaveTo(AppPage.plan);
      case OpenCardio():
        leaveTo(AppPage.cardio);
      case OpenReview():
        await showReview(context, d.review);
      case OpenNutritionGoals():
        await showGoals(context, d.nutrition);
      case OpenAlternatives(:final exercise):
        await showExerciseDetails(
          context,
          d.repository.exerciseById(exercise),
          d.launcher,
          alternativesOf: d.exercises.alternatives,
        );
      case OpenProfile():
        await showCoach(context, d.coach, review: d.review);
      case IncreaseLoad():
        // Accepted by the page's ViewModel, like on Progreso.
        break;
    }
  }

  // A tapped reminder opens its day in Hoy.
  void _openTapped() {
    final d = widget.dependencies;
    final date = d.reminders.taps.value;
    if (date == null || !mounted) return;
    d.reminders.taps.value = null;
    d.today.selectDate(date);
    d.shell.open(AppPage.today);
  }

  // The 28-day window and the permission are looked at again whenever the app
  // comes back: the day, the zone or the permission may have changed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(widget.dependencies.reminders.reconcile());
    }
    // A request to the assistant never continues in the background.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      widget.dependencies.ai.cancelAll();
    }
  }

  /// Más → Asistente IA: a ViewModel per opening, released on close.
  Future<void> _openAi() async {
    final vm = AiSettingsViewModel(widget.dependencies.ai);
    try {
      await showAiSettings(context, vm);
    } finally {
      vm.dispose();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.dependencies.reminders.taps.removeListener(_openTapped);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dependencies;
    return ColoredBox(
      color: ForjaColors.background,
      child: AnimatedBuilder(
        animation: d.shell,
        builder: (context, _) {
          // Wider than tall: the droplet stands on the left so the content
          // keeps its height. Portrait (phone or tablet): the bottom bar.
          final rail = useNavigationRail(MediaQuery.sizeOf(context));
          final appBar = AppBar(
            // Beside the rail the bar starts below the status bar, which then
            // sits on the dark background with light icons.
            primary: !rail,
            backgroundColor: ForjaColors.paper,
            foregroundColor: ForjaColors.ink,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 48,
            automaticallyImplyLeading: false,
            titleSpacing: 16,
            title: Row(
              children: [
                Image.asset(
                  'assets/images/forja-icon.png',
                  width: 28,
                  height: 28,
                  excludeFromSemantics: true,
                ),
                const SizedBox(width: 8),
                // The wordmark shrinks to its space instead of overflowing
                // at 320 px with large text and a streak count beside it.
                const Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'FORJA',
                      style: TextStyle(
                        fontFamily: 'Barlow Condensed',
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              // The streak: flame and count; opens the calendars (D36).
              StreakBadge(
                vm: d.streak,
                onOpen: () => showStreak(context, d.streak),
              ),
              IconButton(
                tooltip: 'Recordatorios',
                onPressed: () => showReminder(context, d.settings),
                icon: const Icon(Icons.notifications_none),
              ),
              IconButton(
                tooltip: 'Mi perfil y minicoach',
                onPressed: () => showCoach(context, d.coach, review: d.review),
                icon: const Icon(Icons.account_circle_outlined),
              ),
              const SizedBox(width: 4),
            ],
          );
          final pages = SafeArea(
            top: false,
            // The bottom bar keeps clear of the system bar itself; beside
            // the rail the pages do it.
            bottom: rail,
            left: !rail,
            child: IndexedStack(
              index: d.shell.page.index,
              children: [
                _today,
                _plan,
                _progress,
                _exercises,
                _more(context),
                _cardio,
                _nutrition,
              ],
            ),
          );
          if (rail) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: Scaffold(
                body: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropletRail(
                      index: d.shell.navIndex,
                      onSelected: d.shell.select,
                    ),
                    Expanded(
                      // The rail already keeps clear of a side camera
                      // cutout; without this every list tile (which pads
                      // itself by the safe area) would add it again.
                      child: MediaQuery.removePadding(
                        context: context,
                        removeLeft: true,
                        child: SafeArea(
                          left: false,
                          right: false,
                          bottom: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              appBar,
                              Expanded(child: pages),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Scaffold(
            appBar: appBar,
            body: pages,
            // On a tablet in portrait the bar keeps a phone-like width.
            bottomNavigationBar: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: DropletNavigation(
                  index: d.shell.navIndex,
                  onSelected: d.shell.select,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _more(BuildContext context) {
    final d = widget.dependencies;
    // A list of settings reads best as one centred column on any screen.
    return ResponsivePage(
      maxWidth: Breakpoints.readable,
      header: const PageHeading(
        'A TU RITMO',
        subtitle: 'Las herramientas que acompañan tu rutina.',
      ),
      primary: [
        SurfaceCard(
          child: Column(
            children: [
              QuickRow(
                icon: Icons.timer_outlined,
                title: 'Cardio',
                subtitle: 'Cronómetro y calorías aproximadas',
                onTap: () => d.shell.open(AppPage.cardio),
              ),
              const Divider(),
              QuickRow(
                icon: Icons.restaurant_outlined,
                title: 'Nutrición',
                subtitle: 'Registro de calorías',
                onTap: () => d.shell.open(AppPage.nutrition),
              ),
              const Divider(),
              QuickRow(
                icon: Icons.tune,
                title: 'Minicoach',
                subtitle: d.review.due
                    ? 'Revisión mensual disponible'
                    : 'Perfil y revisión mensual',
                onTap: _openCoach,
              ),
              const Divider(),
              ListenableBuilder(
                listenable: d.ai,
                builder: (context, _) => QuickRow(
                  key: const ValueKey('more-ai'),
                  icon: Icons.cloud_outlined,
                  title: 'Asistente IA (opcional)',
                  subtitle: d.ai.ready
                      ? 'Activo · con tu clave'
                      : 'Desactivado · externo, con tu propia clave',
                  onTap: _openAi,
                ),
              ),
              const Divider(),
              QuickRow(
                icon: Icons.notifications_none,
                title: 'Recordatorios',
                subtitle: 'Preferencia de horario',
                onTap: () => showReminder(context, d.settings),
              ),
              const Divider(),
              QuickRow(
                icon: Icons.scale_outlined,
                title: 'Unidad de peso',
                subtitle: d.settings.unit == WeightUnit.kg
                    ? 'Kilogramos (kg)'
                    : 'Libras (lb)',
                onTap: () => showUnits(context, d.settings),
              ),
              const Divider(),
              QuickRow(
                icon: Icons.description_outlined,
                title: 'Licencias',
                subtitle: 'Código abierto y fuentes incluidas',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'FORJA',
                  applicationVersion: '0.9.0',
                ),
              ),
              const Divider(),
              QuickRow(
                icon: Icons.shield_outlined,
                title: 'Datos y privacidad',
                subtitle: 'Copia de seguridad, importar y eliminar',
                onTap: () => showData(
                  context,
                  d.data,
                  // After deleting everything the app starts over.
                  onReset: () => showCoach(context, d.coach, review: d.review),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Sin cuenta. Tus registros se guardan en este dispositivo. Los tutoriales necesitan conexión a Internet, y el asistente IA opcional también.',
        ),
      ],
    );
  }
}
