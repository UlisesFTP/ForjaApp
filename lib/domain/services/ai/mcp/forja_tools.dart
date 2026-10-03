import 'dart:convert';

import '../../../../core/date_utils.dart';
import '../../../expert/expert_coach.dart';
import '../../../models/labels.dart';
import '../../../models/models.dart';
import '../../../repositories/repositories.dart';
import '../../cardio_math.dart';
import '../../exercise_library.dart';
import '../../progress_stats.dart';
import '../../streak_rules.dart';
import '../ai_settings.dart';
import 'mcp_types.dart';
import 'proposal_inbox.dart';

/// What the tools may read during one conversation: the app's own
/// repository contracts, today's date, what the person allowed, and the
/// conversation's proposals. Tools never write data.
class ForjaToolContext {
  ForjaToolContext({
    required this.workouts,
    required this.profiles,
    required this.plans,
    required this.catalog,
    required this.categories,
    required this.today,
    required this.expert,
    required this.inbox,
    this.cardio,
    this.nutrition,
    this.coach,
  });
  final WorkoutRepository workouts;
  final ProfileRepository profiles;
  final PlanRepository plans;
  final ExerciseRepository catalog;
  final CardioRepository? cardio;
  final NutritionRepository? nutrition;
  final CoachRepository? coach;
  final Set<DataCategory> categories;
  final DateTime today;

  /// The minicoach's current evaluation (computed when first asked).
  final ExpertResult Function() expert;
  final ProposalInbox inbox;

  bool allows(DataCategory c) => categories.contains(c);
}

/// A wrong argument: reported to the model so it can correct itself.
class ToolArgumentError implements Exception {
  const ToolArgumentError(this.message);
  final String message;
}

/// Largest JSON a tool result may be.
const maxToolResultChars = 12000;

const _noArgs = {
  'type': 'object',
  'properties': <String, Object?>{},
  'additionalProperties': false,
};

/// The tools, in a fixed order (it helps the provider's prompt cache).
const forjaTools = <McpTool>[
  McpTool(
    name: 'get_profile',
    title: 'Perfil',
    description:
        'Objetivo, experiencia, energía habitual, días, duración y equipo de '
        'la persona. Peso y edad solo si los compartió; su nota de perfil '
        'solo si compartió notas.',
    inputSchema: _noArgs,
    annotations: ToolAnnotations.read,
    categories: {DataCategory.profile},
  ),
  McpTool(
    name: 'get_training_history',
    title: 'Historial de entrenamiento',
    description:
        'Sesiones de los últimos días (1–90, por defecto 28), más recientes '
        'primero: estado, ejercicios, series de trabajo (kg, repeticiones, '
        'RIR) y técnica. Con bienestar, cómo se sentía; con notas, sus notas.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'days': {'type': 'integer', 'minimum': 1, 'maximum': 90},
        'exerciseId': {'type': 'string', 'maxLength': 40},
      },
      'additionalProperties': false,
    },
    annotations: ToolAnnotations.read,
    categories: {DataCategory.training},
  ),
  McpTool(
    name: 'get_progress_summary',
    title: 'Resumen de progreso',
    description:
        'Cumplimiento del plan, volumen (kg × repeticiones) con su cobertura, '
        'mejores marcas observadas y racha, de los últimos días (7–90).',
    inputSchema: {
      'type': 'object',
      'properties': {
        'days': {'type': 'integer', 'minimum': 7, 'maximum': 90},
      },
      'additionalProperties': false,
    },
    annotations: ToolAnnotations.read,
    categories: {DataCategory.training},
  ),
  McpTool(
    name: 'get_plan',
    title: 'Plan',
    description:
        'El plan semanal en uso (días, rutinas, ejercicios con series, rango '
        'de repeticiones, RIR y descanso) y si hay un borrador pendiente.',
    inputSchema: _noArgs,
    annotations: ToolAnnotations.read,
    categories: {DataCategory.training},
  ),
  McpTool(
    name: 'get_cardio',
    title: 'Cardio',
    description:
        'Sesiones de cardio terminadas de los últimos días (1–90): actividad, '
        'minutos e intensidad; las kcal estimadas solo si compartió su peso.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'days': {'type': 'integer', 'minimum': 1, 'maximum': 90},
      },
      'additionalProperties': false,
    },
    annotations: ToolAnnotations.read,
    categories: {DataCategory.training},
  ),
  McpTool(
    name: 'get_nutrition',
    title: 'Comidas',
    description:
        'Comidas registradas por día (hasta 31 días, por defecto los últimos '
        '7) con kcal, macros conocidas y su origen, más los objetivos propios. '
        'Un día sin registros no es un día con 0 kcal.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'from': {'type': 'string', 'pattern': r'^\d{4}-\d{2}-\d{2}$'},
        'to': {'type': 'string', 'pattern': r'^\d{4}-\d{2}-\d{2}$'},
      },
      'additionalProperties': false,
    },
    annotations: ToolAnnotations.read,
    categories: {DataCategory.nutrition},
  ),
  McpTool(
    name: 'get_coach_recommendations',
    title: 'Recomendaciones del minicoach',
    description:
        'Lo que dicen ahora las reglas locales del minicoach (expert-v1): '
        'cada recomendación con su clave, por qué y respaldo, y los vetos de '
        'seguridad que impiden aumentos. Es la referencia: no la contradigas '
        'sin explicar por qué.',
    inputSchema: _noArgs,
    annotations: ToolAnnotations.read,
    categories: {DataCategory.training},
  ),
  McpTool(
    name: 'get_exercise_catalog',
    title: 'Catálogo de ejercicios',
    description:
        'Ejercicios de la app (id, nombre, grupo, músculos, equipo, tipo de '
        'carga y alternativas compatibles). Opcionalmente filtra por texto.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'query': {'type': 'string', 'maxLength': 40},
      },
      'additionalProperties': false,
    },
    annotations: ToolAnnotations.read,
  ),
  McpTool(
    name: 'propose_food_entry',
    title: 'Proponer una comida',
    description:
        'Propone registrar una comida con calorías estimadas. No guarda nada: '
        'la persona la revisa en el formulario y decide. Devuelve el id de la '
        'propuesta.',
    inputSchema: {
      'type': 'object',
      'required': ['name', 'kcal', 'confidence'],
      'properties': {
        'date': {'type': 'string', 'pattern': r'^\d{4}-\d{2}-\d{2}$'},
        'name': {'type': 'string', 'minLength': 1, 'maxLength': 80},
        'kcal': {'type': 'integer', 'minimum': 0, 'maximum': 5000},
        'proteinG': {'type': 'number', 'minimum': 0, 'maximum': 2000},
        'carbsG': {'type': 'number', 'minimum': 0, 'maximum': 2000},
        'fatG': {'type': 'number', 'minimum': 0, 'maximum': 2000},
        'portion': {'type': 'number', 'exclusiveMinimum': 0, 'maximum': 100000},
        'unit': {'type': 'string', 'maxLength': 12},
        'confidence': {
          'enum': ['low', 'medium', 'high'],
        },
        'assumptions': {
          'type': 'array',
          'maxItems': 5,
          'items': {'type': 'string', 'maxLength': 120},
        },
      },
      'additionalProperties': false,
    },
    annotations: ToolAnnotations.propose,
    categories: {DataCategory.nutrition},
  ),
  McpTool(
    name: 'show_recommendation',
    title: 'Señalar una recomendación del minicoach',
    description:
        'Muestra a la persona una recomendación local (por su clave, de '
        'get_coach_recommendations) para que la acepte o no desde la app.',
    inputSchema: {
      'type': 'object',
      'required': ['key'],
      'properties': {
        'key': {'type': 'string', 'maxLength': 330},
      },
      'additionalProperties': false,
    },
    annotations: ToolAnnotations.propose,
    categories: {DataCategory.training},
  ),
];

McpTool? toolNamed(String name) {
  for (final t in forjaTools) {
    if (t.name == name) return t;
  }
  return null;
}

/// Runs [tool] with [args]. Throws [ToolArgumentError] for wrong arguments;
/// returns the structured result otherwise. Never writes data.
Object? runForjaTool(
  McpTool tool,
  Map<String, Object?> args,
  ForjaToolContext ctx,
) {
  final a = _Args(args, (tool.inputSchema['properties'] as Map).keys.toSet());
  return switch (tool.name) {
    'get_profile' => _profile(ctx),
    'get_training_history' => _history(
      ctx,
      a.integer('days', 1, 90, 28),
      a.string('exerciseId', 40),
    ),
    'get_progress_summary' => _progress(ctx, a.integer('days', 7, 90, 28)),
    'get_plan' => _plan(ctx),
    'get_cardio' => _cardio(ctx, a.integer('days', 1, 90, 28)),
    'get_nutrition' => _nutrition(ctx, a.date('from'), a.date('to')),
    'get_coach_recommendations' => _recommendations(ctx),
    'get_exercise_catalog' => _catalog(ctx, a.string('query', 40)),
    'propose_food_entry' => _proposeFood(ctx, a),
    'show_recommendation' => _showRecommendation(
      ctx,
      a.requiredString('key', 330),
    ),
    _ => throw ToolArgumentError('herramienta desconocida: ${tool.name}'),
  };
}

/// Text the person wrote, as data: control characters out, length limited.
String userText(String text, [int max = 200]) {
  final t = text.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ').trim();
  return t.length > max ? '${t.substring(0, max)}…' : t;
}

class _Args {
  _Args(this.args, Set<Object?> allowed) {
    for (final k in args.keys) {
      if (!allowed.contains(k)) {
        throw ToolArgumentError('argumento desconocido: $k');
      }
    }
  }
  final Map<String, Object?> args;

  int integer(String k, int min, int max, int fallback) {
    final v = args[k];
    if (v == null) return fallback;
    if (v is! num || v != v.roundToDouble() || v < min || v > max) {
      throw ToolArgumentError('$k debe ser un entero entre $min y $max');
    }
    return v.toInt();
  }

  double? number(String k, double min, double max, {bool open = false}) {
    final v = args[k];
    if (v == null) return null;
    if (v is! num || !v.isFinite || v > max || v < min || (open && v <= min)) {
      throw ToolArgumentError('$k fuera de rango');
    }
    return v.toDouble();
  }

  String? string(String k, int max) {
    final v = args[k];
    if (v == null) return null;
    if (v is! String || v.length > max) {
      throw ToolArgumentError('$k debe ser texto de hasta $max caracteres');
    }
    return v;
  }

  String requiredString(String k, int max) {
    final v = string(k, max);
    if (v == null || v.trim().isEmpty) throw ToolArgumentError('falta $k');
    return v;
  }

  String? date(String k) {
    final v = string(k, 10);
    if (v == null) return null;
    final d = DateTime.tryParse(v);
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v) ||
        d == null ||
        dateKey(d) != v) {
      throw ToolArgumentError('$k debe ser una fecha AAAA-MM-DD');
    }
    return v;
  }
}

Map<String, Object?> _profile(ForjaToolContext ctx) {
  final p = ctx.profiles.profile;
  return {
    'experience': experienceLabels[p.experience],
    'goal': goalLabels[p.goal],
    'habitualEnergy': energyLabels[p.energy],
    'trainingDays': [for (final d in p.trainingDays) weekdayNames[d - 1]],
    'sessionMinutes': p.sessionMinutes,
    'equipment': [
      for (final e in Equipment.values)
        if (p.equipment.contains(e)) equipmentLabels[e],
    ],
    'setupFinished': p.onboarded,
    if (ctx.allows(DataCategory.body)) ...{
      'weightKg': p.weightKg,
      'age': p.age,
    } else
      'body': 'no compartido',
    if (ctx.allows(DataCategory.notes) && p.note.trim().isNotEmpty)
      'note_userText': userText(p.note),
  };
}

String _from(ForjaToolContext ctx, int days) =>
    dateKey(nextDay(dateOnly(ctx.today), 1 - days));

/// Adds items (newest first) while the JSON stays within the budget.
List<Object?> _fit(Iterable<Object?> items, {int budget = 9000}) {
  final out = <Object?>[];
  var size = 2;
  for (final i in items) {
    final n = jsonEncode(i).length + 1;
    if (size + n > budget) break;
    size += n;
    out.add(i);
  }
  return out;
}

Map<String, Object?> _history(
  ForjaToolContext ctx,
  int days,
  String? exerciseId,
) {
  final from = _from(ctx, days), to = dateKey(dateOnly(ctx.today));
  final sessions = [
    for (final s in ctx.workouts.history)
      if (s.dateKey.compareTo(from) >= 0 && s.dateKey.compareTo(to) <= 0) s,
  ]..sort((a, b) => b.dateKey.compareTo(a.dateKey));
  final wellbeing = ctx.allows(DataCategory.wellbeing);
  final notes = ctx.allows(DataCategory.notes);
  final items = [
    for (final s in sessions)
      if (exerciseId == null ||
          s.exercises.any((e) => e.exerciseId == exerciseId))
        {
          'date': s.dateKey,
          'status': sessionLabels[s.status],
          'exercises': [
            for (final e in s.exercises)
              if (exerciseId == null || e.exerciseId == exerciseId)
                {
                  'id': e.exerciseId,
                  'name': ctx.catalog.exerciseById(e.exerciseId).name,
                  'done': e.completed,
                  if (e.skipped) 'skipped': true,
                  'technique': switch (e.technique) {
                    TechniqueRating.solid => 'sólida',
                    TechniqueRating.unstable => 'inestable',
                    null => 'sin valorar',
                  },
                  'workSets': [
                    for (final w in e.workSets)
                      {'kg': w.weightKg, 'reps': w.reps, 'rir': w.rir},
                  ],
                },
          ],
          if (wellbeing) ...{
            'before': ctx.workouts
                .checkInOn(parseDateKey(s.dateKey))
                ?.feeling
                .let((f) => feelingLabels[f]),
            'after': ctx.workouts
                .afterCheckInOn(parseDateKey(s.dateKey))
                ?.feeling
                .let((f) => feelingLabels[f]),
          },
          if (notes && s.note.trim().isNotEmpty)
            'note_userText': userText(s.note),
          if (notes)
            'checkInNote_userText': ctx.workouts
                .checkInOn(parseDateKey(s.dateKey))
                ?.note
                .let((n) => n.trim().isEmpty ? null : userText(n)),
        },
  ];
  final fitted = _fit(items);
  return {
    'from': from,
    'to': to,
    'sessions': fitted,
    if (fitted.length < items.length) 'truncated': true,
    if (!wellbeing) 'wellbeing': 'no compartido',
  };
}

Map<String, Object?> _progress(ForjaToolContext ctx, int days) {
  final end = dateOnly(ctx.today), start = nextDay(end, 1 - days);
  bool planned(DateTime d) => ctx.workouts.routineOn(d) != null;
  final history = ctx.workouts.history;
  final c = ProgressStats.compliance(
    sessions: history,
    reschedules: ctx.workouts.reschedules,
    start: start,
    end: end,
    today: end,
    planned: planned,
  );
  LoadType loadType(String id) => ctx.catalog.exerciseById(id).loadType;
  final v = ProgressStats.volume(
    sessions: history,
    start: start,
    end: end,
    loadType: loadType,
  );
  final streak = Streak(
    sessions: history,
    reschedules: ctx.workouts.reschedules,
    planned: planned,
    today: end,
  );
  final trends = ProgressStats.trends(
    sessions: history,
    start: start,
    end: end,
    loadType: loadType,
  );
  return {
    'from': dateKey(start),
    'to': dateKey(end),
    'compliance': {
      'completed': c.done,
      'due': c.due,
      'partial': c.partial,
      'missed': c.missed,
      'unrecorded': c.unrecorded,
      'moved': c.moved,
    },
    'volumeKgReps': v.kgReps.round(),
    'volumeCoverage': v.coverage == null ? null : (v.coverage! * 100).round(),
    'bests': [
      for (final t in trends.take(12))
        if (t.best != null)
          {
            'exercise': ctx.catalog.exerciseById(t.exerciseId).name,
            'kg': t.best!.weightKg,
            'reps': t.best!.reps,
            'date': t.best!.dateKey,
          },
    ],
    'streak': {'current': streak.current, 'best': streak.best},
  };
}

Map<String, Object?> _plan(ForjaToolContext ctx) {
  final plan = ctx.workouts.planFor(dateOnly(ctx.today));
  Map<String, Object?> routine(Routine r) => {
    'name': r.name,
    'exercises': [
      for (final e in r.exercises)
        {
          'id': e.exerciseId,
          'name': ctx.catalog.exerciseById(e.exerciseId).name,
          'sets': e.sets,
          'reps': '${e.repsMin}–${e.repsMax}',
          'rir': e.rir,
          'restSeconds': e.restSeconds,
        },
    ],
  };
  return {
    'name': plan.source == PlanSource.example ? 'Plan de ejemplo' : plan.name,
    'source': switch (plan.source) {
      PlanSource.example => 'plantilla de ejemplo, adaptada al perfil',
      PlanSource.generated => 'generado desde el perfil',
      PlanSource.manual => 'editado por la persona',
    },
    'days': [
      for (final d in plan.days)
        {'weekday': weekdayNames[d.weekday - 1], ...routine(d.routine)},
    ],
    'draftPending': ctx.plans.draft != null,
  };
}

Map<String, Object?> _cardio(ForjaToolContext ctx, int days) {
  final from = _from(ctx, days);
  final body = ctx.allows(DataCategory.body);
  final sessions = [
    for (final c in ctx.cardio?.cardioHistory ?? const <CardioSession>[])
      if (dateKey(c.startedAt.toLocal()).compareTo(from) >= 0)
        {
          'date': dateKey(c.startedAt.toLocal()),
          'activity': cardioLabels[c.activity],
          'minutes': c.duration(c.finishedAt ?? c.startedAt).inMinutes,
          'intensities': [
            for (final i in {for (final s in c.segments) s.intensity})
              cardioIntensityLabels[i],
          ],
          if (ctx.allows(DataCategory.wellbeing) && c.feedback != null)
            'feeling': feelingLabels[c.feedback],
          if (body)
            'kcalEstimated': CardioMath.kcal(
              c,
              c.finishedAt ?? c.startedAt,
            )?.round(),
        },
  ];
  return {'from': from, 'sessions': _fit(sessions)};
}

Map<String, Object?> _nutrition(
  ForjaToolContext ctx,
  String? from,
  String? to,
) {
  final end = to == null ? dateOnly(ctx.today) : parseDateKey(to);
  final start = from == null ? nextDay(end, -6) : parseDateKey(from);
  if (start.isAfter(end)) {
    throw const ToolArgumentError('from es posterior a to');
  }
  final span = DateTime.utc(
    end.year,
    end.month,
    end.day,
  ).difference(DateTime.utc(start.year, start.month, start.day)).inDays;
  if (span > 30) throw const ToolArgumentError('como mucho 31 días');
  final n = ctx.nutrition;
  if (n == null) return {'days': const []};
  final days = <Object?>[];
  for (var d = end; !d.isBefore(start); d = nextDay(d, -1)) {
    final entries = n.foodOn(d);
    if (entries.isEmpty) continue;
    final known = entries.where((e) => e.proteinG != null).length;
    days.add({
      'date': dateKey(d),
      'totalKcal': entries.fold<int>(0, (s, e) => s + e.calories),
      'entries': [
        for (final e in entries)
          {
            'name_userText': userText(e.name, 80),
            'kcal': e.calories,
            'source': switch (e.caloriesSource) {
              CaloriesSource.manual => 'manual',
              CaloriesSource.macros => 'desde macros',
              CaloriesSource.recipe => 'receta',
              CaloriesSource.estimated => 'estimada (IA)',
            },
            'proteinG': e.proteinG,
            'carbsG': e.carbsG,
            'fatG': e.fatG,
          },
      ],
      'proteinKnownIn': '$known de ${entries.length}',
    });
  }
  final g = n.goals;
  return {
    'from': dateKey(start),
    'to': dateKey(end),
    'days': _fit(days),
    'goals': g.isEmpty
        ? 'sin objetivos propios'
        : {
            'kcal': g.kcal,
            'proteinG': g.proteinG,
            'carbsG': g.carbsG,
            'fatG': g.fatG,
          },
    'note': 'Los días sin registros no aparecen: no son días con 0 kcal.',
  };
}

Map<String, Object?> _recommendations(ForjaToolContext ctx) {
  final result = ctx.expert();
  final wellbeing = ctx.allows(DataCategory.wellbeing);
  final nutrition = ctx.allows(DataCategory.nutrition);
  final muted = {
    for (final p in ctx.coach?.coachPreferences ?? const <CoachPreference>[])
      if (p.muted) p.family,
  };
  final items = <Object?>[];
  for (final r in result.recommendations) {
    if (muted.contains(r.family.name)) continue;
    if (r.family == RuleFamily.nutrition && !nutrition) continue;
    final private = !wellbeing && r.family == RuleFamily.safety;
    items.add({
      'key': r.key,
      'rule': r.ruleId,
      'family': r.family.label,
      'kind': r.kind.name,
      'title': private ? 'Aviso de seguridad local' : r.title,
      'summary': private
          ? 'Hay un aviso de seguridad local; el detalle no se comparte.'
          : r.summary,
      if (!private) 'because': [for (final f in r.because) f.toString()],
      'evidence': r.evidence.level.label,
      if (r.action != null && r.kind != RecommendationKind.blocked)
        'action': r.action!.label,
      if (r.vetoedBy != null) 'blockedBy': r.vetoedBy,
    });
  }
  return {
    'kbVersion': result.kbVersion,
    'recommendations': _fit(items),
    'vetoes': [
      for (final v in result.vetoes.all)
        {
          'kind': switch (v.kind) {
            VetoKind.loadIncrease => 'sin aumentos de carga',
            VetoKind.volumeIncrease => 'sin más volumen',
            VetoKind.nutritionRanges => 'sin rangos de nutrición',
          },
          'exercise': v.exerciseId,
          'reason': wellbeing ? v.reason : 'motivo de seguridad local',
        },
    ],
  };
}

Map<String, Object?> _catalog(ForjaToolContext ctx, String? query) {
  final all = ctx.catalog.exercises.where((e) => !e.archived);
  final equipment = ctx.profiles.profile.equipment;
  final found = query == null || query.trim().isEmpty
      ? all.toList()
      : searchExercises(all, query: query);
  return {
    'exercises': [
      for (final e in found)
        {
          'id': e.id,
          'name': e.name,
          'group': e.group,
          'muscles': e.muscles,
          'equipment': equipmentLabels[e.equipment],
          'load': switch (e.loadType) {
            LoadType.external => 'carga externa',
            LoadType.bodyweight => 'peso corporal',
            LoadType.time => 'tiempo',
          },
          'alternatives': [
            for (final x in alternativesFor(e, all, equipment)) x.id,
          ],
        },
    ],
  };
}

Map<String, Object?> _proposeFood(ForjaToolContext ctx, _Args a) {
  final name = a.requiredString('name', 80).trim();
  final kcal = a.integer('kcal', 0, 5000, -1);
  if (kcal < 0) throw const ToolArgumentError('falta kcal');
  final confidence = a.requiredString('confidence', 6);
  if (!{'low', 'medium', 'high'}.contains(confidence)) {
    throw const ToolArgumentError('confidence: low, medium o high');
  }
  final today = dateOnly(ctx.today);
  final date = a.date('date') ?? dateKey(today);
  final d = parseDateKey(date);
  if (d.isAfter(today) || d.isBefore(nextDay(today, -30))) {
    throw const ToolArgumentError('la fecha va de hace 30 días a hoy');
  }
  final rawAssumptions = a.args['assumptions'];
  if (rawAssumptions != null &&
      (rawAssumptions is! List ||
          rawAssumptions.length > 5 ||
          rawAssumptions.any((x) => x is! String || x.length > 120))) {
    throw const ToolArgumentError('assumptions: hasta 5 textos cortos');
  }
  final proposal = FoodProposal(
    ctx.inbox.newId(),
    ctx.inbox.now(),
    dateKey: date,
    name: userText(name, 80),
    kcal: kcal,
    proteinG: a.number('proteinG', 0, 2000),
    carbsG: a.number('carbsG', 0, 2000),
    fatG: a.number('fatG', 0, 2000),
    portion: a.number('portion', 0, 100000, open: true),
    unit: a.string('unit', 12),
    confidence: confidence,
    assumptions: [
      for (final x in (rawAssumptions as List?) ?? const [])
        userText('$x', 120),
    ],
  );
  ctx.inbox.add(proposal);
  return {
    'status': 'awaiting_user_confirmation',
    'proposalId': proposal.id,
    'note': 'La persona la revisará en el formulario; no está guardada.',
  };
}

Map<String, Object?> _showRecommendation(ForjaToolContext ctx, String key) {
  final result = ctx.expert();
  Recommendation? found;
  for (final r in result.recommendations) {
    if (r.key == key) found = r;
  }
  if (found == null) {
    throw const ToolArgumentError(
      'no hay una recomendación con esa clave; usa get_coach_recommendations',
    );
  }
  if (found.kind == RecommendationKind.blocked) {
    return {
      'status': 'vetoed',
      'reasons': [found.summary],
    };
  }
  final proposal = RecommendationProposal(
    ctx.inbox.newId(),
    ctx.inbox.now(),
    found,
  );
  ctx.inbox.add(proposal);
  return {'status': 'shown_to_user', 'proposalId': proposal.id};
}

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
