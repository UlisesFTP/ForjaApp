import 'dart:math';

typedef IdGenerator = String Function();

final _random = Random.secure();

/// Opaque, stable identifier: 128 random bits as hex.
String randomId() => List.generate(
  16,
  (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();
