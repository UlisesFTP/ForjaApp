import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/core/date_utils.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/progress_stats.dart';
import 'package:forja_app/domain/services/progression_engine.dart';
import 'package:forja_app/domain/services/review_service.dart';

SetLog work(
  int n, {
  double? kg,
  int? reps,
  int? rir,
  SetKind kind = SetKind.work,
  SetStatus status = SetStatus.done,
}) => SetLog(
  id: 's$n${kind.name}',
  kind: kind,
  number: n,
  status: status,
  weightKg: kg,
  reps: reps,
  rir: rir,
);

ExerciseLog log(
  String id,
  List<SetLog> sets, {
  bool completed = true,
  TechniqueRating? technique = TechniqueRating.solid,
}) => ExerciseLog(
  exerciseId: id,
  weightKg: 0,
  completed: completed,
  technique: technique,
  sets: sets,
);

void main() {
  group('progression engine (F08 decision table)', () {
    // Squat: 3 sets of 5–8? read the plan from the catalog.
    final planned = PlanExercise.fromExercise(exerciseFor('squat'));
    final squat = exerciseFor('squat');

    List<SetLog> full({double kg = 60, int? reps, int? rir, int? count}) => [
      for (var i = 1; i <= (count ?? planned.sets); i++)
        work(i, kg: kg, reps: reps ?? planned.repsMax, rir: rir ?? planned.rir),
    ];

    Exposure day(
      String date,
      List<SetLog> sets, {
      Feeling? feeling,
      TechniqueRating? technique = TechniqueRating.solid,
      bool completed = true,
    }) => Exposure(
      dateKey: date,
      feeling: feeling,
      log: log('squat', sets, technique: technique, completed: completed),
    );

    ProgressionSuggestion run(
      List<Exposure> exposures, {
      Feeling? now,
      PlanExercise? plan,
    }) => ProgressionEngine.evaluate(
      planned: plan ?? planned,
      exercise: squat,
      exposures: exposures,
      feelingNow: now,
    );

    test(
      'two eligible sessions at the top of the range suggest the increment',
      () {
        final s = run([day('2026-09-22', full()), day('2026-09-25', full())]);
        expect(s.kind, ProgressionKind.increase);
        expect(s.fromKg, 60);
        expect(s.toKg, 60 + planned.incrementKg);
        expect(s.sessions, ['2026-09-22', '2026-09-25']);
        expect(s.basedOn, '2026-09-25');
        expect(s.actionable, isTrue);
        expect(s.explanation, contains('${planned.repsMax} repeticiones'));
        expect(s.explanation, contains('${planned.incrementKg}'));
        expect(s.missing, isEmpty);
      },
    );

    test('only the two latest sessions count, whatever the order given', () {
      final s = run([
        day('2026-09-25', full()),
        day('2026-09-10', full(reps: 1)),
        day('2026-09-22', full()),
      ]);
      expect(s.kind, ProgressionKind.increase);
      expect(s.sessions, ['2026-09-22', '2026-09-25']);
    });

    test('a single session is not enough', () {
      final s = run([day('2026-09-25', full())]);
      expect(s.kind, ProgressionKind.hold);
      expect(s.missing.single, contains('1 de 2'));
      expect(run(const []).kind, ProgressionKind.hold);
    });

    test('top of the range in only one of the sessions holds', () {
      final s = run([
        day('2026-09-22', full(reps: planned.repsMax - 1)),
        day('2026-09-25', full()),
      ]);
      expect(s.kind, ProgressionKind.hold);
      expect(s.toKg, isNull);
      expect(s.explanation, contains('Mantén'));
    });

    test(
      'effort tighter than planned (RIR) does not qualify, even at the top',
      () {
        final s = run([
          day('2026-09-22', full(rir: planned.rir - 1)),
          day('2026-09-25', full(rir: planned.rir - 1)),
        ]);
        expect(s.kind, ProgressionKind.hold);
        // Going to failure is a record of effort, not a reason to add load.
        final zero = run([
          day('2026-09-22', full(rir: 0)),
          day('2026-09-25', full(rir: 0)),
        ]);
        expect(zero.kind, ProgressionKind.hold);
      },
    );

    test('a looser RIR than planned still qualifies', () {
      final s = run([
        day('2026-09-22', full(rir: planned.rir + 2)),
        day('2026-09-25', full(rir: planned.rir + 1)),
      ]);
      expect(s.kind, ProgressionKind.increase);
    });

    test(
      'one tap on the checklist (no sets) never makes a session eligible',
      () {
        final s = run([
          day('2026-09-22', const []),
          day('2026-09-25', const []),
        ]);
        expect(s.kind, ProgressionKind.hold);
        expect(s.missing, isNotEmpty);
        expect(s.toKg, isNull);
      },
    );

    test('fewer work sets than planned lists what is missing', () {
      final s = run([
        day('2026-09-22', full(count: planned.sets - 1)),
        day('2026-09-25', full()),
      ]);
      expect(s.kind, ProgressionKind.hold);
      expect(
        s.missing.single,
        contains('${planned.sets - 1} de ${planned.sets}'),
      );
    });

    test('warm-ups and skipped sets are not work sets', () {
      final padded = [
        work(1, kg: 20, reps: 10, rir: 4, kind: SetKind.warmup),
        ...full(count: planned.sets - 1),
        work(9, status: SetStatus.skipped),
      ];
      final s = run([day('2026-09-22', padded), day('2026-09-25', full())]);
      expect(s.kind, ProgressionKind.hold);
      expect(s.missing.single, contains('${planned.sets - 1} de'));
    });

    test(
      'missing reps, effort, load or technique are named, never guessed',
      () {
        final sets = [
          work(1, kg: 60, reps: null, rir: 2),
          work(2, kg: 60, reps: planned.repsMax, rir: null),
          work(3, kg: null, reps: planned.repsMax, rir: 2),
        ];
        final s = run([
          day('2026-09-22', sets, technique: null),
          day('2026-09-25', full()),
        ], plan: planned.copyWith(sets: 3));
        expect(s.kind, ProgressionKind.hold);
        final text = s.missing.join('\n');
        expect(text, contains('faltan repeticiones en 1'));
        expect(text, contains('falta el esfuerzo (RIR) en 1'));
        expect(text, contains('falta la carga en 1'));
        expect(text, contains('falta valorar la técnica'));
      },
    );

    test('an injury, tiredness or soreness in either session blocks an increase', () {
      for (final feeling in [Feeling.injured, Feeling.tired, Feeling.doms]) {
        final first = run([
          day('2026-09-22', full(), feeling: feeling),
          day('2026-09-25', full()),
        ]);
        final second = run([
          day('2026-09-22', full()),
          day('2026-09-25', full(), feeling: feeling),
        ]);
        final today = run([
          day('2026-09-22', full()),
          day('2026-09-25', full()),
        ], now: feeling);
        for (final s in [first, second, today]) {
          expect(s.kind, ProgressionKind.blocked, reason: feeling.name);
          expect(s.toKg, isNull);
        }
      }
      // Feeling normal or energetic never blocks, and never forces an increase.
      final fine = run([
        day('2026-09-22', full(), feeling: Feeling.energetic),
        day(
          '2026-09-25',
          full(reps: planned.repsMax - 1),
          feeling: Feeling.normal,
        ),
      ]);
      expect(fine.kind, ProgressionKind.hold);
    });

    test('unstable technique blocks; unknown technique asks for the data', () {
      final shaky = run([
        day('2026-09-22', full(), technique: TechniqueRating.unstable),
        day('2026-09-25', full()),
      ]);
      expect(shaky.kind, ProgressionKind.blocked);
      expect(shaky.explanation, contains('técnica inestable'));
      final unknown = run([
        day('2026-09-22', full(), technique: null),
        day('2026-09-25', full()),
      ]);
      expect(unknown.kind, ProgressionKind.hold);
      expect(unknown.missing.single, contains('técnica'));
    });

    test('below the minimum twice asks to review load and technique, with no prescribed cut', () {
      final low = full(reps: planned.repsMin - 1);
      final s = run([day('2026-09-22', low), day('2026-09-25', low)]);
      expect(s.kind, ProgressionKind.review);
      expect(s.toKg, isNull);
      expect(s.explanation, contains('Revisa la carga'));
      // Once is not twice.
      final once = run([
        day('2026-09-22', low),
        day('2026-09-25', full(reps: planned.repsMin)),
      ]);
      expect(once.kind, ProgressionKind.hold);
    });

    test('different loads are not comparable', () {
      final s = run([
        day('2026-09-22', full(kg: 60)),
        day('2026-09-25', full(kg: 62.5)),
      ]);
      expect(s.kind, ProgressionKind.hold);
      expect(s.explanation, contains('no son comparables'));
      final mixed = run([
        day('2026-09-22', [
          work(1, kg: 60, reps: planned.repsMax, rir: planned.rir),
          work(2, kg: 55, reps: planned.repsMax, rir: planned.rir),
          work(3, kg: 60, reps: planned.repsMax, rir: planned.rir),
        ]),
        day('2026-09-25', full()),
      ], plan: planned.copyWith(sets: 3));
      expect(mixed.kind, ProgressionKind.hold);
    });

    test('without a configured increment it holds and says so', () {
      final s = run([
        day('2026-09-22', full()),
        day('2026-09-25', full()),
      ], plan: planned.copyWith(incrementKg: 0));
      expect(s.kind, ProgressionKind.hold);
      expect(s.missing.single, contains('Incremento'));
    });

    test('decimals and the configured increment are respected', () {
      final s = run([
        day('2026-09-22', full(kg: 22.5)),
        day('2026-09-25', full(kg: 22.5)),
      ], plan: planned.copyWith(incrementKg: 1.25));
      expect(s.toKg, 23.75);
      expect(s.explanation, contains('1.25 kg'));
    });

    test('skipped or unfinished exercises are not exposures', () {
      final s = run([
        day('2026-09-22', full()),
        day('2026-09-25', full(), completed: false),
      ]);
      expect(s.kind, ProgressionKind.hold);
      expect(s.missing.single, contains('1 de 2'));
    });

    test('bodyweight and timed exercises never get a load suggestion', () {
      final pushup = exerciseFor('pushup');
      final s = ProgressionEngine.evaluate(
        planned: PlanExercise.fromExercise(pushup),
        exercise: pushup,
        exposures: [
          Exposure(dateKey: '2026-09-22', log: log('pushup', full())),
          Exposure(dateKey: '2026-09-25', log: log('pushup', full())),
        ],
      );
      expect(s.kind, ProgressionKind.hold);
      expect(s.toKg, isNull);
      expect(s.explanation, contains('peso corporal'));
    });

    test('imported 0.1 sessions (weight only, no sets) never progress', () {
      final legacy = [
        Exposure(
          dateKey: '2026-09-22',
          log: ExerciseLog(exerciseId: 'squat', weightKg: 100, completed: true),
        ),
        Exposure(
          dateKey: '2026-09-25',
          log: ExerciseLog(exerciseId: 'squat', weightKg: 100, completed: true),
        ),
      ];
      final s = run(legacy);
      expect(s.kind, ProgressionKind.hold);
      expect(s.toKg, isNull);
      expect(s.missing, isNotEmpty);
    });

    test('the same input always gives the same suggestion', () {
      final input = [day('2026-09-22', full()), day('2026-09-25', full())];
      final a = run(input), b = run(input);
      expect(
        [a.kind, a.fromKg, a.toKg, a.explanation, a.sessions],
        [b.kind, b.fromKg, b.toKg, b.explanation, b.sessions],
      );
    });
  });

  group('progress statistics (F09 fixtures)', () {
    WorkoutSession session(
      String date,
      SessionStatus status, {
      List<ExerciseLog> exercises = const [],
    }) => WorkoutSession(
      dateKey: date,
      routineId: 'legs',
      status: status,
      exercises: exercises,
    );
    final today = DateTime(2026, 10, 1);
    bool planned(DateTime d) => const [
      DateTime.tuesday,
      DateTime.thursday,
      DateTime.saturday,
    ].contains(d.weekday);

    Compliance compliance(
      List<WorkoutSession> sessions, {
      List<Reschedule> moves = const [],
      DateTime? start,
    }) => ProgressStats.compliance(
      sessions: sessions,
      reschedules: moves,
      start: start ?? DateTime(2026, 9, 1),
      end: today,
      today: today,
      planned: planned,
    );

    test('completed over planned-and-due, with the other outcomes apart', () {
      final c = compliance([
        session('2026-09-22', SessionStatus.completed),
        session('2026-09-24', SessionStatus.partial),
        session('2026-09-26', SessionStatus.missed),
        session('2026-09-29', SessionStatus.completed),
      ]);
      expect([c.done, c.partial, c.missed], [2, 1, 1]);
      // Planned days between the first record and today with nothing saved:
      // 09-24..: Thursdays/Saturdays/Tuesdays without a session.
      expect(c.due, c.done + c.partial + c.missed + c.unrecorded);
      expect(c.fraction, '${c.done}/${c.due}');
      expect(c.ratio, closeTo(c.done / c.due, 1e-12));
    });

    test('future dates and today (still open) are not due', () {
      final c = compliance([
        session('2026-10-01', SessionStatus.scheduled),
        session('2026-10-03', SessionStatus.scheduled),
        session('2026-10-06', SessionStatus.completed),
      ]);
      expect(c.due, 0);
      expect(c.ratio, isNull, reason: 'no data is not 0 %');
      expect(c.done, 0);
    });

    test('an unfinished past session is unrecorded, not completed', () {
      final c = compliance([session('2026-09-29', SessionStatus.scheduled)]);
      expect(c.unrecorded, greaterThanOrEqualTo(1));
      expect(c.done, 0);
    });

    test('only planned days after the first record count as unrecorded', () {
      final c = compliance([session('2026-09-26', SessionStatus.completed)]);
      // After Sat 09-26 and before Thu 10-01: Tue 09-29 is planned and empty.
      expect(c.done, 1);
      expect(c.unrecorded, 1);
      expect(c.due, 2);
    });

    test('a moved session counts once, at its new date', () {
      final move = Reschedule(
        id: 'm',
        sourceDate: '2026-09-29',
        targetDate: '2026-09-30',
        kind: RescheduleKind.missed,
        createdAt: DateTime.utc(2026, 9, 29),
      );
      final sessions = [
        session('2026-09-29', SessionStatus.missed),
        session('2026-09-30', SessionStatus.completed),
      ];
      final withMove = compliance(sessions, moves: [move]);
      expect(withMove.moved, 1);
      expect(withMove.missed, 0, reason: 'the origin is not counted twice');
      expect(withMove.done, 1);
      expect(withMove.due, 1);
      // Undone: both stand as they were.
      final undone = compliance(
        sessions,
        moves: [move.copyWith(undoneAt: DateTime.utc(2026, 9, 29, 1))],
      );
      expect(undone.moved, 0);
      expect(undone.missed, 1);
    });

    test(
      'range bounds follow the calendar, month end and year end included',
      () {
        final sessions = [session('2026-02-03', SessionStatus.completed)];
        final week = ProgressStats.bounds(
          StatsRange.week,
          DateTime(2026, 10, 1),
          sessions,
        );
        expect(week.$1, DateTime(2026, 9, 28));
        final month = ProgressStats.bounds(
          StatsRange.month,
          DateTime(2026, 10, 1),
          sessions,
        );
        expect(month.$1, DateTime(2026, 10, 1));
        final all = ProgressStats.bounds(
          StatsRange.all,
          DateTime(2026, 10, 1),
          sessions,
        );
        expect(all.$1, DateTime(2026, 2, 3));
        final newYear = ProgressStats.bounds(
          StatsRange.week,
          DateTime(2027, 1, 1),
          sessions,
        );
        expect(newYear.$1, DateTime(2026, 12, 28));
        expect(
          ProgressStats.bounds(
            StatsRange.all,
            DateTime(2026, 10, 1),
            const [],
          ).$1,
          DateTime(2026, 10, 1),
        );
      },
    );

    LoadType loadType(String id) => exerciseFor(id).loadType;

    test('external volume sums kg × reps of recorded work sets only', () {
      final stats = ProgressStats.volume(
        sessions: [
          session(
            '2026-09-29',
            SessionStatus.completed,
            exercises: [
              log('squat', [
                work(1, kg: 20, reps: 10, kind: SetKind.warmup),
                work(1, kg: 60, reps: 8),
                work(2, kg: 60, reps: 6),
                work(3, kg: 60), // reps unknown
                work(4, status: SetStatus.skipped),
              ]),
              // Bodyweight: excluded even with data.
              log('pushup', [work(1, kg: 0, reps: 15)]),
              // Checklist tap only.
              log('rdl', const []),
            ],
          ),
          // Legacy-shaped session: weight only.
          session(
            '2026-09-26',
            SessionStatus.completed,
            exercises: [
              ExerciseLog(exerciseId: 'squat', weightKg: 100, completed: true),
            ],
          ),
        ],
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 10, 1),
        loadType: loadType,
      );
      expect(stats.kgReps, 60 * 8 + 60 * 6);
      expect(stats.setsCounted, 2);
      expect(
        stats.setsTotal,
        3,
        reason: 'the set with unknown reps counts as missing data',
      );
      expect(stats.coverage, closeTo(2 / 3, 1e-12));
    });

    test('no records gives "no data", never zero', () {
      final stats = ProgressStats.volume(
        sessions: [
          session(
            '2026-09-29',
            SessionStatus.completed,
            exercises: [
              ExerciseLog(exerciseId: 'squat', weightKg: 100, completed: true),
            ],
          ),
        ],
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 10, 1),
        loadType: loadType,
      );
      expect(stats.hasData, isFalse);
      expect(stats.coverage, isNull);
      expect(
        ProgressStats.trends(
          sessions: const [],
          start: DateTime(2026, 9, 1),
          end: DateTime(2026, 10, 1),
          loadType: loadType,
        ),
        isEmpty,
      );
    });

    test('volume respects the range', () {
      final sessions = [
        session(
          '2026-08-15',
          SessionStatus.completed,
          exercises: [
            log('squat', [work(1, kg: 100, reps: 5)]),
          ],
        ),
        session(
          '2026-09-29',
          SessionStatus.completed,
          exercises: [
            log('squat', [work(1, kg: 50, reps: 5)]),
          ],
        ),
      ];
      final month = ProgressStats.volume(
        sessions: sessions,
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 10, 1),
        loadType: loadType,
      );
      expect(month.kgReps, 250);
      final all = ProgressStats.volume(
        sessions: sessions,
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 10, 1),
        loadType: loadType,
      );
      expect(all.kgReps, 750);
    });

    test('trends and observed personal bests come from recorded sets', () {
      final trends = ProgressStats.trends(
        sessions: [
          session(
            '2026-09-29',
            SessionStatus.completed,
            exercises: [
              log('squat', [
                work(1, kg: 60, reps: 5),
                work(2, kg: 62.5, reps: 3),
              ]),
            ],
          ),
          session(
            '2026-09-22',
            SessionStatus.completed,
            exercises: [
              log('squat', [work(1, kg: 57.5, reps: 8)]),
              log('rdl', [work(1, kg: 70, reps: null)]),
            ],
          ),
        ],
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 10, 1),
        loadType: loadType,
      );
      expect(trends.map((t) => t.exerciseId), [
        'squat',
      ], reason: 'rdl has no complete set, so no line');
      final squat = trends.single;
      expect(squat.points.map((p) => p.dateKey), ['2026-09-22', '2026-09-29']);
      expect(squat.points.map((p) => p.topWeightKg), [57.5, 62.5]);
      expect(squat.points.map((p) => p.totalReps), [8, 8]);
      expect(squat.points.last.kgReps, 60 * 5 + 62.5 * 3);
      expect(squat.best!.weightKg, 62.5);
      expect(squat.best!.reps, 3);
      expect(squat.best!.dateKey, '2026-09-29');
    });
  });

  group('monthly review (F07)', () {
    final base = const UserProfile(onboarded: true, lastReview: '2026-09-01');
    DateTime day(int d) => DateTime(2026, 9, d);

    test('due after 30 days from the last review, not before', () {
      expect(ReviewService.status(base, day(30)).due, isFalse);
      expect(ReviewService.status(base, day(30)).daysSince, 29);
      final due = ReviewService.status(base, DateTime(2026, 10, 1));
      expect(due.due, isTrue);
      expect(due.daysSince, 30);
    });

    test('the month boundary and the year change count real days', () {
      final p = const UserProfile(onboarded: true, lastReview: '2026-12-15');
      expect(ReviewService.status(p, DateTime(2027, 1, 13)).due, isFalse);
      expect(ReviewService.status(p, DateTime(2027, 1, 14)).due, isTrue);
      final leap = const UserProfile(onboarded: true, lastReview: '2028-02-01');
      // February has 29 days in 2028: 30 days after Feb 1 is Mar 2.
      expect(ReviewService.status(leap, DateTime(2028, 3, 1)).due, isFalse);
      expect(ReviewService.status(leap, DateTime(2028, 3, 2)).due, isTrue);
    });

    test('postponing hides it for seven days, then it is due again', () {
      final snoozed = base.copyWith(reviewSnoozeUntil: () => '2026-10-08');
      expect(ReviewService.status(snoozed, DateTime(2026, 10, 7)).due, isFalse);
      expect(
        ReviewService.status(snoozed, DateTime(2026, 10, 7)).snoozedUntil,
        '2026-10-08',
      );
      expect(ReviewService.status(snoozed, DateTime(2026, 10, 8)).due, isTrue);
      expect(
        dateKey(ReviewService.snoozeUntil(DateTime(2026, 10, 1))),
        '2026-10-08',
      );
    });

    test('a profile that was never finished is not asked to review', () {
      expect(
        ReviewService.status(const UserProfile(), DateTime(2030)).due,
        isFalse,
      );
      // Finished but never reviewed: due.
      expect(
        ReviewService.status(
          const UserProfile(onboarded: true),
          DateTime(2026, 10, 1),
        ).due,
        isTrue,
      );
    });

    ReviewProposal propose({
      ReviewAnswers? answers,
      required ReviewMonth month,
      UserProfile? current,
    }) => ReviewService.propose(
      current: current ?? base,
      answers: answers ?? ReviewAnswers.from(current ?? base),
      month: month,
    );

    test('too little data proposes no change in volume or load', () {
      final p = propose(month: const ReviewMonth(done: 1, due: 2));
      expect(p.insufficientData, isTrue);
      expect(p.profile.sessionMinutes, base.sessionMinutes);
      expect(p.notes.first, contains('pocos entrenamientos'));
      final none = propose(month: const ReviewMonth(done: 0, due: 0));
      expect(none.insufficientData, isTrue);
    });

    test('low adherence shortens sessions down to a floor', () {
      final p = propose(month: const ReviewMonth(done: 2, due: 6));
      expect(p.profile.sessionMinutes, 45);
      expect(p.notes.join(' '), contains('33 %'));
      final short = base.copyWith(sessionMinutes: 30);
      final q = propose(
        current: short,
        month: const ReviewMonth(done: 1, due: 6),
      );
      expect(q.profile.sessionMinutes, 30);
      expect(q.notes.join(' '), contains('ya son cortas'));
    });

    test('good adherence never raises load by itself', () {
      final p = propose(month: const ReviewMonth(done: 8, due: 9));
      expect(p.allowsIncrease, isTrue);
      expect(p.profile.sessionMinutes, base.sessionMinutes);
      expect(p.notes.join(' '), contains('no sube cargas'));
    });

    test(
      'pain, injury, fatigue, low energy or "too hard" allow no increase',
      () {
        const strong = ReviewMonth(done: 9, due: 9);
        final cases = {
          'pain': propose(
            answers: ReviewAnswers.from(base).withPain(),
            month: strong,
          ),
          'injury': propose(
            month: const ReviewMonth(done: 9, due: 9, injuryDays: 1),
          ),
          'fatigue': propose(
            month: const ReviewMonth(done: 9, due: 9, fatigueDays: 2),
          ),
          'low energy': propose(
            answers: ReviewAnswers.from(base).withEnergy(Energy.low),
            month: strong,
          ),
          'hard': propose(
            answers: ReviewAnswers.from(base)
                .withDifficulty(ReviewDifficulty.hard),
            month: strong,
          ),
        };
        cases.forEach((name, proposal) {
          expect(proposal.allowsIncrease, isFalse, reason: name);
          expect(
            proposal.notes.join(' '),
            contains('no se propone ningún aumento'),
            reason: name,
          );
        });
      },
    );

    test('"too easy" is noted but never changes the plan on its own', () {
      final p = propose(
        answers: ReviewAnswers.from(base).withDifficulty(ReviewDifficulty.easy),
        month: const ReviewMonth(done: 8, due: 9),
      );
      expect(p.notes.join(' '), contains('fácil'));
      expect(p.profile.sessionMinutes, base.sessionMinutes);
    });

    test('goal, equipment and day changes flow into the proposed profile', () {
      final answers = ReviewAnswers(
        energy: Energy.normal,
        pain: false,
        difficulty: ReviewDifficulty.right,
        goal: TrainingGoal.muscle,
        equipment: const {Equipment.dumbbell},
        trainingDays: const [
          DateTime.friday,
          DateTime.monday,
          DateTime.wednesday,
        ],
        sessionMinutes: 60,
      );
      final p = propose(
        answers: answers,
        month: const ReviewMonth(done: 8, due: 9),
      );
      expect(p.profile.goal, TrainingGoal.muscle);
      expect(p.profile.equipment, {Equipment.dumbbell});
      expect(p.profile.trainingDays, [1, 3, 5]);
      expect(p.notes.last, contains('objetivo'));
      expect(p.notes.last, contains('equipo'));
      expect(p.notes.last, contains('días'));
      // The current profile object is untouched.
      expect(base.goal, isNot(TrainingGoal.muscle));
    });

    test('the comparison names each weekday of the two plans', () {
      final lines = ReviewService.comparePlans(
        legacyTemplatePlan,
        legacyTemplatePlan,
      );
      expect(lines, hasLength(3));
      expect(
        lines.first,
        startsWith('Martes: Pierna & fuerza (3 ejercicios) → '),
      );
      expect(lines.every((l) => l.endsWith('(igual)')), isTrue);
    });
  });
}

extension on ReviewAnswers {
  ReviewAnswers _copy({
    Energy? energy,
    bool? pain,
    ReviewDifficulty? difficulty,
  }) => ReviewAnswers(
    energy: energy ?? this.energy,
    pain: pain ?? this.pain,
    difficulty: difficulty ?? this.difficulty,
    goal: goal,
    equipment: equipment,
    trainingDays: trainingDays,
    sessionMinutes: sessionMinutes,
  );
  ReviewAnswers withPain() => _copy(pain: true);
  ReviewAnswers withEnergy(Energy e) => _copy(energy: e);
  ReviewAnswers withDifficulty(ReviewDifficulty d) => _copy(difficulty: d);
}
