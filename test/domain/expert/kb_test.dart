import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/domain/expert/knowledge/knowledge_base.dart';

/// Every file a Dart file reaches through relative imports.
Set<String> _reachable(String start) {
  final seen = <String>{};
  final pending = [File(start).absolute.path];
  final import = RegExp(
    r'''^(?:import|export)\s+'([^']+)';''',
    multiLine: true,
  );
  while (pending.isNotEmpty) {
    final path = pending.removeLast();
    if (!seen.add(path)) continue;
    final text = File(path).readAsStringSync();
    for (final m in import.allMatches(text)) {
      final target = m.group(1)!;
      if (target.contains(':')) continue;
      pending.add(File(path).parent.uri.resolve(target).toFilePath());
    }
  }
  return seen;
}

void main() {
  group('knowledge base expert-v1', () {
    test('rule ids are unique and start with their family', () {
      final ids = [for (final r in knowledgeBaseV1) r.id];
      expect(ids.toSet(), hasLength(ids.length));
      for (final r in knowledgeBaseV1) {
        expect(r.id, startsWith('${r.family.name}.'));
        expect(ruleById(r.id), same(r));
        expect(r.specificity, greaterThan(0));
        expect(r.evidence.source, isNotEmpty);
      }
      expect(ruleById('nope.nope'), isNull);
    });

    test('the engine is pure Dart: no Flutter, files, network or platform', () {
      final files = <String>{};
      for (final f in Directory(
        'lib/domain/expert',
      ).listSync(recursive: true)) {
        if (f is File && f.path.endsWith('.dart')) {
          files.addAll(_reachable(f.path));
        }
      }
      expect(files, isNotEmpty);
      final forbidden = RegExp(
        r'''^import\s+'(package:flutter|dart:io|dart:ui|package:http|dart:html)''',
        multiLine: true,
      );
      for (final path in files) {
        expect(
          forbidden.hasMatch(File(path).readAsStringSync()),
          isFalse,
          reason: path,
        );
      }
    });
  });
}
