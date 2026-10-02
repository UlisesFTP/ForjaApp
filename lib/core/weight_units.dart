import '../domain/models/models.dart';

/// Weights are stored in kilograms, unrounded. The unit only changes what the
/// person reads and types, so switching units never rewrites stored data.
const double kgPerLb = 0.45359237;

extension WeightUnitX on WeightUnit {
  String get label => this == WeightUnit.kg ? 'kg' : 'lb';

  /// Kilograms to the number shown in this unit (not rounded).
  double fromKg(double kg) => this == WeightUnit.kg ? kg : kg / kgPerLb;

  /// A number typed in this unit to kilograms (not rounded).
  double toKg(double value) => this == WeightUnit.kg ? value : value * kgPerLb;
}

/// Text for a weight in [unit]: at most two decimals, no trailing zeros.
/// Display only; the stored value keeps its full precision.
String weightText(double kg, WeightUnit unit) {
  final value = unit.fromKg(kg);
  final fixed = value.toStringAsFixed(2);
  final trimmed = fixed.contains('.')
      ? fixed.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')
      : fixed;
  return trimmed.isEmpty ? '0' : trimmed;
}

/// Parses a typed weight (comma or dot) in [unit] to kilograms; null when the
/// text is not a finite number.
double? parseWeightKg(String text, WeightUnit unit) {
  final value = double.tryParse(text.trim().replaceAll(',', '.'));
  if (value == null || !value.isFinite) return null;
  return unit.toKg(value);
}
