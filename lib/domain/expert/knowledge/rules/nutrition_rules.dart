import '../../engine/rule.dart';
import '../../facts/coach_facts.dart';
import '../../model/coach_action.dart';
import '../../model/recommendation.dart';
import '../../model/veto.dart';
import '../evidence.dart';
import '../thresholds.dart';

String _g(double v) => '${v.round()} g';

/// N1 · With goals of one's own and at least 4 of the last 7 days logged:
/// the averages of the logged days next to the goals. Empty days are left
/// out, never counted as 0. No judgement: just the numbers.
class AveragesVsGoals extends ExpertRule {
  const AveragesVsGoals();
  @override
  String get id => 'nutrition.averages';
  @override
  RuleFamily get family => RuleFamily.nutrition;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 3;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final goals = f.inputs.goals;
    if (goals.isEmpty) return const [];
    final days = f.loggedDays(7);
    if (days.length < Thresholds.loggedDaysForAverage) return const [];
    final entries = [for (final d in days) ...f.foodOn(d)];
    final kcal =
        entries.fold<int>(0, (sum, e) => sum + e.calories) / days.length;
    final parts = <String>[
      'media de ${kcal.round()} kcal'
          '${goals.kcal == null ? '' : ' (objetivo ${goals.kcal})'}',
    ];
    final because = <FactRef>[
      FactRef('Días registrados de los últimos 7', '${days.length}'),
      FactRef('Media de calorías', '${kcal.round()} kcal'),
    ];
    if (goals.proteinG != null) {
      if (entries.every((e) => e.proteinG != null)) {
        final protein =
            entries.fold<double>(0, (sum, e) => sum + e.proteinG!) /
            days.length;
        parts.add(
          'proteína ${_g(protein)} de media (objetivo ${_g(goals.proteinG!)})',
        );
        because.add(FactRef('Media de proteína', _g(protein)));
      } else {
        parts.add(
          'la proteína no se puede promediar porque falta en algunas comidas',
        );
      }
    }
    return [
      make(
        subject: 'averages',
        anchor: days.last,
        kind: RecommendationKind.info,
        title: 'Tu semana de comidas',
        summary:
            'En los ${days.length} días registrados de la última semana (sin '
            'contar hoy): ${parts.join('; ')}. Los días sin registrar no '
            'cuentan.',
        because: because,
        threshold: '${Thresholds.loggedDaysForAverage} días registrados de 7',
      ),
    ];
  }
}

/// N2 · Several days of the last week without any food logged, for someone
/// who logs: the comparison needs data, and empty is not 0.
class UnloggedDays extends ExpertRule {
  const UnloggedDays();
  @override
  String get id => 'nutrition.unlogged';
  @override
  RuleFamily get family => RuleFamily.nutrition;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 2;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    if (!f.usesNutrition) return const [];
    final missing = 7 - f.loggedDays(7).length;
    if (missing < Thresholds.unloggedDaysTip) return const [];
    return [
      make(
        subject: 'unlogged',
        anchor: f.todayKey,
        kind: RecommendationKind.info,
        title: 'Días sin comidas',
        summary:
            'Hay $missing días de la última semana sin comidas registradas. '
            'Si quieres comparar con tus objetivos, registra aunque sea lo '
            'principal; los días vacíos no cuentan como 0.',
        because: [FactRef('Días sin registrar de los últimos 7', '$missing')],
        threshold: '${Thresholds.unloggedDaysTip} días',
      ),
    ];
  }
}

/// N3 · Macro goals set, but macros known for under half the entries.
class MacroCoverage extends ExpertRule {
  const MacroCoverage();
  @override
  String get id => 'nutrition.macro-coverage';
  @override
  RuleFamily get family => RuleFamily.nutrition;
  @override
  Evidence get evidence => heuristic;
  @override
  int get specificity => 3;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    final g = f.inputs.goals;
    if (g.proteinG == null && g.carbsG == null && g.fatG == null) {
      return const [];
    }
    final entries = [for (var i = 1; i <= 7; i++) ...f.foodOn(f.keyDaysAgo(i))];
    if (entries.length < 5) return const [];
    final known = entries
        .where((e) => e.proteinG != null && e.carbsG != null && e.fatG != null)
        .length;
    if (known / entries.length >= Thresholds.macroCoverageTip) {
      return const [];
    }
    return [
      make(
        subject: 'macros',
        anchor: f.todayKey,
        kind: RecommendationKind.info,
        title: 'Macros incompletos',
        summary:
            'Solo $known de ${entries.length} comidas de la última semana '
            'tienen sus macros. Añadirlos mejora la comparación con tus '
            'objetivos.',
        because: [FactRef('Comidas con macros', '$known de ${entries.length}')],
        threshold: 'la mitad de las comidas',
      ),
    ];
  }
}

/// N4 · No protein goal: a general, non-clinical reference for adults who
/// train (D39), never a diet or a goal worked out for the person. None for
/// a minor.
class ProteinReference extends ExpertRule {
  const ProteinReference();
  @override
  String get id => 'nutrition.protein-reference';
  @override
  RuleFamily get family => RuleFamily.nutrition;
  @override
  Evidence get evidence =>
      const Evidence(EvidenceLevel.high, Sources.morton2018);
  @override
  int get specificity => 2;

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) {
    if (vetoes.any(VetoKind.nutritionRanges)) return const [];
    if (f.inputs.goals.proteinG != null || !f.usesNutrition) return const [];
    final weight = f.profile.weightKg;
    const range =
        '${Thresholds.proteinMinGPerKg}–${Thresholds.proteinMaxGPerKg}';
    final rangeText = range.replaceAll('.', ',');
    final grams = weight == null
        ? null
        : '${(weight * Thresholds.proteinMinGPerKg).round()}–'
              '${(weight * Thresholds.proteinMaxGPerKg).round()} g';
    return [
      make(
        subject: 'protein',
        anchor: weight == null ? 'sin-peso' : '$weight',
        kind: RecommendationKind.info,
        title: 'Referencia general de proteína',
        summary:
            'Referencia general para adultos que entrenan fuerza: $rangeText g '
            'de proteína por kg al día'
            '${grams == null ? '' : ' (unos $grams para tus ${weight!.round()} kg)'}, '
            'repartidos en 3–4 comidas. No es una dieta ni un objetivo '
            'calculado para ti: puedes fijar tus propios objetivos.'
            '${grams == null ? ' Si añades tu peso en el perfil, verás la cifra en gramos.' : ''}',
        because: [
          if (weight != null)
            FactRef('Peso del perfil', '${weight.round()} kg'),
          const FactRef('Objetivo de proteína', 'sin fijar'),
        ],
        threshold: '$rangeText g/kg',
        action: const OpenNutritionGoals(),
      ),
    ];
  }
}
