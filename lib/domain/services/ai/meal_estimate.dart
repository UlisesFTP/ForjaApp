import 'dart:convert';

import '../../models/models.dart';

/// One food of an estimate.
class MealItem {
  const MealItem({
    required this.name,
    required this.kcal,
    this.grams,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });
  final String name;
  final int kcal;
  final double? grams, proteinG, carbsG, fatG;
}

enum EstimateConfidence {
  low('baja'),
  medium('media'),
  high('alta');

  const EstimateConfidence(this.label);
  final String label;
}

/// An external assistant's estimate of a meal (F17, D38), already checked.
/// It only fills the food form: the person reviews it and saves it, and it
/// is stored with the `estimated` source.
class MealEstimate {
  const MealEstimate({
    required this.title,
    required this.items,
    required this.totalKcal,
    required this.confidence,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.assumptions = const [],
    this.question,
    this.warnings = const [],
  });
  final String title;
  final List<MealItem> items;
  final int totalKcal;
  final double? proteinG, carbsG, fatG;
  final EstimateConfidence confidence;
  final List<String> assumptions;
  final String? question;

  /// What the checks corrected or noticed, in words.
  final List<String> warnings;

  /// Reads and checks the assistant's answer. Throws [FormatException] when
  /// it is not a usable estimate (the caller asks once more, then gives up).
  static MealEstimate parse(String text) {
    final raw = _jsonPart(text);
    final Object? root;
    try {
      root = jsonDecode(raw);
    } on FormatException {
      throw const FormatException('no es JSON');
    }
    if (root is! Map<String, dynamic>) {
      throw const FormatException('no es un objeto');
    }
    final title = _text(root['title'], 80);
    if (title == null) throw const FormatException('falta el nombre');
    final rawItems = root['items'];
    if (rawItems is! List || rawItems.isEmpty || rawItems.length > 12) {
      throw const FormatException('de 1 a 12 alimentos');
    }
    final items = <MealItem>[];
    for (final i in rawItems) {
      if (i is! Map) throw const FormatException('alimento no válido');
      final name = _text(i['name'], 60);
      final kcal = _int(i['kcal'], 0, 3000);
      if (name == null || kcal == null) {
        throw const FormatException('alimento sin nombre o calorías');
      }
      items.add(
        MealItem(
          name: name,
          kcal: kcal,
          grams: _num(i['grams'], 0, 5000),
          proteinG: _num(i['proteinG'], 0, 500),
          carbsG: _num(i['carbsG'], 0, 500),
          fatG: _num(i['fatG'], 0, 500),
        ),
      );
    }
    final claimed = _int(root['totalKcal'], 0, 5000);
    final sum = items.fold<int>(0, (s, i) => s + i.kcal);
    if (sum > 5000) throw const FormatException('más de 5000 kcal');
    final warnings = <String>[];
    var total = claimed ?? sum;
    // The items are the detail: a total that does not add up is recomputed.
    if (claimed == null ||
        ((claimed - sum).abs() > 10 && (claimed - sum).abs() > sum * 0.05)) {
      if (claimed != null) {
        warnings.add(
          'El total no coincidía con la suma de los alimentos: se usa la suma.',
        );
      }
      total = sum;
    }
    final data = root;
    double? macro(String key, double? Function(MealItem) pick) {
      final stated = _num(data[key], 0, 2000);
      if (stated != null) return stated;
      if (items.every((i) => pick(i) != null)) {
        return items.fold<double>(0, (s, i) => s + pick(i)!);
      }
      return null;
    }

    final p = macro('proteinG', (i) => i.proteinG);
    final c = macro('carbsG', (i) => i.carbsG);
    final f = macro('fatG', (i) => i.fatG);
    final fromMacros = caloriesFromMacros(p, c, f);
    if (fromMacros != null &&
        total > 0 &&
        (fromMacros - total).abs() / total > 0.2) {
      warnings.add(
        'Las macros y las calorías no cuadran del todo (4·P + 4·C + 9·G = '
        '$fromMacros kcal): revísalas.',
      );
    }
    final assumptions = <String>[
      for (final a
          in (root['assumptions'] is List
              ? root['assumptions'] as List
              : const []))
        ?_text(a, 120),
    ];
    return MealEstimate(
      title: title,
      items: items,
      totalKcal: total,
      proteinG: p,
      carbsG: c,
      fatG: f,
      confidence: switch (root['confidence']) {
        'high' => EstimateConfidence.high,
        'medium' => EstimateConfidence.medium,
        _ => EstimateConfidence.low,
      },
      assumptions: assumptions.take(5).toList(),
      question: _text(root['question'], 160),
      warnings: warnings,
    );
  }

  /// The JSON object inside an answer that may wrap it in text or fences.
  static String _jsonPart(String text) {
    final start = text.indexOf('{'), end = text.lastIndexOf('}');
    if (start < 0 || end <= start) throw const FormatException('sin objeto');
    return text.substring(start, end + 1);
  }

  /// Plain text: control characters removed, trimmed, length-limited.
  static String? _text(Object? v, int max) {
    if (v is! String) return null;
    final t = v.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ').trim();
    if (t.isEmpty) return null;
    return t.length > max ? t.substring(0, max).trim() : t;
  }

  static int? _int(Object? v, int min, int max) {
    if (v is! num || !v.isFinite) return null;
    final n = v.round();
    return n < min || n > max ? null : n;
  }

  static double? _num(Object? v, double min, double max) {
    if (v is! num || !v.isFinite) return null;
    final d = v.toDouble();
    return d < min || d > max ? null : (d * 10).round() / 10;
  }
}
