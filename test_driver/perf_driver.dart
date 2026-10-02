import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

/// Writes the frame statistics measured on the device to build/perf/.
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data == null) return;
    final dir = Directory('build/perf')..createSync(recursive: true);
    File('${dir.path}/summary.json')
        .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  },
);
