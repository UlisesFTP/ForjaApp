import 'package:flutter/foundation.dart';

import '../../core/date_utils.dart';
import '../../core/ids.dart';
import '../../domain/models/models.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/services/plan_validator.dart';
import '../../domain/services/reschedule_planner.dart';
import '../seed/catalog.dart';
import '../services/forja_store.dart';

class LocalForjaRepository extends ChangeNotifier
    implements
        WorkoutRepository,
        ExerciseRepository,
        PlanRepository,
        ProgressionRepository,
        CardioRepository,
        ProfileRepository,
        NutritionRepository,
        SettingsRepository {
  LocalForjaRepository(
    this._store, {
    IdGenerator? newId,
    DateTime Function()? clock,
  }) : _newId = newId ?? randomId,
       _clock = clock ?? DateTime.now;
  final ForjaStore _store;
  final IdGenerator _newId;
  final DateTime Function() _clock;
  AppSnapshot _snapshot = AppSnapshot();
  Future<void> _writes = Future.value();
  bool _disposed = false;
  static final _knownExercises = {for (final e in exerciseCatalog) e.id};

  Future<void> initialize() async {
    _snapshot = await _store.load();
    notifyListeners();
  }

  // A write can finish after the screens are gone; it must not notify then.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// The whole committed state, for a consistent export: the snapshot is
  /// immutable, so what is read is exactly one committed moment.
  AppSnapshot get snapshot => _snapshot;

  /// Replaces all data in one transaction (after the caller has checked it and
  /// saved a backup). Writes queued before it finish first; if storage
  /// fails, the visible state is unchanged.
  Future<void> replaceAll(AppSnapshot next) {
    final operation = _writes.then((_) async {
      await _store.replaceAll(next);
      _snapshot = next;
      notifyListeners();
    });
    _writes = operation.catchError((Object _) {});
    return operation;
  }

  /// Waits for writes in flight, then closes the store.
  Future<void> close() async {
    await _writes;
    await _store.close();
  }

  @override
  List<Exercise> get exercises => exerciseCatalog;
  @override
  Exercise exerciseById(String id) => exerciseFor(id);

  // The accepted version that applies on [date]: the latest one whose
  // validity has started, or the built-in example before any is accepted.
  PlanVersion _planFor(AppSnapshot state, DateTime date) {
    final key = dateKey(date);
    PlanVersion? best;
    for (final plan in state.plans) {
      final from = plan.effectiveFrom;
      if (plan.status != PlanStatus.accepted || from == null) continue;
      if (from.compareTo(key) > 0) continue;
      // Later versions win ties: they were accepted afterwards.
      if (best == null || from.compareTo(best.effectiveFrom!) >= 0) best = plan;
    }
    return best ?? examplePlan;
  }

  Routine _routineById(AppSnapshot state, String id) {
    for (final plan in [...state.plans, examplePlan]) {
      for (final routine in plan.routines) {
        if (routine.id == id) return routine;
      }
    }
    return Routine(
      id: id,
      name: 'Rutina archivada',
      focus: '',
      warmup: '',
      exercises: const [],
    );
  }

  // Explicit overrides come first, then a session already saved for the date
  // (frozen, so a newer plan never rewrites it), then the plan for that day.
  Routine? _routineOn(AppSnapshot state, DateTime date) {
    final key = dateKey(date);
    if (state.overrides.containsKey(key)) {
      final id = state.overrides[key];
      return id == null ? null : _routineById(state, id);
    }
    final saved = state.sessions[key];
    if (saved != null) return _routineById(state, saved.routineId);
    return _planFor(state, date).routineOnWeekday(date.weekday);
  }

  @override
  PlanVersion planFor(DateTime date) => _planFor(_snapshot, date);
  @override
  Routine routineById(String id) => _routineById(_snapshot, id);
  @override
  Routine? routineOn(DateTime date) => _routineOn(_snapshot, date);
  WorkoutSession? _sessionOn(AppSnapshot state, DateTime date) {
    final key = dateKey(date);
    final saved = state.sessions[key];
    if (saved != null) return saved;
    final routine = _routineOn(state, date);
    if (routine == null) return null;
    return WorkoutSession(
      dateKey: key,
      routineId: routine.id,
      exercises: [
        for (final planned in routine.exercises)
          ExerciseLog(
            exerciseId: planned.exerciseId,
            weightKg:
                _workingWeight(state, planned.exerciseId) ??
                planned.referenceWeightKg ??
                0,
          ),
      ],
    );
  }

  // The latest accepted increase for the exercise. It only shapes sessions
  // that do not exist yet; saved sessions and plan versions are untouched.
  double? _workingWeight(AppSnapshot state, String exerciseId) {
    for (final d in state.progressionDecisions.reversed) {
      if (d.exerciseId == exerciseId &&
          d.status == DecisionStatus.accepted &&
          d.toKg != null) {
        return d.toKg;
      }
    }
    return null;
  }

  @override
  double? workingWeight(String exerciseId) =>
      _workingWeight(_snapshot, exerciseId);
  @override
  List<Reschedule> get reschedules => _snapshot.reschedules;

  @override
  WorkoutSession? sessionOn(DateTime date) => _sessionOn(_snapshot, date);
  @override
  List<WorkoutSession> get history =>
      List.unmodifiable(_snapshot.sessions.values);
  @override
  CheckIn? checkInOn(DateTime date) => _snapshot.checkIns[dateKey(date)];
  @override
  CheckIn? afterCheckInOn(DateTime date) =>
      _snapshot.afterCheckIns[dateKey(date)];
  @override
  bool? adjustmentOn(DateTime date) => _snapshot.adjustments[dateKey(date)];
  @override
  List<SessionEvent> eventsOn(DateTime date) => [
    for (final e in _snapshot.sessionEvents)
      if (e.dateKey == dateKey(date)) e,
  ];
  @override
  Reschedule? rescheduleInto(DateTime date) => _snapshot.reschedules
      .where((r) => r.active && r.targetDate == dateKey(date))
      .firstOrNull;
  @override
  Reschedule? rescheduleFrom(DateTime date) => _snapshot.reschedules
      .where((r) => r.active && r.sourceDate == dateKey(date))
      .firstOrNull;
  @override
  UserProfile get profile => _snapshot.profile;
  @override
  List<ProfileAnswer> get profileHistory => _snapshot.profileHistory;
  @override
  ReminderSettings get reminder => _snapshot.reminder;

  // Serialize writes, derive each change from the latest committed snapshot,
  // and publish only after storage succeeds. A failed write does not poison
  // the queue or replace the visible state with unpersisted data.
  Future<void> _mutate(AppSnapshot Function(AppSnapshot) change) {
    final operation = _writes.then((_) async {
      final previous = _snapshot, next = change(previous);
      await _store.commit(previous, next);
      _snapshot = next;
      notifyListeners();
    });
    _writes = operation.catchError((Object _) {});
    return operation;
  }

  // [reopens] marks edits that change what was done: on a finished session
  // they put it back in progress and leave an audit entry.
  Future<void> _changeSession(
    DateTime date,
    WorkoutSession Function(WorkoutSession) change, {
    bool reopens = false,
  }) => _mutate((state) {
    if (_routineOn(state, date) == null) {
      throw StateError('Este día es de descanso.');
    }
    final key = dateKey(date);
    final session = _sessionOn(state, date)!;
    var next = change(session);
    var events = state.sessionEvents;
    if (reopens && _isFinished(session)) {
      next = next.copyWith(status: SessionStatus.scheduled);
      events = [...events, _reopenedEvent(key)];
    }
    return state.copyWith(
      sessions: {...state.sessions, key: next},
      sessionEvents: events,
    );
  });

  static bool _isFinished(WorkoutSession s) =>
      s.status == SessionStatus.completed || s.status == SessionStatus.partial;

  SessionEvent _reopenedEvent(String key) => SessionEvent(
    id: _newId(),
    dateKey: key,
    kind: SessionEventKind.reopened,
    at: _clock().toUtc(),
  );

  static ExerciseLog _logOf(WorkoutSession session, String id) =>
      session.exercises.firstWhere(
        (e) => e.exerciseId == id,
        orElse: () => throw ArgumentError('Ejercicio no disponible.'),
      );

  static WorkoutSession _replaceLog(
    WorkoutSession session,
    String id,
    ExerciseLog Function(ExerciseLog) change,
  ) {
    _logOf(session, id);
    return session.copyWith(
      exercises: [
        for (final e in session.exercises) e.exerciseId == id ? change(e) : e,
      ],
    );
  }

  @override
  Future<void> toggleExercise(DateTime date, String id) =>
      _changeSession(date, reopens: true, (session) {
        _logOf(session, id);
        // Completing a skipped exercise takes the skip back; the sets stay.
        return _replaceLog(
          session,
          id,
          (e) => e.skipped || !e.completed
              ? e.copyWith(
                  completed: true,
                  skipped: false,
                  skipReason: () => null,
                )
              : e.copyWith(completed: false),
        );
      });

  @override
  Future<void> setSkipped(
    DateTime date,
    String id,
    bool skipped, {
    String? reason,
  }) {
    final text = reason?.trim() ?? '';
    if (skipped && (text.isEmpty || text.length > 120)) {
      return Future.error(
        ArgumentError('Indica el motivo (hasta 120 caracteres).'),
      );
    }
    return _changeSession(
      date,
      reopens: true,
      (session) => _replaceLog(session, id, (e) {
        _logOf(session, id);
        return skipped
            ? e.copyWith(
                skipped: true,
                completed: false,
                skipReason: () => text,
              )
            : e.copyWith(skipped: false, skipReason: () => null);
      }),
    );
  }

  static String? _checkEntry(SetEntry entry) {
    final weight = entry.weightKg, reps = entry.reps, rir = entry.rir;
    if (weight != null && (!weight.isFinite || weight < 0 || weight > 2000)) {
      return 'Introduce un peso entre 0 y 2000 kg.';
    }
    if (reps != null && (reps < 0 || reps > 999)) {
      return 'Las repeticiones van de 0 a 999.';
    }
    if (rir != null && (rir < 0 || rir > 10)) {
      return 'Las repeticiones en reserva van de 0 a 10.';
    }
    final reason = entry.skipReason?.trim() ?? '';
    if (reason.length > 120) return 'El motivo admite hasta 120 caracteres.';
    if (entry.status == SetStatus.skipped &&
        (weight != null || reps != null || rir != null)) {
      return 'Una serie omitida no lleva datos de rendimiento.';
    }
    if (entry.status == SetStatus.done && reason.isNotEmpty) {
      return 'Solo una serie omitida lleva motivo.';
    }
    return null;
  }

  // Numbers count within each kind, in list order, so deleting or changing a
  // kind never leaves gaps.
  static List<SetLog> _renumber(List<SetLog> sets) {
    final seen = <SetKind, int>{};
    return [
      for (final s in sets)
        s.copyWith(number: seen[s.kind] = (seen[s.kind] ?? 0) + 1),
    ];
  }

  SetLog _setFrom(String id, SetEntry e) => SetLog(
    id: id,
    kind: e.kind,
    number: 1,
    status: e.status,
    weightKg: e.weightKg,
    reps: e.reps,
    rir: e.rir,
    skipReason: (e.skipReason?.trim().isEmpty ?? true)
        ? null
        : e.skipReason!.trim(),
  );

  @override
  Future<void> addSet(DateTime date, String id, SetEntry entry) {
    final problem = _checkEntry(entry);
    if (problem != null) return Future.error(ArgumentError(problem));
    final setId = _newId();
    return _changeSession(
      date,
      reopens: true,
      (session) => _replaceLog(session, id, (e) {
        if (e.skipped) {
          throw StateError('Quita la omisión antes de registrar series.');
        }
        if (e.sets.length >= 30) {
          throw StateError('Máximo 30 series por ejercicio.');
        }
        // Warm-ups come before work sets, whatever order they were typed in.
        final sets = [...e.sets, _setFrom(setId, entry)];
        sets.sort((a, b) => a.kind.index.compareTo(b.kind.index));
        return e.copyWith(sets: _renumber(sets));
      }),
    );
  }

  @override
  Future<void> updateSet(
    DateTime date,
    String id,
    String setId,
    SetEntry entry,
  ) {
    final problem = _checkEntry(entry);
    if (problem != null) return Future.error(ArgumentError(problem));
    return _changeSession(
      date,
      reopens: true,
      (session) => _replaceLog(session, id, (e) {
        if (!e.sets.any((s) => s.id == setId)) {
          throw ArgumentError('Serie no disponible.');
        }
        final sets = [
          for (final s in e.sets) s.id == setId ? _setFrom(setId, entry) : s,
        ]..sort((a, b) => a.kind.index.compareTo(b.kind.index));
        return e.copyWith(sets: _renumber(sets));
      }),
    );
  }

  @override
  Future<void> removeSet(DateTime date, String id, String setId) =>
      _changeSession(
        date,
        reopens: true,
        (session) => _replaceLog(session, id, (e) {
          if (!e.sets.any((s) => s.id == setId)) {
            throw ArgumentError('Serie no disponible.');
          }
          return e.copyWith(
            sets: _renumber([
              for (final s in e.sets)
                if (s.id != setId) s,
            ]),
          );
        }),
      );

  @override
  Future<void> setTechnique(
    DateTime date,
    String id,
    TechniqueRating? rating,
  ) => _changeSession(
    date,
    (session) =>
        _replaceLog(session, id, (e) => e.copyWith(technique: () => rating)),
  );

  @override
  Future<void> reopenSession(DateTime date) => _mutate((state) {
    if (_routineOn(state, date) == null) {
      throw StateError('Este día es de descanso.');
    }
    final key = dateKey(date);
    final session = state.sessions[key];
    if (session == null || !_isFinished(session)) {
      throw StateError('La sesión no está terminada.');
    }
    return state.copyWith(
      sessions: {
        ...state.sessions,
        key: session.copyWith(status: SessionStatus.scheduled),
      },
      sessionEvents: [...state.sessionEvents, _reopenedEvent(key)],
    );
  });

  @override
  Future<void> updateWeight(DateTime date, String id, double weight) {
    if (!weight.isFinite || weight < 0 || weight > 2000) {
      return Future.error(
        ArgumentError('Introduce un peso entre 0 y 2000 kg.'),
      );
    }
    return _changeSession(date, (session) {
      _logOf(session, id);
      return _replaceLog(session, id, (e) => e.copyWith(weightKg: weight));
    });
  }

  @override
  Future<void> reorder(DateTime date, List<String> ids) => _changeSession(
    date,
    (session) {
      final lookup = {for (final e in session.exercises) e.exerciseId: e};
      if (ids.length != lookup.length ||
          ids.toSet().length != lookup.length ||
          !ids.every(lookup.containsKey)) {
        throw ArgumentError('Orden de ejercicios inválido.');
      }
      // Logs travel with their exercise: the same objects, new order.
      return session.copyWith(exercises: ids.map((id) => lookup[id]!).toList());
    },
  );
  @override
  Future<void> saveCheckIn(
    DateTime date,
    CheckIn checkIn, {
    CheckInPhase phase = CheckInPhase.before,
  }) => _mutate(
    (state) => phase == CheckInPhase.before
        ? state.copyWith(checkIns: {...state.checkIns, dateKey(date): checkIn})
        : state.copyWith(
            afterCheckIns: {...state.afterCheckIns, dateKey(date): checkIn},
          ),
  );
  @override
  Future<void> setAdjustment(DateTime date, bool applied) => _mutate(
    (state) => state.copyWith(
      adjustments: {...state.adjustments, dateKey(date): applied},
    ),
  );

  bool _trainsOn(AppSnapshot state, DateTime d) => _routineOn(state, d) != null;
  bool _occupied(AppSnapshot state, DateTime d) =>
      _trainsOn(state, d) || state.sessions.containsKey(dateKey(d));

  // Exercises that would move: everything for an absence, otherwise those
  // neither done nor deliberately skipped.
  static List<ExerciseLog> _pending(
    WorkoutSession session,
    SessionStatus status,
  ) => [
    for (final e in session.exercises)
      if (status == SessionStatus.missed || !e.resolved) e,
  ];

  ReschedulePreview _preview(
    AppSnapshot state,
    DateTime date,
    SessionStatus status,
  ) {
    if (_routineOn(state, date) == null) {
      throw StateError('No hay sesión programada.');
    }
    if (status != SessionStatus.partial && status != SessionStatus.missed) {
      throw ArgumentError('Solo una sesión parcial o ausente se reprograma.');
    }
    final session = _sessionOn(state, date)!;
    return ReschedulePreview(
      source: dateOnly(date),
      status: status,
      pending: [for (final e in _pending(session, status)) e.exerciseId],
      options: ReschedulePlanner.options(
        source: date,
        status: status,
        trains: (d) => _trainsOn(state, d),
        occupied: (d) => _occupied(state, d),
      ),
    );
  }

  @override
  ReschedulePreview previewReschedule(DateTime date, SessionStatus status) =>
      _preview(_snapshot, date, status);

  @override
  String? rescheduleProblem(DateTime source, DateTime target) =>
      ReschedulePlanner.manualProblem(
        source: source,
        date: target,
        occupied: (d) => _occupied(_snapshot, d),
      );

  @override
  List<String> rescheduleWarnings(
    DateTime source,
    SessionStatus status,
    DateTime target,
  ) => ReschedulePlanner.warningsFor(
    target,
    (d) => dateKey(d) == dateKey(source)
        ? status != SessionStatus.missed
        : _trainsOn(_snapshot, d),
  );

  static bool _untouched(WorkoutSession? s) =>
      s != null &&
      s.status == SessionStatus.scheduled &&
      !s.exercises.any((e) => e.resolved || e.sets.isNotEmpty);

  @override
  bool canUndo(Reschedule move) =>
      move.active &&
      _untouched(_snapshot.sessions[move.targetDate]) &&
      !_snapshot.reschedules.any((r) => r.active && r.parentId == move.id);

  @override
  Future<DateTime?> finishSession(
    DateTime date,
    SessionStatus status, {
    DateTime? moveTo,
    bool reschedule = true,
  }) async {
    DateTime? movedTo;
    await _mutate((state) {
      if (_routineOn(state, date) == null) {
        throw StateError('No hay sesión programada.');
      }
      final session = _sessionOn(state, date)!;
      if (status == SessionStatus.scheduled) {
        throw ArgumentError('Elige un resultado de sesión.');
      }
      final key = dateKey(date);
      if (status == SessionStatus.completed) {
        if (!session.allResolved) {
          throw StateError(
            'Resuelve todos los ejercicios (hecho u omitido) antes de completar la sesión.',
          );
        }
        // Skipped exercises make the result partial: nothing is moved.
        return state.copyWith(
          sessions: {
            ...state.sessions,
            key: session.copyWith(
              status: session.skippedCount > 0
                  ? SessionStatus.partial
                  : SessionStatus.completed,
            ),
          },
        );
      }
      if (status == SessionStatus.partial && session.allResolved) {
        throw StateError(
          session.skippedCount > 0
              ? 'No quedan pendientes. Completa la sesión.'
              : 'Todos los ejercicios están hechos. Completa la sesión.',
        );
      }
      final finished = {
        ...state.sessions,
        key: session.copyWith(status: status),
      };
      if (!reschedule) {
        return state.copyWith(sessions: finished);
      }
      final preview = _preview(state, date, status);
      final target = moveTo == null
          ? preview.suggested?.date
          : dateOnly(moveTo);
      if (target == null) {
        throw StateError(
          'No hay descanso disponible en las próximas dos semanas.',
        );
      }
      if (moveTo != null) {
        final problem = ReschedulePlanner.manualProblem(
          source: date,
          date: target,
          occupied: (d) => _occupied(state, d),
        );
        if (problem != null) throw StateError(problem);
      }
      movedTo = target;
      final targetKey = dateKey(target);
      // The move itself starts clean: nothing done, nothing skipped.
      final sessions = {
        ...finished,
        targetKey: WorkoutSession(
          dateKey: targetKey,
          routineId: session.routineId,
          exercises: [
            for (final e in _pending(session, status))
              ExerciseLog(exerciseId: e.exerciseId, weightKg: e.weightKg),
          ],
        ),
      };
      // A later move of something that was itself moved keeps the lineage.
      String? parent;
      for (final r in state.reschedules) {
        if (r.active && r.targetDate == key) parent = r.id;
      }
      return state.copyWith(
        sessions: sessions,
        overrides: {
          ...state.overrides,
          targetKey: session.routineId,
          key: null,
        },
        reschedules: [
          ...state.reschedules,
          Reschedule(
            id: _newId(),
            sourceDate: key,
            targetDate: targetKey,
            kind: status == SessionStatus.missed
                ? RescheduleKind.missed
                : RescheduleKind.partial,
            createdAt: _clock().toUtc(),
            parentId: parent,
          ),
        ],
      );
    });
    return movedTo;
  }

  @override
  Future<void> undoReschedule(String id) => _mutate((state) {
    final move = state.reschedules.where((r) => r.id == id).firstOrNull;
    if (move == null) throw ArgumentError('Movimiento no encontrado.');
    if (!move.active) return state;
    final target = state.sessions[move.targetDate];
    final laterMove = state.reschedules.any(
      (r) => r.active && r.parentId == move.id,
    );
    if (!_untouched(target) || laterMove) {
      throw StateError('El destino ya empezó; no se puede deshacer.');
    }
    final source = state.sessions[move.sourceDate];
    final sessions = {...state.sessions}..remove(move.targetDate);
    if (source != null) {
      sessions[move.sourceDate] = source.copyWith(
        status: SessionStatus.scheduled,
      );
    }
    final overrides = {...state.overrides}
      ..remove(move.targetDate)
      ..remove(move.sourceDate);
    return state.copyWith(
      sessions: sessions,
      overrides: overrides,
      reschedules: [
        for (final r in state.reschedules)
          r.id == id ? r.copyWith(undoneAt: _clock().toUtc()) : r,
      ],
      sessionEvents: [...state.sessionEvents, _reopenedEvent(move.sourceDate)],
    );
  });

  @override
  Future<void> saveProfile(UserProfile profile, {ProfileChange? record}) {
    final weight = profile.weightKg, age = profile.age;
    if ((weight != null && (!weight.isFinite || weight < 25 || weight > 300)) ||
        (age != null && (age < 14 || age > 100))) {
      return Future.error(ArgumentError('Revisa edad y peso corporal.'));
    }
    final days = profile.trainingDays;
    if (days.length != 3 ||
        days.toSet().length != 3 ||
        days.any((d) => d < DateTime.monday || d > DateTime.sunday)) {
      return Future.error(
        ArgumentError(
          'Elige exactamente tres días distintos de entrenamiento.',
        ),
      );
    }
    if (profile.sessionMinutes < 20 || profile.sessionMinutes > 180) {
      return Future.error(
        ArgumentError('La duración debe estar entre 20 y 180 minutos.'),
      );
    }
    final normalized = profile.copyWith(trainingDays: [...days]..sort());
    return _mutate(
      (state) => state.copyWith(
        profile: normalized,
        profileHistory: record == null
            ? null
            : [
                ...state.profileHistory,
                ProfileAnswer(
                  id: _newId(),
                  recordedAt: _clock().toUtc(),
                  reason: record,
                  profile: normalized,
                ),
              ],
      ),
    );
  }

  @override
  List<PlanVersion> get plans => _snapshot.plans;
  PlanVersion? _draftOf(AppSnapshot state) {
    for (final plan in state.plans.reversed) {
      if (plan.status == PlanStatus.draft) return plan;
    }
    return null;
  }

  @override
  PlanVersion? get draft => _draftOf(_snapshot);

  @override
  Future<void> saveDraft(PlanVersion draft) {
    if (draft.status != PlanStatus.draft) {
      return Future.error(ArgumentError('Solo se puede guardar un borrador.'));
    }
    final issues = PlanValidator.validate(
      draft,
      forAcceptance: false,
      isKnown: _knownExercises.contains,
    );
    if (issues.isNotEmpty) return Future.error(ArgumentError(issues.first));
    return _mutate((state) => _withDraft(state, draft));
  }

  AppSnapshot _withDraft(AppSnapshot state, PlanVersion draft) {
    final taken = {
      for (final plan in [...state.plans, examplePlan])
        if (plan.id != draft.id) ...plan.routines.map((r) => r.id),
    };
    if (draft.routines.any((r) => taken.contains(r.id))) {
      throw StateError('Las rutinas del borrador deben ser nuevas.');
    }
    final exists = state.plans.any((p) => p.id == draft.id);
    return state.copyWith(
      plans: [
        for (final p in state.plans)
          if (p.id == draft.id)
            draft
          else if (p.status == PlanStatus.draft)
            p.copyWith(status: PlanStatus.rejected)
          else
            p,
        if (!exists) draft,
      ],
    );
  }

  @override
  Future<void> discardDraft() => _mutate((state) {
    final pending = _draftOf(state);
    if (pending == null) return state;
    return state.copyWith(
      plans: [
        for (final p in state.plans)
          if (p.id == pending.id)
            p.copyWith(status: PlanStatus.rejected)
          else
            p,
      ],
    );
  });

  @override
  Future<void> acceptDraft(DateTime effectiveFrom) => _mutate((state) {
    final pending = _draftOf(state);
    if (pending == null) throw StateError('No hay un borrador que aceptar.');
    final issues = PlanValidator.validate(
      pending,
      forAcceptance: true,
      isKnown: _knownExercises.contains,
    );
    if (issues.isNotEmpty) throw ArgumentError(issues.first);
    final from = dateKey(effectiveFrom);
    if (from.compareTo(dateKey(_clock())) < 0) {
      throw ArgumentError('La vigencia debe ser hoy o una fecha futura.');
    }
    String? latest;
    for (final plan in state.plans) {
      final start = plan.effectiveFrom;
      if (plan.status == PlanStatus.accepted &&
          start != null &&
          (latest == null || start.compareTo(latest) > 0)) {
        latest = start;
      }
    }
    if (latest != null && from.compareTo(latest) < 0) {
      throw StateError(
        'La vigencia no puede ser anterior a la del plan actual ($latest).',
      );
    }
    final accepted = pending.copyWith(
      status: PlanStatus.accepted,
      effectiveFrom: () => from,
      acceptedAt: _clock().toUtc(),
    );
    return state.copyWith(
      plans: [
        for (final p in state.plans)
          if (p.id == pending.id) accepted else p,
      ],
    );
  });

  @override
  List<ProgressionDecision> get progressionDecisions =>
      _snapshot.progressionDecisions;

  @override
  Future<void> decideProgression({
    required String exerciseId,
    required ProgressionKind kind,
    required String basedOn,
    required String ruleVersion,
    required DecisionStatus status,
    double? fromKg,
    double? toKg,
  }) {
    if (!_knownExercises.contains(exerciseId)) {
      return Future.error(ArgumentError('Ejercicio no disponible.'));
    }
    if (status == DecisionStatus.accepted &&
        (kind != ProgressionKind.increase ||
            fromKg == null ||
            toKg == null ||
            !toKg.isFinite ||
            toKg <= fromKg ||
            toKg > 2000)) {
      return Future.error(
        ArgumentError('Solo se acepta un aumento de carga válido.'),
      );
    }
    return _mutate((state) {
      final taken = state.progressionDecisions.any(
        (d) =>
            d.exerciseId == exerciseId &&
            d.basedOn == basedOn &&
            d.ruleVersion == ruleVersion,
      );
      if (taken) return state;
      return state.copyWith(
        progressionDecisions: [
          ...state.progressionDecisions,
          ProgressionDecision(
            id: _newId(),
            exerciseId: exerciseId,
            ruleVersion: ruleVersion,
            kind: kind,
            basedOn: basedOn,
            status: status,
            decidedAt: _clock().toUtc(),
            fromKg: fromKg,
            toKg: toKg,
          ),
        ],
      );
    });
  }

  @override
  List<MonthlyReview> get reviews => _snapshot.reviews;

  @override
  Future<void> snoozeReview(DateTime until) => _mutate(
    (state) => state.copyWith(
      profile: state.profile.copyWith(reviewSnoozeUntil: () => dateKey(until)),
    ),
  );

  @override
  Future<void> completeReview(
    MonthlyReview review, {
    UserProfile? profile,
    PlanVersion? draft,
  }) {
    if (review.outcome == ReviewOutcome.rejected &&
        (profile != null || draft != null)) {
      return Future.error(
        ArgumentError('Un rechazo no cambia el perfil ni el plan.'),
      );
    }
    return _mutate((state) {
      if (state.reviews.any((r) => r.id == review.id)) return state;
      final accepted = review.outcome == ReviewOutcome.accepted;
      final base = accepted ? (profile ?? state.profile) : state.profile;
      final days = base.trainingDays;
      if (days.length != 3 || days.toSet().length != 3) {
        throw ArgumentError('Elige exactamente tres días distintos.');
      }
      final next = base.copyWith(
        trainingDays: [...days]..sort(),
        lastReview: () => review.reviewedOn,
        reviewSnoozeUntil: () => null,
      );
      var result = state.copyWith(
        profile: next,
        reviews: [...state.reviews, review],
        profileHistory: [
          ...state.profileHistory,
          ProfileAnswer(
            id: _newId(),
            recordedAt: _clock().toUtc(),
            reason: accepted
                ? ProfileChange.review
                : ProfileChange.reviewRejected,
            profile: next,
            rulesVersion: review.rulesVersion,
          ),
        ],
      );
      if (accepted && draft != null) result = _withDraft(result, draft);
      return result;
    });
  }

  @override
  CardioSession? get activeCardio =>
      _snapshot.cardio.where((c) => c.active).firstOrNull;
  @override
  List<CardioSession> get cardioHistory => [
    for (final c in _snapshot.cardio.reversed)
      if (!c.active) c,
  ];

  static CardioSession _activeIn(AppSnapshot state) =>
      state.cardio.where((c) => c.active).firstOrNull ??
      (throw StateError('No hay una sesión de cardio activa.'));

  AppSnapshot _replaceCardio(AppSnapshot state, CardioSession next) =>
      state.copyWith(
        cardio: [
          for (final c in state.cardio)
            if (c.id == next.id) next else c,
        ],
      );

  @override
  Future<void> startCardio({
    required CardioActivity activity,
    required CardioIntensity intensity,
    required DateTime at,
    int? targetMinutes,
  }) {
    if (targetMinutes != null && (targetMinutes < 1 || targetMinutes > 600)) {
      return Future.error(
        ArgumentError('La duración objetivo va de 1 a 600 minutos.'),
      );
    }
    return _mutate((state) {
      if (state.cardio.any((c) => c.active)) {
        throw StateError('Ya hay una sesión de cardio en curso.');
      }
      final start = at.toUtc();
      final session = CardioSession(
        id: _newId(),
        activity: activity,
        startedAt: start,
        targetMinutes: targetMinutes,
        segments: [
          CardioSegment(
            id: _newId(),
            startedAt: start,
            intensity: intensity,
            weightKg: state.profile.weightKg,
          ),
        ],
      );
      return state.copyWith(cardio: [...state.cardio, session]);
    });
  }

  @override
  Future<void> pauseCardio(DateTime at) => _mutate((state) {
    final session = _activeIn(state);
    final current = session.current;
    if (current == null) return state;
    if (at.toUtc().isBefore(current.startedAt)) {
      throw StateError(
        'El reloj del teléfono retrocedió. Finaliza la sesión y corrige la duración.',
      );
    }
    return _replaceCardio(
      state,
      session.copyWith(
        segments: [
          for (final s in session.segments)
            if (s.id == current.id) s.closedAt(at.toUtc()) else s,
        ],
      ),
    );
  });

  CardioSegment _openSegment(
    AppSnapshot state,
    DateTime at,
    CardioIntensity intensity,
  ) => CardioSegment(
    id: _newId(),
    startedAt: at.toUtc(),
    intensity: intensity,
    weightKg: state.profile.weightKg,
  );

  @override
  Future<void> resumeCardio(DateTime at, {CardioIntensity? intensity}) =>
      _mutate((state) {
        final session = _activeIn(state);
        if (session.running) return state;
        final last = session.segments.last;
        if (at.toUtc().isBefore(last.endedAt!)) {
          throw StateError(
            'El reloj del teléfono retrocedió. Finaliza la sesión y corrige la duración.',
          );
        }
        return _replaceCardio(
          state,
          session.copyWith(
            segments: [
              ...session.segments,
              _openSegment(state, at, intensity ?? last.intensity),
            ],
          ),
        );
      });

  @override
  Future<void> changeCardioIntensity(DateTime at, CardioIntensity intensity) =>
      _mutate((state) {
        final session = _activeIn(state);
        final current = session.current;
        if (current == null) {
          throw StateError('Continúa la sesión para cambiar la intensidad.');
        }
        if (current.intensity == intensity) return state;
        if (at.toUtc().isBefore(current.startedAt)) {
          throw StateError(
            'El reloj del teléfono retrocedió. Finaliza la sesión y corrige la duración.',
          );
        }
        return _replaceCardio(
          state,
          session.copyWith(
            segments: [
              for (final s in session.segments)
                if (s.id == current.id) s.closedAt(at.toUtc()) else s,
              _openSegment(state, at, intensity),
            ],
          ),
        );
      });

  @override
  Future<void> finishCardio(
    String id,
    DateTime at, {
    Duration? correctedDuration,
    Feeling? feedback,
    String note = '',
  }) {
    final text = note.trim();
    if (text.length > 500) {
      return Future.error(
        ArgumentError('La nota admite hasta 500 caracteres.'),
      );
    }
    if (correctedDuration != null &&
        (correctedDuration.isNegative ||
            correctedDuration > const Duration(hours: 24))) {
      return Future.error(
        ArgumentError('La duración corregida va de 0 a 24 horas.'),
      );
    }
    return _mutate((state) {
      final session = state.cardio.where((c) => c.id == id).firstOrNull;
      if (session == null) {
        throw ArgumentError('Sesión de cardio no encontrada.');
      }
      // Pressing "finish" twice must not save twice.
      if (!session.active) return state;
      var segments = [...session.segments];
      final last = segments.last;
      if (last.running) {
        var end = at.toUtc();
        if (end.isBefore(last.startedAt)) {
          if (correctedDuration == null) {
            throw StateError(
              'El reloj del teléfono retrocedió. Indica la duración real de la sesión.',
            );
          }
          end = last.startedAt;
        }
        segments[segments.length - 1] = last.closedAt(end);
      }
      if (correctedDuration != null) {
        final others = segments
            .sublist(0, segments.length - 1)
            .fold(Duration.zero, (sum, s) => sum + s.duration(at.toUtc()));
        final rest = correctedDuration - others;
        if (rest.isNegative) {
          throw ArgumentError(
            'La duración indicada es menor que el tiempo ya registrado antes de la última pausa.',
          );
        }
        final tail = segments.last;
        segments[segments.length - 1] = tail.closedAt(tail.startedAt.add(rest));
      }
      return _replaceCardio(
        state,
        session.copyWith(
          segments: segments,
          status: CardioStatus.finished,
          finishedAt: segments.last.endedAt,
          feedback: () => feedback,
          note: text,
          durationCorrected: correctedDuration != null,
        ),
      );
    });
  }

  @override
  Future<void> discardCardio(String id) => _mutate((state) {
    final session = state.cardio.where((c) => c.id == id).firstOrNull;
    if (session == null) return state;
    if (!session.active) {
      throw StateError('Solo se descarta una sesión en curso.');
    }
    return state.copyWith(
      cardio: [
        for (final c in state.cardio)
          if (c.id != id) c,
      ],
    );
  });

  @override
  List<FoodEntry> foodOn(DateTime date) => List.unmodifiable(
    _snapshot.food.where((e) => e.dateKey == dateKey(date)),
  );
  static String? _checkFood(FoodEntry e) {
    if (e.name.trim().isEmpty || e.name.trim().length > 80) {
      return 'Revisa el nombre (hasta 80 caracteres).';
    }
    if (e.calories < 0 || e.calories > 5000) {
      return 'Las calorías van de 0 a 5000.';
    }
    final portion = e.portion;
    if (portion != null &&
        (!portion.isFinite || portion <= 0 || portion > 100000)) {
      return 'La porción debe ser mayor que 0.';
    }
    if ((e.unit?.length ?? 0) > 12) return 'La unidad admite hasta 12 letras.';
    for (final g in [e.proteinG, e.carbsG, e.fatG]) {
      if (g != null && (!g.isFinite || g < 0 || g > 2000)) {
        return 'Los macros van de 0 a 2000 g.';
      }
    }
    // Calories worked out from macros must say so and must add up: a made-up
    // number is never filed as the person's own.
    if (e.caloriesSource == CaloriesSource.macros &&
        e.calories != caloriesFromMacros(e.proteinG, e.carbsG, e.fatG)) {
      return 'Las calorías no coinciden con los macros indicados.';
    }
    if (e.caloriesSource == CaloriesSource.recipe && e.recipeId == null) {
      return 'Falta la receta de origen.';
    }
    try {
      if (dateKey(parseDateKey(e.dateKey)) != e.dateKey) {
        throw const FormatException();
      }
    } on FormatException {
      return 'La fecha no es válida.';
    }
    return null;
  }

  @override
  Future<void> addFood(FoodEntry entry) {
    final problem = _checkFood(entry);
    if (problem != null) return Future.error(ArgumentError(problem));
    return _mutate((state) {
      if (state.food.any((f) => f.id == entry.id)) {
        throw StateError('Ese alimento ya está registrado.');
      }
      return state.copyWith(food: [...state.food, entry]);
    });
  }

  @override
  Future<void> updateFood(FoodEntry entry) {
    final problem = _checkFood(entry);
    if (problem != null) return Future.error(ArgumentError(problem));
    return _mutate((state) {
      if (!state.food.any((f) => f.id == entry.id)) {
        throw ArgumentError('Alimento no encontrado.');
      }
      return state.copyWith(
        food: [
          for (final f in state.food)
            if (f.id == entry.id) entry else f,
        ],
      );
    });
  }

  @override
  Future<void> removeFood(String id) => _mutate(
    (state) =>
        state.copyWith(food: state.food.where((e) => e.id != id).toList()),
  );

  @override
  Future<void> restoreFood(FoodEntry entry) {
    final problem = _checkFood(entry);
    if (problem != null) return Future.error(ArgumentError(problem));
    return _mutate(
      (state) => state.food.any((f) => f.id == entry.id)
          ? state
          : state.copyWith(food: [...state.food, entry]),
    );
  }

  @override
  List<FavoriteFood> get favorites => _snapshot.favorites;

  @override
  Future<void> addFavorite(FavoriteFood food) {
    final problem = _checkFood(
      FoodEntry(
        id: food.id,
        dateKey: dateKey(_clock()),
        name: food.name,
        calories: food.calories,
        portion: food.portion,
        unit: food.unit,
        proteinG: food.proteinG,
        carbsG: food.carbsG,
        fatG: food.fatG,
      ),
    );
    if (problem != null) return Future.error(ArgumentError(problem));
    return _mutate((state) {
      if (state.favorites.any((f) => f.id == food.id)) return state;
      // The same food twice is not a second favorite.
      if (state.favorites.length >= 200) {
        throw StateError('Máximo 200 favoritos.');
      }
      return state.copyWith(favorites: [...state.favorites, food]);
    });
  }

  @override
  Future<void> removeFavorite(String id) => _mutate(
    (state) => state.copyWith(
      favorites: state.favorites.where((f) => f.id != id).toList(),
    ),
  );

  @override
  List<Recipe> get recipes => _snapshot.recipes;

  static String? _checkRecipe(Recipe r) {
    if (r.name.trim().isEmpty || r.name.trim().length > 80) {
      return 'Revisa el nombre de la receta (hasta 80 caracteres).';
    }
    if (!r.servings.isFinite || r.servings <= 0 || r.servings > 1000) {
      return 'Las porciones deben ser mayores que 0.';
    }
    if (r.ingredients.isEmpty || r.ingredients.length > 50) {
      return 'Una receta lleva de 1 a 50 ingredientes.';
    }
    for (final i in r.ingredients) {
      if (i.name.trim().isEmpty || i.name.trim().length > 60) {
        return 'Revisa el nombre de cada ingrediente.';
      }
      final q = i.quantity;
      if (q != null && (!q.isFinite || q <= 0 || q > 1000000)) {
        return 'La cantidad de un ingrediente debe ser mayor que 0.';
      }
      final k = i.calories;
      if (k != null && (k < 0 || k > 100000)) {
        return 'Las calorías de un ingrediente van de 0 a 100000.';
      }
      for (final g in [i.proteinG, i.carbsG, i.fatG]) {
        if (g != null && (!g.isFinite || g < 0 || g > 100000)) {
          return 'Los macros de un ingrediente no son válidos.';
        }
      }
      if ((i.unit?.length ?? 0) > 12) {
        return 'La unidad admite hasta 12 letras.';
      }
    }
    if (r.notes.length > 1000) {
      return 'Las notas admiten hasta 1000 caracteres.';
    }
    for (final tag in [...r.tags, ...?r.allergens]) {
      if (tag.trim().isEmpty || tag.length > 24) {
        return 'Las etiquetas admiten hasta 24 caracteres.';
      }
    }
    if (r.tags.length > 10 || (r.allergens?.length ?? 0) > 20) {
      return 'Demasiadas etiquetas.';
    }
    return null;
  }

  @override
  Future<void> saveRecipe(Recipe recipe) {
    final problem = _checkRecipe(recipe);
    if (problem != null) return Future.error(ArgumentError(problem));
    return _mutate((state) {
      final exists = state.recipes.any((r) => r.id == recipe.id);
      if (!exists && state.recipes.length >= 200) {
        throw StateError('Máximo 200 recetas.');
      }
      return state.copyWith(
        recipes: [
          for (final r in state.recipes)
            if (r.id == recipe.id) recipe else r,
          if (!exists) recipe,
        ],
      );
    });
  }

  // Entries logged from a recipe keep their own numbers: deleting the recipe
  // never rewrites what was eaten.
  @override
  Future<void> deleteRecipe(String id) => _mutate(
    (state) => state.copyWith(
      recipes: state.recipes.where((r) => r.id != id).toList(),
    ),
  );

  @override
  NutritionGoals get goals => _snapshot.goals;

  @override
  Future<void> saveGoals(NutritionGoals goals) {
    final kcal = goals.kcal;
    if (kcal != null && (kcal < 500 || kcal > 10000)) {
      return Future.error(ArgumentError('El objetivo va de 500 a 10000 kcal.'));
    }
    for (final g in [goals.proteinG, goals.carbsG, goals.fatG]) {
      if (g != null && (!g.isFinite || g < 0 || g > 1000)) {
        return Future.error(
          ArgumentError('Los macros objetivo van de 0 a 1000 g.'),
        );
      }
    }
    return _mutate((state) => state.copyWith(goals: goals));
  }

  @override
  Future<void> saveReminder(ReminderSettings value) {
    if (value.hour < 0 ||
        value.hour > 23 ||
        value.minute < 0 ||
        value.minute > 59) {
      return Future.error(ArgumentError('Hora del recordatorio inválida.'));
    }
    return _mutate((state) => state.copyWith(reminder: value));
  }
}
