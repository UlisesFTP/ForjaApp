import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/progression_engine.dart';
import 'package:forja_app/domain/services/review_service.dart';

import 'support/sqlite_harness.dart';

final throwsInjected = throwsA(
  predicate((Object e) => e.toString().contains('InjectedFailure')),
);

void main() {
  final tuesday = DateTime(2026, 9, 29);
  final now = DateTime.utc(2026, 10, 1, 9);
  late StoreHarness h;
  late Opened db;
  setUp(() async {
    h = await StoreHarness.create();
    db = await h.open(clock: () => now);
  });
  tearDown(() => h.dispose());
  Future<Opened> reopen() async {
    await db.close();
    return db = await h.open(clock: () => now);
  }

  group('technique (F08 input)', () {
    test(
      'is stored per exercise, can be cleared, and survives restart',
      () async {
        final repo = db.repo;
        expect(repo.sessionOn(tuesday)!.exercises.first.technique, isNull);
        await repo.setTechnique(tuesday, 'squat', TechniqueRating.unstable);
        await repo.setTechnique(tuesday, 'rdl', TechniqueRating.solid);
        var session = (await reopen()).repo.sessionOn(tuesday)!;
        expect(
          {for (final e in session.exercises) e.exerciseId: e.technique},
          {
            'squat': TechniqueRating.unstable,
            'rdl': TechniqueRating.solid,
            'press': null,
          },
        );
        await db.repo.setTechnique(tuesday, 'squat', null);
        session = (await reopen()).repo.sessionOn(tuesday)!;
        expect(session.exercises.first.technique, isNull);
      },
    );

    test('rating does not reopen a finished session', () async {
      final repo = db.repo;
      for (final e in repo.sessionOn(tuesday)!.exercises) {
        await repo.toggleExercise(tuesday, e.exerciseId);
      }
      await repo.finishSession(tuesday, SessionStatus.completed);
      await repo.setTechnique(tuesday, 'squat', TechniqueRating.solid);
      expect(repo.sessionOn(tuesday)!.status, SessionStatus.completed);
      expect(repo.eventsOn(tuesday), isEmpty);
    });

    test('an unknown exercise is refused', () async {
      await expectLater(
        db.repo.setTechnique(tuesday, 'nope', TechniqueRating.solid),
        throwsArgumentError,
      );
    });
  });

  group('progression decisions (F08)', () {
    Future<void> accept(
      Opened o, {
      double to = 62.5,
      String based = '2026-09-25',
    }) => o.repo.decideProgression(
      exerciseId: 'squat',
      kind: ProgressionKind.increase,
      basedOn: based,
      ruleVersion: progressionRulesVersion,
      status: DecisionStatus.accepted,
      fromKg: 60,
      toKg: to,
    );

    test(
      'accepting sets the working weight of sessions that do not exist yet',
      () async {
        final repo = db.repo;
        expect(repo.workingWeight('squat'), isNull);
        final before = repo.sessionOn(DateTime(2026, 10, 6))!.exercises.first;
        await accept(db);
        expect(repo.workingWeight('squat'), 62.5);
        expect(
          repo.sessionOn(DateTime(2026, 10, 6))!.exercises.first.weightKg,
          62.5,
        );
        expect(before.weightKg, isNot(62.5));
        expect((await reopen()).repo.workingWeight('squat'), 62.5);
      },
    );

    test('a saved session and past history keep their weights', () async {
      final repo = db.repo;
      await repo.updateWeight(tuesday, 'squat', 55);
      await accept(db);
      expect(repo.sessionOn(tuesday)!.exercises.first.weightKg, 55);
      final reopened = await reopen();
      expect(reopened.repo.sessionOn(tuesday)!.exercises.first.weightKg, 55);
    });

    test('deciding twice does not apply twice', () async {
      await accept(db);
      await accept(db, to: 65);
      await db.repo.decideProgression(
        exerciseId: 'squat',
        kind: ProgressionKind.increase,
        basedOn: '2026-09-25',
        ruleVersion: progressionRulesVersion,
        status: DecisionStatus.rejected,
      );
      expect(db.repo.progressionDecisions, hasLength(1));
      expect(db.repo.workingWeight('squat'), 62.5);
      final rows = await db.db
          .customSelect('SELECT COUNT(*) AS n FROM progression_decisions')
          .getSingle();
      expect(rows.read<int>('n'), 1);
    });

    test('a rejection is recorded and changes no weight', () async {
      await db.repo.decideProgression(
        exerciseId: 'squat',
        kind: ProgressionKind.increase,
        basedOn: '2026-09-25',
        ruleVersion: progressionRulesVersion,
        status: DecisionStatus.rejected,
        fromKg: 60,
        toKg: 62.5,
      );
      expect(db.repo.workingWeight('squat'), isNull);
      final stored = (await reopen()).repo.progressionDecisions.single;
      expect(stored.status, DecisionStatus.rejected);
      expect(stored.decidedAt, now);
      expect(stored.ruleVersion, progressionRulesVersion);
    });

    test(
      'a newer suggestion (later session) can be decided separately',
      () async {
        await accept(db);
        await accept(db, to: 65, based: '2026-10-02');
        expect(db.repo.progressionDecisions, hasLength(2));
        expect(db.repo.workingWeight('squat'), 65);
      },
    );

    test('only a real increase can be accepted', () async {
      final repo = db.repo;
      for (final (kind, from, to) in [
        (ProgressionKind.hold, 60.0, 62.5),
        (ProgressionKind.increase, null, 62.5),
        (ProgressionKind.increase, 60.0, null),
        (ProgressionKind.increase, 60.0, 60.0),
        (ProgressionKind.increase, 60.0, 55.0),
        (ProgressionKind.increase, 60.0, double.nan),
        (ProgressionKind.increase, 60.0, 5000.0),
      ]) {
        await expectLater(
          repo.decideProgression(
            exerciseId: 'squat',
            kind: kind,
            basedOn: 'x',
            ruleVersion: progressionRulesVersion,
            status: DecisionStatus.accepted,
            fromKg: from,
            toKg: to,
          ),
          throwsArgumentError,
          reason: '$kind $from $to',
        );
      }
      await expectLater(
        repo.decideProgression(
          exerciseId: 'nope',
          kind: ProgressionKind.increase,
          basedOn: 'x',
          ruleVersion: progressionRulesVersion,
          status: DecisionStatus.rejected,
        ),
        throwsArgumentError,
      );
      expect(repo.progressionDecisions, isEmpty);
    });

    test('a failed write stores nothing and a retry succeeds', () async {
      h.fault.arm(
        (sql) =>
            sql.startsWith('INSERT') && sql.contains('progression_decisions'),
      );
      await expectLater(accept(db), throwsInjected);
      expect(db.repo.progressionDecisions, isEmpty);
      h.fault.disarm();
      await accept(db);
      expect(db.repo.progressionDecisions, hasLength(1));
    });

    test('concurrent identical decisions store one', () async {
      await Future.wait([accept(db), accept(db), accept(db)]);
      expect(db.repo.progressionDecisions, hasLength(1));
    });
  });

  group('monthly review (F07)', () {
    MonthlyReview review(
      String id,
      ReviewOutcome outcome, {
      String on = '2026-10-01',
    }) => MonthlyReview(
      id: id,
      reviewedOn: on,
      outcome: outcome,
      rulesVersion: reviewRulesVersion,
      sessionsDone: 5,
      sessionsDue: 8,
      answers: const {'energy': 'normal', 'pain': false},
      proposal: const ['Cumplimiento del mes: 5/8 (63 %).'],
      createdAt: now,
    );

    final answered = const UserProfile(
      onboarded: true,
      lastReview: '2026-08-30',
      goal: TrainingGoal.muscle,
      note: 'sin cambios',
    );

    test('accepting saves the review, the profile, the draft and the history together', () async {
      await db.repo.saveProfile(answered);
      final draft = PlanVersion(
        id: 'draft1',
        status: PlanStatus.draft,
        source: PlanSource.generated,
        name: 'Propuesta',
        createdAt: now,
        days: [
          PlanDay(
            DateTime.monday,
            Routine(
              id: 'r1',
              name: 'A',
              focus: '',
              warmup: '',
              exercises: [
                PlanExercise.fromExercise(db.repo.exerciseById('squat')),
                PlanExercise.fromExercise(db.repo.exerciseById('rdl')),
                PlanExercise.fromExercise(db.repo.exerciseById('press')),
              ],
            ),
          ),
          PlanDay(
            DateTime.wednesday,
            Routine(
              id: 'r2',
              name: 'B',
              focus: '',
              warmup: '',
              exercises: [
                PlanExercise.fromExercise(db.repo.exerciseById('bench')),
                PlanExercise.fromExercise(db.repo.exerciseById('shoulder')),
                PlanExercise.fromExercise(db.repo.exerciseById('triceps')),
              ],
            ),
          ),
          PlanDay(
            DateTime.friday,
            Routine(
              id: 'r3',
              name: 'C',
              focus: '',
              warmup: '',
              exercises: [
                PlanExercise.fromExercise(db.repo.exerciseById('row')),
                PlanExercise.fromExercise(db.repo.exerciseById('pulldown')),
                PlanExercise.fromExercise(db.repo.exerciseById('curl')),
              ],
            ),
          ),
        ],
      );
      final proposed = answered.copyWith(
        sessionMinutes: 45,
        trainingDays: const [
          DateTime.friday,
          DateTime.monday,
          DateTime.wednesday,
        ],
        reviewSnoozeUntil: () => '2026-10-08',
      );
      await db.repo.completeReview(
        review('rv1', ReviewOutcome.accepted),
        profile: proposed,
        draft: draft,
      );
      void expectAll(Opened o) {
        expect(o.repo.reviews.single.id, 'rv1');
        expect(o.repo.reviews.single.answers['energy'], 'normal');
        expect(o.repo.reviews.single.proposal.single, contains('5/8'));
        expect(o.repo.profile.sessionMinutes, 45);
        expect(o.repo.profile.trainingDays, [1, 3, 5]);
        expect(o.repo.profile.lastReview, '2026-10-01');
        expect(
          o.repo.profile.reviewSnoozeUntil,
          isNull,
          reason: 'a review ends a postponement',
        );
        expect(o.repo.draft!.id, 'draft1');
        final last = o.repo.profileHistory.last;
        expect(last.reason, ProfileChange.review);
        expect(last.rulesVersion, reviewRulesVersion);
        expect(last.profile.sessionMinutes, 45);
      }

      expectAll(db);
      expectAll(await reopen());
    });

    test(
      'a rejection changes nothing but the review date, and is recorded',
      () async {
        await db.repo.saveProfile(answered);
        final before = db.repo.profile;
        await db.repo.completeReview(review('rv2', ReviewOutcome.rejected));
        final after = (await reopen()).repo.profile;
        expect(after.lastReview, '2026-10-01');
        expect(after.goal, before.goal);
        expect(after.sessionMinutes, before.sessionMinutes);
        expect(after.trainingDays, before.trainingDays);
        expect(db.repo.draft, isNull);
        expect(db.repo.reviews.single.outcome, ReviewOutcome.rejected);
        expect(
          db.repo.profileHistory.last.reason,
          ProfileChange.reviewRejected,
        );
      },
    );

    test('a rejection cannot carry changes', () async {
      await expectLater(
        db.repo.completeReview(
          review('rv3', ReviewOutcome.rejected),
          profile: answered,
        ),
        throwsArgumentError,
      );
      expect(db.repo.reviews, isEmpty);
    });

    test(
      'completing the same review twice stores it once (idempotent)',
      () async {
        await db.repo.saveProfile(answered);
        final rv = review('rv4', ReviewOutcome.accepted);
        await db.repo.completeReview(
          rv,
          profile: answered.copyWith(sessionMinutes: 45),
        );
        await db.repo.completeReview(
          rv,
          profile: answered.copyWith(sessionMinutes: 30),
        );
        expect(db.repo.reviews, hasLength(1));
        expect(db.repo.profile.sessionMinutes, 45);
        final historyEntries = db.repo.profileHistory
            .where((a) => a.reason == ProfileChange.review)
            .length;
        expect(historyEntries, 1);
      },
    );

    test(
      'postponing hides the review for the chosen days and survives restart',
      () async {
        await db.repo.saveProfile(answered);
        await db.repo.snoozeReview(DateTime(2026, 10, 8));
        expect(db.repo.profile.reviewSnoozeUntil, '2026-10-08');
        final reopened = await reopen();
        expect(
          ReviewService.status(
            reopened.repo.profile,
            DateTime(2026, 10, 7),
          ).due,
          isFalse,
        );
        expect(
          ReviewService.status(
            reopened.repo.profile,
            DateTime(2026, 10, 8),
          ).due,
          isTrue,
        );
      },
    );

    test(
      'a failing write stores no review and leaves the profile alone',
      () async {
        await db.repo.saveProfile(answered);
        final before = await db.counts();
        h.fault.arm(
          (sql) => sql.startsWith('INSERT') && sql.contains('monthly_reviews'),
        );
        await expectLater(
          db.repo.completeReview(
            review('rv5', ReviewOutcome.accepted),
            profile: answered.copyWith(sessionMinutes: 45),
          ),
          throwsInjected,
        );
        expect(await db.counts(), before);
        expect(db.repo.profile.sessionMinutes, 60);
        expect(db.repo.reviews, isEmpty);
      },
    );

    test('earlier reviews and history entries are never rewritten', () async {
      await db.repo.saveProfile(answered);
      await db.repo.completeReview(review('a', ReviewOutcome.rejected));
      final first = db.repo.reviews.single.toJson();
      await db.repo.completeReview(
        review('b', ReviewOutcome.accepted, on: '2026-11-02'),
        profile: answered.copyWith(sessionMinutes: 45),
      );
      final reopened = await reopen();
      expect(reopened.repo.reviews, hasLength(2));
      expect(reopened.repo.reviews.first.toJson(), first);
      expect(
        reopened.repo.profileHistory
            .map((a) => a.reason)
            .toList()
            .sublist(reopened.repo.profileHistory.length - 2),
        [ProfileChange.reviewRejected, ProfileChange.review],
      );
    });
  });
}
