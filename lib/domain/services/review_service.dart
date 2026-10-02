import '../../core/date_utils.dart';
import '../models/models.dart';

/// Version of the monthly-review rules, stored with every review.
const reviewRulesVersion = 'review-v1';

enum ReviewDifficulty { easy, right, hard }

/// What the person answers in a review.
class ReviewAnswers {
  const ReviewAnswers({
    required this.energy,
    required this.pain,
    required this.difficulty,
    required this.goal,
    required this.equipment,
    required this.trainingDays,
    required this.sessionMinutes,
  });
  final Energy energy;
  // Pain or soreness that gets in the way of training.
  final bool pain;
  final ReviewDifficulty difficulty;
  final TrainingGoal goal;
  final Set<Equipment> equipment;
  final List<int> trainingDays;
  final int sessionMinutes;

  /// Defaults taken from the current profile.
  factory ReviewAnswers.from(UserProfile p) => ReviewAnswers(
    energy: p.energy,
    pain: false,
    difficulty: ReviewDifficulty.right,
    goal: p.goal,
    equipment: p.equipment,
    trainingDays: p.trainingDays,
    sessionMinutes: p.sessionMinutes,
  );

  Map<String, Object?> toJson() => {
    'energy': energy.name,
    'pain': pain,
    'difficulty': difficulty.name,
    'goal': goal.name,
    'equipment': [
      for (final e in Equipment.values)
        if (equipment.contains(e)) e.name,
    ],
    'trainingDays': trainingDays,
    'sessionMinutes': sessionMinutes,
  };
}

/// The last month as the rules see it.
class ReviewMonth {
  const ReviewMonth({
    required this.done,
    required this.due,
    this.fatigueDays = 0,
    this.injuryDays = 0,
  });
  // Completed vs planned-and-due sessions.
  final int done, due;
  // Days with a "tired / DOMS" or "injured" check-in.
  final int fatigueDays, injuryDays;
  double? get adherence => due == 0 ? null : done / due;
}

class ReviewStatus {
  const ReviewStatus({required this.due, this.daysSince, this.snoozedUntil});
  // A review can be offered now (never forced: Hoy is not blocked).
  final bool due;
  final int? daysSince;
  final String? snoozedUntil;
}

class ReviewProposal {
  const ReviewProposal({
    required this.profile,
    required this.notes,
    required this.insufficientData,
    required this.allowsIncrease,
  });
  // The profile with the answers applied: the basis of the proposed plan.
  final UserProfile profile;
  // Plain-language reasons, one per line.
  final List<String> notes;
  final bool insufficientData;
  // False after pain, injury, fatigue or a "too hard" answer: nothing in
  // the proposal asks for more load.
  final bool allowsIncrease;
}

/// Monthly review rules, v1. Local, explainable heuristics for organising
/// training; not a diagnosis and not a remote model.
class ReviewService {
  static const periodDays = 30;
  static const snoozeDays = 7;
  static const minSessions = 3;

  static ReviewStatus status(UserProfile profile, DateTime today) {
    final now = dateOnly(today);
    final last = profile.lastReview == null
        ? null
        : parseDateKey(profile.lastReview!);
    // Whole calendar days, counted in UTC so a daylight-saving change (a
    // 23- or 25-hour day) never shifts the count.
    final since = last == null
        ? null
        : DateTime.utc(
            now.year,
            now.month,
            now.day,
          ).difference(DateTime.utc(last.year, last.month, last.day)).inDays;
    final snooze = profile.reviewSnoozeUntil;
    final snoozed = snooze != null && dateKey(now).compareTo(snooze) < 0;
    final reached = since == null || since >= periodDays;
    return ReviewStatus(
      due: profile.onboarded && reached && !snoozed,
      daysSince: since,
      snoozedUntil: snoozed ? snooze : null,
    );
  }

  static DateTime snoozeUntil(DateTime today) => nextDay(today, snoozeDays);

  static ReviewProposal propose({
    required UserProfile current,
    required ReviewAnswers answers,
    required ReviewMonth month,
  }) {
    var minutes = answers.sessionMinutes;
    final notes = <String>[];
    final insufficient = month.due < minSessions;
    final held =
        answers.pain ||
        month.injuryDays > 0 ||
        month.fatigueDays > 0 ||
        answers.energy == Energy.low ||
        answers.difficulty == ReviewDifficulty.hard;

    if (insufficient) {
      notes.add(
        'Hay pocos entrenamientos vencidos este mes (${month.due}; hacen falta al menos $minSessions): no se propone ningún cambio de volumen o carga.',
      );
    } else {
      final adherence = month.adherence!;
      final pct = (adherence * 100).round();
      notes.add('Cumplimiento del mes: ${month.done}/${month.due} ($pct %).');
      if (adherence < .6) {
        if (minutes > 30) {
          minutes = (minutes - 15).clamp(30, 180);
          notes.add(
            'Cumpliste menos del 60 %: se propone acortar las sesiones a $minutes min para que sean más realistas.',
          );
        } else {
          notes.add(
            'Cumpliste menos del 60 %: las sesiones ya son cortas; la propuesta mantiene el plan.',
          );
        }
      } else if (adherence >= .85 && !held) {
        notes.add(
          'Buen cumplimiento. Los aumentos de carga se sugieren ejercicio por ejercicio en el panel de series, cuando hay datos suficientes; esta revisión no sube cargas.',
        );
      }
    }
    if (month.injuryDays > 0 || answers.pain) {
      notes.add(
        'Registraste dolor o lesión: no se propone ningún aumento. Si persiste, busca valoración profesional.',
      );
    } else if (month.fatigueDays > 0 || answers.energy == Energy.low) {
      notes.add(
        'Hubo cansancio o poca energía: no se propone ningún aumento este mes.',
      );
    }
    if (answers.difficulty == ReviewDifficulty.hard) {
      notes.add(
        'Dijiste que el plan te resulta difícil: revisa descansos y cargas; no se propone ningún aumento.',
      );
    } else if (answers.difficulty == ReviewDifficulty.easy && !held) {
      notes.add(
        'Dijiste que te resulta fácil. No se suben cargas por esa respuesta: cuando cumplas la regla de progresión recibirás la sugerencia.',
      );
    }
    final changes = <String>[
      if (answers.goal != current.goal) 'objetivo',
      if (!_sameSet(answers.equipment, current.equipment)) 'equipo',
      if (!_sameList(answers.trainingDays, current.trainingDays)) 'días',
      if (minutes != current.sessionMinutes) 'duración',
      if (answers.energy != current.energy) 'energía',
    ];
    if (changes.isNotEmpty) {
      notes.add('Cambios en tu perfil: ${changes.join(', ')}.');
    }
    return ReviewProposal(
      profile: current.copyWith(
        goal: answers.goal,
        energy: answers.energy,
        equipment: answers.equipment,
        trainingDays: [...answers.trainingDays]..sort(),
        sessionMinutes: minutes,
      ),
      notes: notes,
      insufficientData: insufficient,
      allowsIncrease: !held,
    );
  }

  /// Lines comparing two plans weekday by weekday, for the review screen.
  static List<String> comparePlans(PlanVersion current, PlanVersion proposed) {
    String describe(PlanVersion plan, int weekday) {
      final routine = plan.routineOnWeekday(weekday);
      return routine == null
          ? 'descanso'
          : '${routine.name} (${routine.exercises.length} ejercicios)';
    }

    final lines = <String>[];
    for (var d = DateTime.monday; d <= DateTime.sunday; d++) {
      final before = describe(current, d), after = describe(proposed, d);
      if (before == 'descanso' && after == 'descanso') continue;
      lines.add(
        '${weekdayNames[d - 1]}: $before → $after${before == after ? ' (igual)' : ''}',
      );
    }
    return lines;
  }

  static bool _sameSet(Set<Equipment> a, Set<Equipment> b) =>
      a.length == b.length && a.containsAll(b);
  static bool _sameList(List<int> a, List<int> b) {
    final x = [...a]..sort(), y = [...b]..sort();
    if (x.length != y.length) return false;
    for (var i = 0; i < x.length; i++) {
      if (x[i] != y[i]) return false;
    }
    return true;
  }
}
