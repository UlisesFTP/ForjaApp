import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/domain/expert/engine/pipeline.dart';
import 'package:forja_app/domain/expert/engine/rule.dart';
import 'package:forja_app/domain/expert/expert_coach.dart';
import 'package:forja_app/domain/expert/facts/coach_facts.dart';
import 'package:forja_app/domain/expert/knowledge/knowledge_base.dart';
import 'package:forja_app/domain/models/models.dart';

import 'expert_fixtures.dart';

/// A rule made up for the tests: it recommends what it is given and may veto.
class _Rule extends ExpertRule {
  const _Rule(
    this.id, {
    this.family = RuleFamily.plan,
    this.specificity = 1,
    this.subjects = const ['a'],
    this.action,
    this.vetoKind,
  });
  @override
  final String id;
  @override
  final RuleFamily family;
  @override
  final int specificity;
  final List<String> subjects;
  final CoachAction? action;
  final VetoKind? vetoKind;
  @override
  Evidence get evidence => const Evidence(EvidenceLevel.heuristic, 'prueba');

  @override
  Iterable<Veto> vetoes(CoachFacts f) => [
    if (vetoKind != null) veto(vetoKind!, 'motivo de prueba.'),
  ];

  @override
  Iterable<Recommendation> recommend(CoachFacts f, Vetoes vetoes) => [
    for (final s in subjects)
      make(
        subject: s,
        anchor: 'x',
        kind: RecommendationKind.suggestion,
        title: '$id $s',
        summary: 'resumen',
        because: const [FactRef('dato', 'valor')],
        action: action,
      ),
  ];
}

ExpertResult _run(List<ExpertRule> rules, [CoachInputs? inputs]) =>
    ExpertEngine(rules).evaluate(CoachFacts(inputs ?? coachInputs()));

void main() {
  group('expert engine (D37)', () {
    test('orders by salience, then specificity, then rule id, then key', () {
      final result = _run([
        const _Rule('plan.b', subjects: ['z', 'y']),
        const _Rule('logging.a', family: RuleFamily.logging),
        const _Rule('plan.a', specificity: 1),
        const _Rule('plan.c', specificity: 3),
        const _Rule('safety.x', family: RuleFamily.safety),
      ]);
      expect(
        [for (final r in result.recommendations) r.key],
        [
          'safety.x|a|x',
          'plan.c|a|x',
          'plan.a|a|x',
          'plan.b|y|x',
          'plan.b|z|x',
          'logging.a|a|x',
        ],
      );
    });

    test('a rule fires once per binding', () {
      final result = _run([
        const _Rule('plan.dup', subjects: ['a', 'a', 'b']),
      ]);
      expect([for (final r in result.recommendations) r.subject], ['a', 'b']);
      expect(result.trace.where((f) => f.ruleId == 'plan.dup'), hasLength(2));
    });

    test('the safety gate blocks a raise under a matching veto, with the '
        'reason, and nothing else', () {
      const raise = IncreaseLoad(
        exercise: 'squat',
        basedOn: '2026-10-01',
        fromKg: 60,
        toKg: 62.5,
      );
      final result = _run([
        const _Rule(
          'safety.stop',
          family: RuleFamily.safety,
          subjects: [],
          vetoKind: VetoKind.loadIncrease,
        ),
        const _Rule('progression.up', action: raise),
        const _Rule('plan.more', action: AddVolume()),
        const _Rule('plan.open', action: OpenPlanEditor()),
      ]);
      final byRule = {for (final r in result.recommendations) r.ruleId: r};
      expect(byRule['progression.up']!.kind, RecommendationKind.blocked);
      expect(byRule['progression.up']!.vetoedBy, 'safety.stop');
      expect(byRule['progression.up']!.action, isNull);
      expect(byRule['progression.up']!.summary, contains('motivo de prueba'));
      // A load veto does not stop added volume or a plain navigation.
      expect(byRule['plan.more']!.kind, RecommendationKind.suggestion);
      expect(byRule['plan.open']!.kind, RecommendationKind.suggestion);
      expect(result.trace.map((f) => f.outcome), contains('blocked'));
    });

    test('a veto for one exercise leaves the others alone', () {
      const veto = Veto(
        kind: VetoKind.loadIncrease,
        ruleId: 'safety.one',
        reason: 'r',
        exerciseId: 'squat',
      );
      final vetoes = Vetoes([veto]);
      const squat = IncreaseLoad(
        exercise: 'squat',
        basedOn: 'd',
        fromKg: 1,
        toKg: 2,
      );
      const bench = IncreaseLoad(
        exercise: 'bench',
        basedOn: 'd',
        fromKg: 1,
        toKg: 2,
      );
      expect(SafetyGate.vet(squat, vetoes), veto);
      expect(SafetyGate.vet(bench, vetoes), isNull);
      expect(SafetyGate.vet(const AddVolume(), vetoes), isNull);
    });

    test('no data gives no training advice and no error: only why the '
        'example plan looks as it does', () {
      final result = ExpertCoach.evaluate(coachInputs());
      expect(result.recommendations.map((r) => r.ruleId), [
        'plan.example-adapted',
      ]);
      expect(result.vetoes.all, isEmpty);
      expect(result.kbVersion, 'expert-v1');
    });

    test('the same data in any order gives the same answer', () {
      final history = [
        session('2026-09-22', [logged('squat'), logged('rdl')]),
        session('2026-09-29', [logged('squat'), logged('rdl', reps: 3)]),
        session('2026-09-24', [logged('bench')]),
        session('2026-10-01', [logged('bench')]),
        session('2026-09-26', [logged('row', rir: 0)]),
      ];
      final checkIns = {
        '2026-09-24': const CheckIn(feeling: Feeling.normal),
        '2026-10-01': const CheckIn(feeling: Feeling.energetic),
      };
      String describe(ExpertResult r) => [
        for (final x in r.recommendations)
          '${x.key}|${x.kind}|${x.summary}|${x.because}',
        for (final v in r.vetoes.all) '${v.ruleId}|${v.exerciseId}',
        r.todayLine,
      ].join('\n');
      final expected = describe(
        ExpertCoach.evaluate(coachInputs(history: history, checkIns: checkIns)),
      );
      final random = Random(37);
      for (var i = 0; i < 20; i++) {
        final shuffled = [...history]..shuffle(random);
        expect(
          describe(
            ExpertCoach.evaluate(
              coachInputs(history: shuffled, checkIns: checkIns),
            ),
          ),
          expected,
        );
      }
    });

    test('the real knowledge base is ordered by precedence', () {
      final engine = ExpertEngine(knowledgeBaseV1);
      for (var i = 1; i < engine.rules.length; i++) {
        expect(
          engine.rules[i - 1].salience,
          greaterThanOrEqualTo(engine.rules[i].salience),
        );
      }
    });
  });
}
