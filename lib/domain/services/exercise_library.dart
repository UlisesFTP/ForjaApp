import '../models/labels.dart';
import '../models/models.dart';

/// Lowercase and without accents, so "tríceps" and "triceps" match.
String foldAccents(String text) {
  const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const to = 'aaaaaeeeeiiiiooooouuuunc';
  final out = StringBuffer();
  for (final unit in text.toLowerCase().runes) {
    final char = String.fromCharCode(unit);
    final at = from.indexOf(char);
    out.write(at < 0 ? char : to[at]);
  }
  return out.toString();
}

/// Exercises matching every word of [query] (name, muscles, group or
/// equipment), in [group] and with [equipment] when those are given.
List<Exercise> searchExercises(
  Iterable<Exercise> all, {
  String query = '',
  String? group,
  Set<Equipment>? equipment,
}) {
  final words = foldAccents(query)
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty);
  return [
    for (final e in all)
      if ((group == null || e.group == group) &&
          (equipment == null || equipment.contains(e.equipment)) &&
          _matches(e, words))
        e,
  ];
}

bool _matches(Exercise e, Iterable<String> words) {
  if (words.isEmpty) return true;
  final haystack = foldAccents(
    '${e.name} ${e.muscles} ${e.group} ${equipmentLabels[e.equipment]}',
  );
  return words.every(haystack.contains);
}

/// Other exercises of the same group and movement pattern that [available]
/// equipment allows, closest equipment first.
List<Exercise> alternativesFor(
  Exercise exercise,
  Iterable<Exercise> catalog,
  Set<Equipment> available,
) => [
  for (final e in catalog)
    if (e.id != exercise.id &&
        e.group == exercise.group &&
        e.pattern == exercise.pattern &&
        available.contains(e.equipment))
      e,
];
