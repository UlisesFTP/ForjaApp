import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../domain/models/models.dart';
import '../database/forja_database.dart';
import '../database/tables.dart';
import 'forja_store.dart';
import 'snapshot_diff.dart';

/// SQLite persistence. State is loaded once into an [AppSnapshot]; every
/// [commit] writes only what changed, inside one transaction.
class DriftForjaStore implements ForjaStore {
  DriftForjaStore(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;
  final ForjaDatabase _db;
  final DateTime Function() _clock;

  /// Opens the database and runs migrations, so a newer schema or an IO
  /// failure surfaces before anything is read or written.
  Future<void> open() async {
    await _db.customSelect('SELECT 1').get();
  }

  @override
  Future<AppSnapshot> load() => _readSnapshot();

  @override
  Future<void> commit(AppSnapshot previous, AppSnapshot next) {
    final changes = diffSnapshots(previous, next);
    if (changes.isEmpty) return Future.value();
    return _db.transaction(() => _apply(changes, imported: false));
  }

  // Every table that holds what the person stored. The legacy-import marker
  // is not one of them: deleting data must not make 0.1 data import again.
  static const _userTables = [
    'workout_sessions',
    'calendar_overrides',
    'check_ins',
    'food_entries',
    'profiles',
    'profile_history',
    'plan_versions',
    'reminders',
    'session_events',
    'reschedules',
    'session_adjustments',
    'progression_decisions',
    'monthly_reviews',
    'cardio_sessions',
    'food_favorites',
    'recipes',
    'nutrition_goals',
  ];

  @override
  Future<void> replaceAll(AppSnapshot next) => _db.transaction(() async {
    // Children go with their parents (foreign keys cascade).
    for (final table in _userTables) {
      await _db.customStatement('DELETE FROM $table');
    }
    await _apply(SnapshotChanges.insertAll(next), imported: false);
    // What was written must read back as exactly what was given.
    if (!sameSnapshotContent(next, await _readSnapshot())) {
      throw StateError('Stored data differs from the restored snapshot.');
    }
  });

  @override
  Future<void> close() => _db.close();

  Future<LegacyImportRow?> legacyImport(String source) => (_db.select(
    _db.legacyImports,
  )..where((t) => t.source.equals(source))).getSingleOrNull();

  /// Imports [snapshot] once. Data, verification and marker share one
  /// transaction: either all of it is stored or none is.
  Future<void> importLegacy(
    String source,
    AppSnapshot snapshot, {
    List<String> notes = const [],
  }) => _db.transaction(() async {
    if (await legacyImport(source) != null) return;
    await _apply(SnapshotChanges.insertAll(snapshot), imported: true);
    if (!sameSnapshotContent(snapshot, await _readSnapshot())) {
      throw StateError('Stored data differs from the imported snapshot.');
    }
    await _db
        .into(_db.legacyImports)
        .insert(
          LegacyImportsCompanion.insert(
            source: source,
            status: LegacyImportStatus.imported,
            importedAt: _clock().toUtc(),
            sessionCount: snapshot.sessions.length,
            overrideCount: snapshot.overrides.length,
            checkInCount: snapshot.checkIns.length,
            foodCount: snapshot.food.length,
            notes: notes.join(','),
          ),
        );
  });

  /// Records that [source] needs no import (nothing there, or the user chose
  /// to start empty). An existing marker is never replaced.
  Future<void> markLegacy(String source, LegacyImportStatus status) => _db
      .into(_db.legacyImports)
      .insert(
        LegacyImportsCompanion.insert(
          source: source,
          status: status,
          importedAt: _clock().toUtc(),
          sessionCount: 0,
          overrideCount: 0,
          checkInCount: 0,
          foodCount: 0,
          notes: '',
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<AppSnapshot> _readSnapshot() async {
    final profile = await _db.select(_db.profiles).getSingleOrNull();
    final reminder = await _db.select(_db.reminders).getSingleOrNull();
    final sessions = await _db.select(_db.workoutSessions).get();
    final exercises = await (_db.select(
      _db.sessionExercises,
    )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
    final overrides = await _db.select(_db.calendarOverrides).get();
    final checkIns = await _db.select(_db.checkIns).get();
    final setRows = await (_db.select(
      _db.setLogs,
    )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
    final adjustments = await _db.select(_db.sessionAdjustments).get();
    final moveRows = await (_db.select(
      _db.reschedules,
    )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    final eventRows = await (_db.select(
      _db.sessionEvents,
    )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    final decisionRows = await (_db.select(
      _db.progressionDecisions,
    )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    final reviewRows = await (_db.select(
      _db.monthlyReviews,
    )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    final cardioRows = await (_db.select(
      _db.cardioSessions,
    )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    final favoriteRows = await (_db.select(
      _db.foodFavorites,
    )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    final recipeRows = await (_db.select(
      _db.recipes,
    )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    final ingredientRows = await (_db.select(
      _db.recipeIngredients,
    )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
    final goalsRow = await _db
        .select(_db.nutritionGoalsTable)
        .getSingleOrNull();
    final ingredients = <String, List<Ingredient>>{};
    for (final r in ingredientRows) {
      final list = ingredients.putIfAbsent(r.recipeId, () => []);
      if (r.position != list.length) {
        throw StateError('Stored ingredient order is inconsistent.');
      }
      list.add(
        Ingredient(
          name: r.name,
          quantity: r.quantity,
          unit: r.unit,
          calories: r.calories,
          proteinG: r.proteinG,
          carbsG: r.carbsG,
          fatG: r.fatG,
        ),
      );
    }
    final segmentRows = await (_db.select(
      _db.cardioSegments,
    )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
    final segmentsBySession = <String, List<CardioSegment>>{};
    for (final r in segmentRows) {
      final list = segmentsBySession.putIfAbsent(r.sessionId, () => []);
      if (r.position != list.length) {
        throw StateError('Stored cardio segment order is inconsistent.');
      }
      list.add(
        CardioSegment(
          id: r.id,
          startedAt: r.startedAt.toUtc(),
          endedAt: r.endedAt?.toUtc(),
          intensity: r.intensity,
          weightKg: r.weightKg,
        ),
      );
    }
    final food = await (_db.select(
      _db.foodEntries,
    )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    final planRows = await (_db.select(
      _db.planVersions,
    )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    final routineRows = await (_db.select(
      _db.planRoutines,
    )..orderBy([(t) => OrderingTerm.asc(t.weekday)])).get();
    final plannedRows = await (_db.select(
      _db.planRoutineExercises,
    )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
    final historyRows = await (_db.select(
      _db.profileHistory,
    )..orderBy([(t) => OrderingTerm.asc(t.seq)])).get();
    final planned = <String, List<PlanExercise>>{};
    for (final row in plannedRows) {
      final list = planned.putIfAbsent(row.routineId, () => []);
      if (row.position != list.length) {
        throw StateError('Stored routine order is inconsistent.');
      }
      list.add(
        PlanExercise(
          exerciseId: row.exerciseId,
          sets: row.sets,
          repsMin: row.repsMin,
          repsMax: row.repsMax,
          rir: row.rir,
          restSeconds: row.restSeconds,
          incrementKg: row.incrementKg,
          referenceWeightKg: row.referenceWeightKg,
        ),
      );
    }
    final routinesByPlan = <String, List<PlanDay>>{};
    for (final row in routineRows) {
      routinesByPlan
          .putIfAbsent(row.planId, () => [])
          .add(
            PlanDay(
              row.weekday,
              Routine(
                id: row.id,
                name: row.name,
                focus: row.focus,
                warmup: row.warmup,
                exercises: planned[row.id] ?? const [],
              ),
            ),
          );
    }
    // Sets are matched to their exercise by id, never by position.
    final setsByExercise = <String, List<SetLog>>{};
    for (final row in setRows) {
      final list = setsByExercise.putIfAbsent(
        '${row.sessionId}/${row.exerciseId}',
        () => [],
      );
      if (row.position != list.length) {
        throw StateError('Stored set order is inconsistent.');
      }
      list.add(
        SetLog(
          id: row.id,
          kind: row.kind,
          number: row.number,
          status: row.status,
          weightKg: row.weightKg,
          reps: row.reps,
          rir: row.rir,
          skipReason: row.skipReason,
        ),
      );
    }
    final logs = <String, List<ExerciseLog>>{};
    for (final row in exercises) {
      final list = logs.putIfAbsent(row.sessionId, () => []);
      if (row.position != list.length) {
        throw StateError('Stored exercise order is inconsistent.');
      }
      list.add(
        ExerciseLog(
          exerciseId: row.exerciseId,
          weightKg: row.weightKg,
          completed: row.completed,
          skipped: row.skipped,
          skipReason: row.skipReason,
          technique: row.technique,
          sets:
              setsByExercise['${row.sessionId}/${row.exerciseId}'] ?? const [],
        ),
      );
    }
    return AppSnapshot(
      profile: profile == null
          ? const UserProfile()
          : UserProfile(
              experience: profile.experience,
              goal: profile.goal,
              weightKg: profile.weightKg,
              age: profile.age,
              energy: profile.energy,
              note: profile.note,
              onboarded: profile.onboarded,
              lastReview: profile.lastReview,
              equipment: _parseEquipment(profile.equipment),
              trainingDays: _parseDays(profile.trainingDays),
              sessionMinutes: profile.sessionMinutes,
              skippedSetup: profile.setupSkipped,
              setupStep: profile.setupStep,
              unit: profile.weightUnit,
              reviewSnoozeUntil: profile.reviewSnoozeUntil,
            ),
      reminder: reminder == null
          ? const ReminderSettings()
          : ReminderSettings(
              enabled: reminder.enabled,
              hour: reminder.hour,
              minute: reminder.minute,
            ),
      sessions: {
        for (final s in sessions)
          s.dateKey: WorkoutSession(
            dateKey: s.dateKey,
            routineId: s.routineId,
            exercises: logs[s.id] ?? const [],
            status: s.status,
            feeling: s.feeling,
            note: s.note,
          ),
      },
      overrides: {for (final o in overrides) o.dateKey: o.routineId},
      checkIns: {
        for (final c in checkIns)
          if (c.phase == CheckInPhase.before)
            c.dateKey: CheckIn(feeling: c.feeling, note: c.note),
      },
      afterCheckIns: {
        for (final c in checkIns)
          if (c.phase == CheckInPhase.after)
            c.dateKey: CheckIn(feeling: c.feeling, note: c.note),
      },
      adjustments: {for (final a in adjustments) a.dateKey: a.applied},
      reschedules: [
        for (final r in moveRows)
          Reschedule(
            id: r.id,
            sourceDate: r.sourceDate,
            targetDate: r.targetDate,
            kind: r.kind,
            createdAt: r.createdAt.toUtc(),
            undoneAt: r.undoneAt?.toUtc(),
            parentId: r.parentId,
          ),
      ],
      favorites: [
        for (final f in favoriteRows)
          FavoriteFood(
            id: f.id,
            name: f.name,
            calories: f.calories,
            portion: f.portion,
            unit: f.unit,
            proteinG: f.proteinG,
            carbsG: f.carbsG,
            fatG: f.fatG,
          ),
      ],
      recipes: [
        for (final r in recipeRows)
          Recipe(
            id: r.id,
            name: r.name,
            servings: r.servings,
            ingredients: ingredients[r.id] ?? const [],
            createdAt: r.createdAt.toUtc(),
            notes: r.notes,
            tags: [for (final t in jsonDecode(r.tags) as List) t as String],
            allergens: r.allergens == null
                ? null
                : [
                    for (final a in jsonDecode(r.allergens!) as List)
                      a as String,
                  ],
          ),
      ],
      goals: goalsRow == null
          ? const NutritionGoals()
          : NutritionGoals(
              kcal: goalsRow.kcal,
              proteinG: goalsRow.proteinG,
              carbsG: goalsRow.carbsG,
              fatG: goalsRow.fatG,
            ),
      cardio: [
        for (final c in cardioRows)
          CardioSession(
            id: c.id,
            activity: c.activity,
            startedAt: c.startedAt.toUtc(),
            segments: segmentsBySession[c.id] ?? const [],
            targetMinutes: c.targetMinutes,
            status: c.status,
            finishedAt: c.finishedAt?.toUtc(),
            feedback: c.feedback,
            note: c.note,
            durationCorrected: c.durationCorrected,
          ),
      ],
      progressionDecisions: [
        for (final d in decisionRows)
          ProgressionDecision(
            id: d.id,
            exerciseId: d.exerciseId,
            ruleVersion: d.ruleVersion,
            kind: d.kind,
            basedOn: d.basedOn,
            status: d.status,
            decidedAt: d.decidedAt.toUtc(),
            fromKg: d.fromKg,
            toKg: d.toKg,
          ),
      ],
      reviews: [
        for (final r in reviewRows)
          MonthlyReview(
            id: r.id,
            reviewedOn: r.reviewedOn,
            outcome: r.outcome,
            rulesVersion: r.rulesVersion,
            sessionsDone: r.sessionsDone,
            sessionsDue: r.sessionsDue,
            answers: Map<String, Object?>.from(
              jsonDecode(r.answers) as Map<String, dynamic>,
            ),
            proposal: [
              for (final line in jsonDecode(r.proposal) as List) line as String,
            ],
            createdAt: r.createdAt.toUtc(),
          ),
      ],
      sessionEvents: [
        for (final e in eventRows)
          SessionEvent(
            id: e.id,
            dateKey: e.dateKey,
            kind: e.kind,
            at: e.at.toUtc(),
          ),
      ],
      food: [
        for (final f in food)
          FoodEntry(
            id: f.id,
            dateKey: f.dateKey,
            name: f.name,
            calories: f.calories,
            portion: f.portion,
            unit: f.unit,
            proteinG: f.proteinG,
            carbsG: f.carbsG,
            fatG: f.fatG,
            caloriesSource: f.caloriesSource,
            recipeId: f.recipeId,
          ),
      ],
      plans: [
        for (final p in planRows)
          PlanVersion(
            id: p.id,
            status: p.status,
            source: p.source,
            name: p.name,
            createdAt: p.createdAt.toUtc(),
            effectiveFrom: p.effectiveFrom,
            acceptedAt: p.acceptedAt?.toUtc(),
            days: routinesByPlan[p.id] ?? const [],
          ),
      ],
      profileHistory: [
        for (final h in historyRows)
          ProfileAnswer(
            id: h.id,
            recordedAt: h.recordedAt.toUtc(),
            reason: h.reason,
            profile: UserProfile.fromJson(
              jsonDecode(h.payload) as Map<String, dynamic>,
            ),
            rulesVersion: h.rulesVersion,
          ),
      ],
    );
  }

  static Set<Equipment> _parseEquipment(String text) => {
    for (final name in text.split(',').where((s) => s.isNotEmpty))
      Equipment.values.firstWhere(
        (e) => e.name == name,
        orElse: () => throw StateError('Stored equipment is invalid.'),
      ),
  };
  static List<int> _parseDays(String text) => [
    for (final part in text.split(',').where((s) => s.isNotEmpty))
      int.parse(part),
  ];
  static String _equipmentText(Set<Equipment> set) => [
    for (final e in Equipment.values)
      if (set.contains(e)) e.name,
  ].join(',');

  // Must run inside a transaction. Every statement is awaited and an error is
  // never swallowed: a half-applied change would commit.
  Future<void> _apply(SnapshotChanges c, {required bool imported}) async {
    final now = _clock().toUtc();
    // 0.1 data has no creation time; it stays unknown instead of invented.
    final created = imported ? null : now;
    if (c.removedSessions.isNotEmpty) {
      await (_db.delete(
        _db.workoutSessions,
      )..where((t) => t.dateKey.isIn(c.removedSessions))).go();
    }
    for (final e in c.sessions.entries) {
      await _writeSession(e.key, e.value, now, created, imported);
    }
    if (c.removedOverrides.isNotEmpty) {
      await (_db.delete(
        _db.calendarOverrides,
      )..where((t) => t.dateKey.isIn(c.removedOverrides))).go();
    }
    for (final e in c.overrides.entries) {
      await _db
          .into(_db.calendarOverrides)
          .insertOnConflictUpdate(
            CalendarOverridesCompanion.insert(
              dateKey: e.key,
              routineId: Value(e.value),
              updatedAt: now,
            ),
          );
    }
    if (c.removedCheckIns.isNotEmpty) {
      await (_db.delete(_db.checkIns)..where(
            (t) =>
                t.dateKey.isIn(c.removedCheckIns) &
                t.phase.equalsValue(CheckInPhase.before),
          ))
          .go();
    }
    for (final e in c.checkIns.entries) {
      await _writeCheckIn(e.key, e.value, CheckInPhase.before, now, created);
    }
    if (c.removedAfterCheckIns.isNotEmpty) {
      await (_db.delete(_db.checkIns)..where(
            (t) =>
                t.dateKey.isIn(c.removedAfterCheckIns) &
                t.phase.equalsValue(CheckInPhase.after),
          ))
          .go();
    }
    for (final e in c.afterCheckIns.entries) {
      await _writeCheckIn(e.key, e.value, CheckInPhase.after, now, created);
    }
    await _writeMovement(c, now);
    await _writeDecisions(c);
    await _writeCardio(c);
    await _writeNutrition(c, now);
    await _writeFood(c, created);
    final profile = c.profile;
    if (profile != null) {
      await _db
          .into(_db.profiles)
          .insertOnConflictUpdate(
            ProfilesCompanion.insert(
              id: const Value(1),
              experience: profile.experience,
              goal: profile.goal,
              weightKg: Value(profile.weightKg),
              age: Value(profile.age),
              energy: profile.energy,
              note: profile.note,
              onboarded: profile.onboarded,
              lastReview: Value(profile.lastReview),
              equipment: Value(_equipmentText(profile.equipment)),
              trainingDays: Value(profile.trainingDays.join(',')),
              sessionMinutes: Value(profile.sessionMinutes),
              setupSkipped: Value(profile.skippedSetup),
              setupStep: Value(profile.setupStep),
              weightUnit: Value(profile.unit),
              reviewSnoozeUntil: Value(profile.reviewSnoozeUntil),
              updatedAt: now,
            ),
          );
    }
    await _writeProfileHistory(c.profileAnswers);
    for (final plan in c.plans) {
      await _writePlan(plan);
    }
    final reminder = c.reminder;
    if (reminder != null) {
      await _db
          .into(_db.reminders)
          .insertOnConflictUpdate(
            RemindersCompanion.insert(
              id: const Value(1),
              enabled: reminder.enabled,
              hour: reminder.hour,
              minute: reminder.minute,
              updatedAt: now,
            ),
          );
    }
  }

  Future<int> _nextSeq(
    TableInfo<Table, dynamic> table,
    GeneratedColumn<int> seq,
  ) async {
    final top = seq.max();
    final row = await (_db.selectOnly(table)..addColumns([top])).getSingle();
    return (row.read(top) ?? 0) + 1;
  }

  Future<void> _writeProfileHistory(List<ProfileAnswer> answers) async {
    if (answers.isEmpty) return;
    var seq = await _nextSeq(_db.profileHistory, _db.profileHistory.seq);
    for (final a in answers) {
      await _db
          .into(_db.profileHistory)
          .insert(
            ProfileHistoryCompanion.insert(
              id: a.id,
              seq: seq++,
              recordedAt: a.recordedAt.toUtc(),
              reason: a.reason,
              payload: jsonEncode(a.profile.toJson()),
              rulesVersion: Value(a.rulesVersion),
            ),
          );
    }
  }

  // The plan row keeps its creation order; its routines are rewritten whole
  // (nothing points at them with a foreign key, sessions use the opaque id).
  Future<void> _writePlan(PlanVersion plan) async {
    final existing = await (_db.select(
      _db.planVersions,
    )..where((t) => t.id.equals(plan.id))).getSingleOrNull();
    if (existing == null) {
      await _db
          .into(_db.planVersions)
          .insert(
            PlanVersionsCompanion.insert(
              id: plan.id,
              seq: await _nextSeq(_db.planVersions, _db.planVersions.seq),
              status: plan.status,
              source: plan.source,
              name: plan.name,
              effectiveFrom: Value(plan.effectiveFrom),
              createdAt: plan.createdAt.toUtc(),
              acceptedAt: Value(plan.acceptedAt?.toUtc()),
            ),
          );
    } else {
      await (_db.update(
        _db.planVersions,
      )..where((t) => t.id.equals(plan.id))).write(
        PlanVersionsCompanion(
          status: Value(plan.status),
          source: Value(plan.source),
          name: Value(plan.name),
          effectiveFrom: Value(plan.effectiveFrom),
          acceptedAt: Value(plan.acceptedAt?.toUtc()),
        ),
      );
      await (_db.delete(
        _db.planRoutines,
      )..where((t) => t.planId.equals(plan.id))).go();
    }
    for (final day in plan.days) {
      final routine = day.routine;
      await _db
          .into(_db.planRoutines)
          .insert(
            PlanRoutinesCompanion.insert(
              id: routine.id,
              planId: plan.id,
              weekday: day.weekday,
              name: routine.name,
              focus: routine.focus,
              warmup: routine.warmup,
            ),
          );
      for (var i = 0; i < routine.exercises.length; i++) {
        final e = routine.exercises[i];
        await _db
            .into(_db.planRoutineExercises)
            .insert(
              PlanRoutineExercisesCompanion.insert(
                routineId: routine.id,
                position: i,
                exerciseId: e.exerciseId,
                sets: e.sets,
                repsMin: e.repsMin,
                repsMax: e.repsMax,
                rir: e.rir,
                restSeconds: e.restSeconds,
                incrementKg: e.incrementKg,
                referenceWeightKg: Value(e.referenceWeightKg),
              ),
            );
      }
    }
  }

  // Never REPLACE: it would delete the row, cascade to its exercises and
  // change its id. Existing sessions keep their id and creation time.
  Future<void> _writeSession(
    String key,
    WorkoutSession session,
    DateTime now,
    DateTime? created,
    bool imported,
  ) async {
    if (session.dateKey != key) {
      throw StateError('Session key does not match its date.');
    }
    final existing = await (_db.select(
      _db.workoutSessions,
    )..where((t) => t.dateKey.equals(key))).getSingleOrNull();
    final String id;
    if (existing == null) {
      id = _newId();
      await _db
          .into(_db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              id: id,
              dateKey: key,
              routineId: session.routineId,
              status: session.status,
              feeling: Value(session.feeling),
              note: session.note,
              origin: imported
                  ? SessionOrigin.legacySnapshotV1
                  : SessionOrigin.app,
              createdAt: Value(created),
              updatedAt: now,
            ),
          );
    } else {
      id = existing.id;
      await (_db.update(
        _db.workoutSessions,
      )..where((t) => t.id.equals(id))).write(
        WorkoutSessionsCompanion(
          routineId: Value(session.routineId),
          status: Value(session.status),
          feeling: Value(session.feeling),
          note: Value(session.note),
          updatedAt: Value(now),
        ),
      );
    }
    await _syncExercises(id, session.exercises);
  }

  // Rows are matched by exercise id and updated in place, so data that later
  // references them survives a reorder.
  Future<void> _syncExercises(String sessionId, List<ExerciseLog> logs) async {
    final rows = await (_db.select(
      _db.sessionExercises,
    )..where((t) => t.sessionId.equals(sessionId))).get();
    final stored = {for (final r in rows) r.exerciseId: r};
    final kept = {for (final l in logs) l.exerciseId};
    final gone = [
      for (final r in rows)
        if (!kept.contains(r.exerciseId)) r.exerciseId,
    ];
    if (gone.isNotEmpty) {
      await (_db.delete(_db.sessionExercises)..where(
            (t) => t.sessionId.equals(sessionId) & t.exerciseId.isIn(gone),
          ))
          .go();
      await (_db.delete(_db.setLogs)..where(
            (t) => t.sessionId.equals(sessionId) & t.exerciseId.isIn(gone),
          ))
          .go();
    }
    final storedSets = <String, List<SetLogRow>>{};
    final setRows =
        await (_db.select(_db.setLogs)
              ..where((t) => t.sessionId.equals(sessionId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    for (final row in setRows) {
      storedSets.putIfAbsent(row.exerciseId, () => []).add(row);
    }
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i], row = stored[log.exerciseId];
      if (log.completed && log.skipped) {
        throw StateError('An exercise cannot be completed and skipped.');
      }
      if (row == null) {
        await _db
            .into(_db.sessionExercises)
            .insert(
              SessionExercisesCompanion.insert(
                sessionId: sessionId,
                exerciseId: log.exerciseId,
                position: i,
                weightKg: log.weightKg,
                completed: log.completed,
                skipped: Value(log.skipped),
                skipReason: Value(log.skipReason),
                technique: Value(log.technique),
              ),
            );
      } else if (row.position != i ||
          row.weightKg != log.weightKg ||
          row.completed != log.completed ||
          row.skipped != log.skipped ||
          row.skipReason != log.skipReason ||
          row.technique != log.technique) {
        await (_db.update(_db.sessionExercises)..where(
              (t) =>
                  t.sessionId.equals(sessionId) &
                  t.exerciseId.equals(log.exerciseId),
            ))
            .write(
              SessionExercisesCompanion(
                position: Value(i),
                weightKg: Value(log.weightKg),
                completed: Value(log.completed),
                skipped: Value(log.skipped),
                skipReason: Value(log.skipReason),
                technique: Value(log.technique),
              ),
            );
      }
      await _syncSets(sessionId, log, storedSets[log.exerciseId] ?? const []);
    }
  }

  // Sets are matched by id. Survivors are moved out of the way first because
  // (session, exercise, position) is unique.
  Future<void> _syncSets(
    String sessionId,
    ExerciseLog log,
    List<SetLogRow> stored,
  ) async {
    final before = {for (final r in stored) r.id: r};
    final ids = {for (final s in log.sets) s.id};
    if (ids.length != log.sets.length) {
      throw StateError('Set ids must be unique.');
    }
    final unchanged =
        stored.length == log.sets.length &&
        Iterable<int>.generate(stored.length).every((i) {
          final r = stored[i], s = log.sets[i];
          return r.id == s.id && _sameSet(r, s);
        });
    if (unchanged) return;
    final gone = [
      for (final r in stored)
        if (!ids.contains(r.id)) r.id,
    ];
    if (gone.isNotEmpty) {
      await (_db.delete(_db.setLogs)..where((t) => t.id.isIn(gone))).go();
    }
    final offset = log.sets.length + stored.length + 1;
    await _db.customStatement(
      'UPDATE set_logs SET position = position + ? '
      'WHERE session_id = ? AND exercise_id = ?',
      [offset, sessionId, log.exerciseId],
    );
    for (var i = 0; i < log.sets.length; i++) {
      final set = log.sets[i];
      if (before.containsKey(set.id)) {
        await (_db.update(
          _db.setLogs,
        )..where((t) => t.id.equals(set.id))).write(
          SetLogsCompanion(
            position: Value(i),
            kind: Value(set.kind),
            number: Value(set.number),
            status: Value(set.status),
            weightKg: Value(set.weightKg),
            reps: Value(set.reps),
            rir: Value(set.rir),
            skipReason: Value(set.skipReason),
          ),
        );
      } else {
        await _db
            .into(_db.setLogs)
            .insert(
              SetLogsCompanion.insert(
                id: set.id,
                sessionId: sessionId,
                exerciseId: log.exerciseId,
                position: i,
                kind: set.kind,
                number: set.number,
                status: set.status,
                weightKg: Value(set.weightKg),
                reps: Value(set.reps),
                rir: Value(set.rir),
                skipReason: Value(set.skipReason),
              ),
            );
      }
    }
  }

  static bool _sameSet(SetLogRow r, SetLog s) =>
      r.kind == s.kind &&
      r.number == s.number &&
      r.status == s.status &&
      r.weightKg == s.weightKg &&
      r.reps == s.reps &&
      r.rir == s.rir &&
      r.skipReason == s.skipReason;

  // Saved foods, recipes (written whole, ingredients in order) and goals.
  Future<void> _writeNutrition(SnapshotChanges c, DateTime now) async {
    if (c.removedFavorites.isNotEmpty) {
      await (_db.delete(
        _db.foodFavorites,
      )..where((t) => t.id.isIn(c.removedFavorites))).go();
    }
    for (final f in c.favorites) {
      final exists = await (_db.select(
        _db.foodFavorites,
      )..where((t) => t.id.equals(f.id))).getSingleOrNull();
      if (exists == null) {
        await _db
            .into(_db.foodFavorites)
            .insert(
              FoodFavoritesCompanion.insert(
                id: f.id,
                seq: await _nextSeq(_db.foodFavorites, _db.foodFavorites.seq),
                name: f.name,
                calories: f.calories,
                portion: Value(f.portion),
                unit: Value(f.unit),
                proteinG: Value(f.proteinG),
                carbsG: Value(f.carbsG),
                fatG: Value(f.fatG),
              ),
            );
      } else {
        await (_db.update(
          _db.foodFavorites,
        )..where((t) => t.id.equals(f.id))).write(
          FoodFavoritesCompanion(
            name: Value(f.name),
            calories: Value(f.calories),
            portion: Value(f.portion),
            unit: Value(f.unit),
            proteinG: Value(f.proteinG),
            carbsG: Value(f.carbsG),
            fatG: Value(f.fatG),
          ),
        );
      }
    }
    if (c.removedRecipes.isNotEmpty) {
      await (_db.delete(
        _db.recipes,
      )..where((t) => t.id.isIn(c.removedRecipes))).go();
    }
    for (final r in c.recipes) {
      final exists = await (_db.select(
        _db.recipes,
      )..where((t) => t.id.equals(r.id))).getSingleOrNull();
      final tags = jsonEncode(r.tags);
      final allergens = r.allergens == null ? null : jsonEncode(r.allergens);
      if (exists == null) {
        await _db
            .into(_db.recipes)
            .insert(
              RecipesCompanion.insert(
                id: r.id,
                seq: await _nextSeq(_db.recipes, _db.recipes.seq),
                name: r.name,
                servings: r.servings,
                notes: r.notes,
                tags: tags,
                allergens: Value(allergens),
                createdAt: r.createdAt.toUtc(),
              ),
            );
      } else {
        await (_db.update(_db.recipes)..where((t) => t.id.equals(r.id))).write(
          RecipesCompanion(
            name: Value(r.name),
            servings: Value(r.servings),
            notes: Value(r.notes),
            tags: Value(tags),
            allergens: Value(allergens),
          ),
        );
        await (_db.delete(
          _db.recipeIngredients,
        )..where((t) => t.recipeId.equals(r.id))).go();
      }
      for (var i = 0; i < r.ingredients.length; i++) {
        final g = r.ingredients[i];
        await _db
            .into(_db.recipeIngredients)
            .insert(
              RecipeIngredientsCompanion.insert(
                recipeId: r.id,
                position: i,
                name: g.name,
                quantity: Value(g.quantity),
                unit: Value(g.unit),
                calories: Value(g.calories),
                proteinG: Value(g.proteinG),
                carbsG: Value(g.carbsG),
                fatG: Value(g.fatG),
              ),
            );
      }
    }
    final goals = c.goals;
    if (goals != null) {
      await _db
          .into(_db.nutritionGoalsTable)
          .insertOnConflictUpdate(
            NutritionGoalsTableCompanion.insert(
              id: const Value(1),
              kcal: Value(goals.kcal),
              proteinG: Value(goals.proteinG),
              carbsG: Value(goals.carbsG),
              fatG: Value(goals.fatG),
              updatedAt: now,
            ),
          );
    }
  }

  // A session is written whole; its segments are matched by id and position
  // (a segment only ever closes or is added, never reordered).
  Future<void> _writeCardio(SnapshotChanges c) async {
    if (c.removedCardio.isNotEmpty) {
      await (_db.delete(
        _db.cardioSessions,
      )..where((t) => t.id.isIn(c.removedCardio))).go();
    }
    for (final s in c.cardio) {
      final exists = await (_db.select(
        _db.cardioSessions,
      )..where((t) => t.id.equals(s.id))).getSingleOrNull();
      if (exists == null) {
        await _db
            .into(_db.cardioSessions)
            .insert(
              CardioSessionsCompanion.insert(
                id: s.id,
                seq: await _nextSeq(_db.cardioSessions, _db.cardioSessions.seq),
                activity: s.activity,
                targetMinutes: Value(s.targetMinutes),
                status: s.status,
                startedAt: s.startedAt.toUtc(),
                finishedAt: Value(s.finishedAt?.toUtc()),
                feedback: Value(s.feedback),
                note: s.note,
                durationCorrected: Value(s.durationCorrected),
              ),
            );
      } else {
        await (_db.update(
          _db.cardioSessions,
        )..where((t) => t.id.equals(s.id))).write(
          CardioSessionsCompanion(
            status: Value(s.status),
            finishedAt: Value(s.finishedAt?.toUtc()),
            feedback: Value(s.feedback),
            note: Value(s.note),
            durationCorrected: Value(s.durationCorrected),
          ),
        );
      }
      final stored = {
        for (final r in await (_db.select(
          _db.cardioSegments,
        )..where((t) => t.sessionId.equals(s.id))).get())
          r.id: r,
      };
      final keep = {for (final seg in s.segments) seg.id};
      final gone = [
        for (final id in stored.keys)
          if (!keep.contains(id)) id,
      ];
      if (gone.isNotEmpty) {
        await (_db.delete(
          _db.cardioSegments,
        )..where((t) => t.id.isIn(gone))).go();
      }
      for (var i = 0; i < s.segments.length; i++) {
        final seg = s.segments[i], row = stored[seg.id];
        if (row == null) {
          await _db
              .into(_db.cardioSegments)
              .insert(
                CardioSegmentsCompanion.insert(
                  id: seg.id,
                  sessionId: s.id,
                  position: i,
                  startedAt: seg.startedAt.toUtc(),
                  endedAt: Value(seg.endedAt?.toUtc()),
                  intensity: seg.intensity,
                  weightKg: Value(seg.weightKg),
                ),
              );
        } else if (row.position != i ||
            row.startedAt.toUtc() != seg.startedAt.toUtc() ||
            row.endedAt?.toUtc() != seg.endedAt?.toUtc() ||
            row.intensity != seg.intensity ||
            row.weightKg != seg.weightKg) {
          await (_db.update(
            _db.cardioSegments,
          )..where((t) => t.id.equals(seg.id))).write(
            CardioSegmentsCompanion(
              position: Value(i),
              startedAt: Value(seg.startedAt.toUtc()),
              endedAt: Value(seg.endedAt?.toUtc()),
              intensity: Value(seg.intensity),
              weightKg: Value(seg.weightKg),
            ),
          );
        }
      }
    }
  }

  // Append-only logs: progression decisions and monthly reviews.
  Future<void> _writeDecisions(SnapshotChanges c) async {
    if (c.progressionDecisions.isNotEmpty) {
      var seq = await _nextSeq(
        _db.progressionDecisions,
        _db.progressionDecisions.seq,
      );
      for (final d in c.progressionDecisions) {
        await _db
            .into(_db.progressionDecisions)
            .insert(
              ProgressionDecisionsCompanion.insert(
                id: d.id,
                seq: seq++,
                exerciseId: d.exerciseId,
                ruleVersion: d.ruleVersion,
                kind: d.kind,
                basedOn: d.basedOn,
                status: d.status,
                decidedAt: d.decidedAt.toUtc(),
                fromKg: Value(d.fromKg),
                toKg: Value(d.toKg),
              ),
            );
      }
    }
    if (c.reviews.isNotEmpty) {
      var seq = await _nextSeq(_db.monthlyReviews, _db.monthlyReviews.seq);
      for (final r in c.reviews) {
        await _db
            .into(_db.monthlyReviews)
            .insert(
              MonthlyReviewsCompanion.insert(
                id: r.id,
                seq: seq++,
                reviewedOn: r.reviewedOn,
                outcome: r.outcome,
                rulesVersion: r.rulesVersion,
                sessionsDone: r.sessionsDone,
                sessionsDue: r.sessionsDue,
                answers: jsonEncode(r.answers),
                proposal: jsonEncode(r.proposal),
                createdAt: r.createdAt.toUtc(),
              ),
            );
      }
    }
  }

  // Per-date adjustment decisions, reschedules (an undo updates the entry)
  // and the append-only audit trail of reopened sessions.
  Future<void> _writeMovement(SnapshotChanges c, DateTime now) async {
    if (c.removedAdjustments.isNotEmpty) {
      await (_db.delete(
        _db.sessionAdjustments,
      )..where((t) => t.dateKey.isIn(c.removedAdjustments))).go();
    }
    for (final e in c.adjustments.entries) {
      await _db
          .into(_db.sessionAdjustments)
          .insertOnConflictUpdate(
            SessionAdjustmentsCompanion.insert(
              dateKey: e.key,
              applied: e.value,
              updatedAt: now,
            ),
          );
    }
    if (c.reschedules.isNotEmpty) {
      var seq = await _nextSeq(_db.reschedules, _db.reschedules.seq);
      for (final r in c.reschedules) {
        final existing = await (_db.select(
          _db.reschedules,
        )..where((t) => t.id.equals(r.id))).getSingleOrNull();
        if (existing == null) {
          await _db
              .into(_db.reschedules)
              .insert(
                ReschedulesCompanion.insert(
                  id: r.id,
                  seq: seq++,
                  sourceDate: r.sourceDate,
                  targetDate: r.targetDate,
                  kind: r.kind,
                  createdAt: r.createdAt.toUtc(),
                  undoneAt: Value(r.undoneAt?.toUtc()),
                  parentId: Value(r.parentId),
                ),
              );
        } else {
          await (_db.update(
            _db.reschedules,
          )..where((t) => t.id.equals(r.id))).write(
            ReschedulesCompanion(undoneAt: Value(r.undoneAt?.toUtc())),
          );
        }
      }
    }
    if (c.sessionEvents.isNotEmpty) {
      var seq = await _nextSeq(_db.sessionEvents, _db.sessionEvents.seq);
      for (final e in c.sessionEvents) {
        await _db
            .into(_db.sessionEvents)
            .insert(
              SessionEventsCompanion.insert(
                id: e.id,
                seq: seq++,
                dateKey: e.dateKey,
                kind: e.kind,
                at: e.at.toUtc(),
              ),
            );
      }
    }
  }

  Future<void> _writeCheckIn(
    String key,
    CheckIn checkIn,
    CheckInPhase phase,
    DateTime now,
    DateTime? created,
  ) async {
    final existing =
        await (_db.select(
              _db.checkIns,
            )..where((t) => t.dateKey.equals(key) & t.phase.equalsValue(phase)))
            .getSingleOrNull();
    if (existing == null) {
      await _db
          .into(_db.checkIns)
          .insert(
            CheckInsCompanion.insert(
              id: _newId(),
              dateKey: key,
              phase: Value(phase),
              feeling: checkIn.feeling,
              note: checkIn.note,
              createdAt: Value(created),
              updatedAt: now,
            ),
          );
    } else {
      await (_db.update(
        _db.checkIns,
      )..where((t) => t.id.equals(existing.id))).write(
        CheckInsCompanion(
          feeling: Value(checkIn.feeling),
          note: Value(checkIn.note),
          updatedAt: Value(now),
        ),
      );
    }
  }

  Future<void> _writeFood(SnapshotChanges c, DateTime? created) async {
    if (c.removedFood.isNotEmpty) {
      await (_db.delete(
        _db.foodEntries,
      )..where((t) => t.id.isIn(c.removedFood))).go();
    }
    for (final f in c.updatedFood) {
      await (_db.update(
        _db.foodEntries,
      )..where((t) => t.id.equals(f.id))).write(
        FoodEntriesCompanion(
          dateKey: Value(f.dateKey),
          name: Value(f.name),
          calories: Value(f.calories),
          portion: Value(f.portion),
          unit: Value(f.unit),
          proteinG: Value(f.proteinG),
          carbsG: Value(f.carbsG),
          fatG: Value(f.fatG),
          caloriesSource: Value(f.caloriesSource),
          recipeId: Value(f.recipeId),
        ),
      );
    }
    if (c.addedFood.isEmpty) return;
    final top = _db.foodEntries.seq.max();
    final row = await (_db.selectOnly(
      _db.foodEntries,
    )..addColumns([top])).getSingle();
    var seq = row.read(top) ?? 0;
    for (final f in c.addedFood) {
      await _db
          .into(_db.foodEntries)
          .insert(
            FoodEntriesCompanion.insert(
              id: f.id,
              seq: ++seq,
              dateKey: f.dateKey,
              name: f.name,
              calories: f.calories,
              createdAt: Value(created),
              portion: Value(f.portion),
              unit: Value(f.unit),
              proteinG: Value(f.proteinG),
              carbsG: Value(f.carbsG),
              fatG: Value(f.fatG),
              caloriesSource: Value(f.caloriesSource),
              recipeId: Value(f.recipeId),
            ),
          );
    }
  }

  String _newId() => randomId();
}
