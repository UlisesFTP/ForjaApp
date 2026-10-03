import '../models/models.dart';

/// Version of the progression rules, stored with every decision. `prog-v2`
/// (D41a): the same rules, compared on the example plan with the adapted
/// prescription the screen shows. A decision taken under `prog-v1` still
/// stands for its suggestion (matched by exercise and date).
const progressionRulesVersion = 'prog-v2';

/// One session in which an exercise was done: the log plus how the person
/// said they felt before training that day.
class Exposure {
  const Exposure({required this.dateKey, required this.log, this.feeling});
  final String dateKey;
  final ExerciseLog log;
  final Feeling? feeling;
}

/// What the engine says about one exercise, with everything needed to explain
/// it: the sessions used, the rule, and what data was missing.
class ProgressionSuggestion {
  const ProgressionSuggestion({
    required this.exerciseId,
    required this.kind,
    required this.rule,
    required this.explanation,
    this.sessions = const [],
    this.missing = const [],
    this.fromKg,
    this.toKg,
  });
  final String exerciseId;
  final ProgressionKind kind;
  final String rule, explanation;
  // Dates of the sessions the suggestion is based on, oldest first.
  final List<String> sessions;
  final List<String> missing;
  final double? fromKg, toKg;

  /// The latest session used; with the exercise and rules version it
  /// identifies the suggestion, so a decision is made once per suggestion.
  String get basedOn => sessions.isEmpty ? '' : sessions.last;
  bool get actionable => kind == ProgressionKind.increase;
}

/// Weight progression, v1. A pure function of recorded work: it reads only
/// complete work sets with real reps and effort, never invents data, never
/// applies anything by itself and never prescribes a decrease.
class ProgressionEngine {
  static const _tolerance = 1e-6;
  static const _rule =
      'Dos sesiones seguidas con todas las series de trabajo en el extremo '
      'superior de repeticiones y con el esfuerzo previsto (RIR) o más '
      'holgado, con la misma carga y técnica sólida.';

  /// [exposures] are the sessions in which [planned] was done, any order.
  /// [feelingNow] is today's check-in, if any.
  static ProgressionSuggestion evaluate({
    required PlanExercise planned,
    required Exercise exercise,
    required List<Exposure> exposures,
    Feeling? feelingNow,
  }) {
    final id = planned.exerciseId;
    ProgressionSuggestion make(
      ProgressionKind kind,
      String explanation, {
      List<Exposure> used = const [],
      List<String> missing = const [],
      double? from,
      double? to,
    }) => ProgressionSuggestion(
      exerciseId: id,
      kind: kind,
      rule: _rule,
      explanation: explanation,
      sessions: [for (final e in used) e.dateKey],
      missing: missing,
      fromKg: from,
      toKg: to,
    );

    if (exercise.loadType != LoadType.external) {
      return make(
        ProgressionKind.hold,
        exercise.loadType == LoadType.time
            ? 'Este ejercicio se mide en tiempo: no hay carga que subir. Alarga el tiempo cuando te resulte fácil.'
            : 'Este ejercicio usa tu peso corporal: no hay carga externa que subir.',
      );
    }
    final done =
        exposures.where((e) => e.log.completed && !e.log.skipped).toList()
          ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
    if (done.length < 2) {
      return make(
        ProgressionKind.hold,
        'Aún no hay dos sesiones completadas de este ejercicio. Sigue con la carga actual.',
        used: done,
        missing: ['Sesiones completadas: ${done.length} de 2'],
      );
    }
    final used = done.sublist(done.length - 2);

    // Safety first: an injury, tiredness, soreness or shaky technique in any
    // of the sessions (or today) rules out suggesting more load.
    final reasons = <String>[
      for (final e in used)
        if (_unfit(e.feeling)) '${e.dateKey}: ${_feelingText(e.feeling!)}',
      if (_unfit(feelingNow)) 'Hoy: ${_feelingText(feelingNow!)}',
      for (final e in used)
        if (e.log.technique == TechniqueRating.unstable)
          '${e.dateKey}: técnica inestable',
    ];
    if (reasons.isNotEmpty) {
      return make(
        ProgressionKind.blocked,
        'No se sugiere subir la carga: ${reasons.join('; ')}. Cuando haya dos sesiones recientes sin esto, se volverá a evaluar.',
        used: used,
      );
    }

    final missing = <String>[];
    for (final e in used) {
      final sets = e.log.workSets;
      if (sets.length < planned.sets) {
        missing.add(
          '${e.dateKey}: ${sets.length} de ${planned.sets} series de trabajo registradas',
        );
        continue;
      }
      final noReps = sets.where((s) => s.reps == null).length;
      final noEffort = sets.where((s) => s.rir == null).length;
      final noLoad = sets.where((s) => s.weightKg == null).length;
      if (noReps > 0) {
        missing.add('${e.dateKey}: faltan repeticiones en $noReps series');
      }
      if (noEffort > 0) {
        missing.add(
          '${e.dateKey}: falta el esfuerzo (RIR) en $noEffort series',
        );
      }
      if (noLoad > 0) {
        missing.add('${e.dateKey}: falta la carga en $noLoad series');
      }
      if (e.log.technique == null) {
        missing.add('${e.dateKey}: falta valorar la técnica');
      }
    }
    if (missing.isNotEmpty) {
      return make(
        ProgressionKind.hold,
        'Faltan datos para evaluar el aumento. Mantén la carga y completa el registro de series, esfuerzo y técnica.',
        used: used,
        missing: missing,
      );
    }

    final weights = [
      for (final e in used)
        for (final s in e.log.workSets) s.weightKg!,
    ];
    final weight = weights.first;
    if (weights.any((w) => (w - weight).abs() > _tolerance)) {
      return make(
        ProgressionKind.hold,
        'Las cargas cambiaron entre series o sesiones, así que no son comparables. Mantén una carga fija unas sesiones.',
        used: used,
      );
    }

    final belowMin = [
      for (final e in used)
        e.log.workSets.any((s) => s.reps! < planned.repsMin),
    ];
    if (belowMin.every((b) => b)) {
      return make(
        ProgressionKind.review,
        'En las dos últimas sesiones no llegaste a ${planned.repsMin} repeticiones en alguna serie. Revisa la carga y la técnica; la app no calcula una bajada.',
        used: used,
        from: weight,
      );
    }

    final reached = used.every(
      (e) => e.log.workSets.every(
        (s) => s.reps! >= planned.repsMax && s.rir! >= planned.rir,
      ),
    );
    if (reached) {
      if (planned.incrementKg <= 0) {
        return make(
          ProgressionKind.hold,
          'Cumples la regla, pero este ejercicio no tiene un incremento configurado. Defínelo en el plan para recibir una sugerencia.',
          used: used,
          missing: const ['Incremento mínimo del ejercicio'],
          from: weight,
        );
      }
      final to = weight + planned.incrementKg;
      return make(
        ProgressionKind.increase,
        'Llegaste a ${planned.repsMax} repeticiones en todas las series con RIR ${planned.rir} o más, dos sesiones seguidas con ${_kg(weight)}. Sugerencia: subir ${_kg(planned.incrementKg)} (a ${_kg(to)}).',
        used: used,
        from: weight,
        to: to,
      );
    }
    return make(
      ProgressionKind.hold,
      'Mantén ${_kg(weight)} hasta llegar a ${planned.repsMax} repeticiones en todas las series con RIR ${planned.rir} o más, dos sesiones seguidas.',
      used: used,
      from: weight,
    );
  }

  static bool _unfit(Feeling? f) =>
      f == Feeling.injured || f == Feeling.tired || f == Feeling.doms;

  static String _feelingText(Feeling f) => switch (f) {
    Feeling.injured => 'lesión registrada',
    Feeling.tired => 'cansancio registrado',
    Feeling.doms => 'DOMS registrados',
    _ => '',
  };

  static String _kg(double v) =>
      '${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '')} kg';
}
