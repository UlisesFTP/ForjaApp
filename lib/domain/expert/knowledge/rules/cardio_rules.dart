import '../../../../core/date_utils.dart';
import '../../../models/labels.dart';
import '../../../models/models.dart';
import '../../engine/rule.dart';
import '../../facts/coach_facts.dart';
import '../../model/coach_action.dart';
import '../../model/recommendation.dart';
import '../evidence.dart';
import '../thresholds.dart';

/// C1 · The week's moderate-equivalent cardio against the WHO reference
/// (150–300 min for adults). Only for people who log cardio.
class WhoWeek extends ExpertRule {
  const WhoWeek();
  @override
  String get id => 'cardio.who-week';
  @override
  RuleFamily get family => RuleFamily.cardio;
  @override
  Evidence get evidence => const Evidence(
    EvidenceLevel.high,
    '${Sources.who2020} Intensidad según ${Sources.compendium}',
  );
  @override
  int get specificity => 2;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    // Only for someone who logs cardio: any session in the last 4 weeks.
    final logsCardio = f.inputs.cardio.any((c) {
      final ago = f.daysAgo(dateKey(c.startedAt.toLocal()));
      return ago >= 0 && ago < 28;
    });
    if (!logsCardio) return const [];
    final minutes = f.moderateMinutes(7);
    final enough = minutes >= Thresholds.whoWeeklyMin;
    return [
      make(
        subject: 'who',
        anchor: dateKey(weekOf(f.today).first),
        kind: RecommendationKind.info,
        title: enough ? 'Cardio de la semana' : 'Cardio de la semana: poco',
        summary: enough
            ? 'En los últimos 7 días sumas unos $minutes min de cardio de '
                  'intensidad moderada equivalente: dentro de la referencia de '
                  'la OMS (${Thresholds.whoWeeklyMin}–${Thresholds.whoWeeklyMax} '
                  'min a la semana para adultos).'
            : 'En los últimos 7 días sumas unos $minutes min de cardio de '
                  'intensidad moderada equivalente. La OMS recomienda '
                  '${Thresholds.whoWeeklyMin}–${Thresholds.whoWeeklyMax} min a '
                  'la semana para adultos (la actividad intensa cuenta doble). '
                  'Tú eliges cómo y cuándo.',
        because: [
          FactRef('Minutos equivalentes en 7 días', '$minutes'),
          const FactRef(
            'Cómo se cuenta',
            'MET menor de 3 no cuenta; 6 o más cuenta doble',
          ),
        ],
        threshold: '${Thresholds.whoWeeklyMin} min por semana',
        action: enough ? null : const OpenCardio(),
      ),
    ];
  }
}

/// C2 · Two comparable, comfortable cardio sessions: the person may make it
/// longer or harder (F08: the person chooses the change).
class CardioProgress extends ExpertRule {
  const CardioProgress();
  @override
  String get id => 'cardio.progress';
  @override
  RuleFamily get family => RuleFamily.cardio;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 4;

  static CardioIntensity? _single(CardioSession s) {
    final intensities = {for (final x in s.segments) x.intensity};
    return intensities.length == 1 ? intensities.first : null;
  }

  static int _minutes(CardioSession s) => s.segments
      .fold(
        Duration.zero,
        (sum, x) => sum + x.duration(x.endedAt ?? x.startedAt),
      )
      .inMinutes;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final recent = [
      for (final c in f.inputs.cardio)
        if (c.status == CardioStatus.finished &&
            f.daysAgo(dateKey(c.startedAt.toLocal())) <
                Thresholds.comparableCardioDays &&
            f.daysAgo(dateKey(c.startedAt.toLocal())) >= 0)
          c,
    ];
    if (recent.length < 2) return const [];
    final last = recent.last, intensity = _single(last);
    if (intensity == null) return const [];
    final same = [
      for (final c in recent)
        if (c.activity == last.activity && _single(c) == intensity) c,
    ];
    if (same.length < 2) return const [];
    final pair = same.sublist(same.length - 2);
    final a = _minutes(pair[0]), b = _minutes(pair[1]);
    final longest = a > b ? a : b;
    if (longest == 0 ||
        (a - b).abs() > longest * Thresholds.comparableDurationShare) {
      return const [];
    }
    bool comfortable(CardioSession c) =>
        c.feedback == Feeling.normal || c.feedback == Feeling.energetic;
    if (!pair.every(comfortable)) return const [];
    final name =
        '${cardioLabels[last.activity]!.toLowerCase()} '
        '${cardioIntensityLabels[intensity]!.toLowerCase()}';
    return [
      make(
        subject: last.activity.name,
        anchor: last.id,
        kind: RecommendationKind.info,
        title: 'Cardio cómodo',
        summary:
            'Tus dos últimas sesiones de $name (unos $b min) te sentaron '
            'bien. Si te apetece, puedes alargar un poco o subir la '
            'intensidad; tú eliges.',
        because: [
          for (final c in pair)
            FactRef(
              'Sesión de $name',
              '${_minutes(c)} min · ${c.feedback == Feeling.energetic ? 'con energía' : 'normal'}',
              date: dateKey(c.startedAt.toLocal()),
            ),
        ],
        threshold: 'duración parecida (±10 %) y sensación normal o mejor',
        action: const OpenCardio(),
      ),
    ];
  }
}
