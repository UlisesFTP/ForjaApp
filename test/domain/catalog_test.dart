import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/seed/catalog.dart';
import 'package:forja_app/domain/models/models.dart';
import 'package:forja_app/domain/services/plan_validator.dart';

void main() {
  test('every exercise is complete and has sane defaults', () {
    final ids = <String>{};
    for (final e in exerciseCatalog) {
      expect(ids.add(e.id), isTrue, reason: 'duplicate id ${e.id}');
      for (final text in [
        e.name,
        e.group,
        e.muscles,
        e.description,
        e.warmup,
        e.tip,
      ]) {
        expect(text.trim(), isNotEmpty, reason: '${e.id} has an empty text');
      }
      expect(e.sets, inInclusiveRange(1, 6), reason: e.id);
      expect(e.repsMin, greaterThanOrEqualTo(1), reason: e.id);
      expect(e.repsMax, greaterThanOrEqualTo(e.repsMin), reason: e.id);
      expect(e.rir, inInclusiveRange(0, 5), reason: e.id);
      expect(e.restSeconds, inInclusiveRange(30, 300), reason: e.id);
      expect(e.incrementKg, greaterThanOrEqualTo(0), reason: e.id);
      // Body-weight and timed exercises carry no external load.
      if (e.loadType != LoadType.external) {
        expect(e.defaultWeight, 0, reason: e.id);
        expect(e.incrementKg, 0, reason: e.id);
      }
      if (e.equipment == Equipment.bodyweight) {
        expect(e.loadType, isNot(LoadType.external), reason: e.id);
      }
    }
  });
  test('the catalog covers every muscle group and every kind of equipment', () {
    expect(exerciseCatalog.map((e) => e.group).toSet(), {
      'Piernas',
      'Pecho',
      'Hombros',
      'Espalda',
      'Brazos',
      'Core',
    });
    for (final equipment in Equipment.values) {
      expect(
        exerciseCatalog.where((e) => e.equipment == equipment),
        isNotEmpty,
        reason: equipment.name,
      );
    }
  });
  test('no tutorial is promised without a verified link', () {
    for (final e in exerciseCatalog) {
      final url = e.tutorialUrl;
      if (url == null) continue;
      final uri = Uri.parse(url);
      expect(uri.scheme, 'https', reason: e.id);
      expect(
        {'www.youtube.com', 'youtube.com', 'youtu.be'},
        contains(uri.host),
        reason: e.id,
      );
    }
    // The fallback is always a search, and it is labelled as such in the UI.
    expect(exerciseCatalog.first.tutorialUri.host, 'www.youtube.com');
    expect(exerciseCatalog.first.tutorialUri.path, '/results');
  });
  test('the example plan is 0.1 template: Tuesday, Thursday, Saturday', () {
    expect(legacyTemplatePlan.source, PlanSource.example);
    expect(legacyTemplatePlan.status, PlanStatus.accepted);
    expect(
      {for (final d in legacyTemplatePlan.days) d.weekday: d.routine.id},
      {
        DateTime.tuesday: 'legs',
        DateTime.thursday: 'push',
        DateTime.saturday: 'pull',
      },
    );
    expect(legacyTemplatePlan.routines.map((r) => r.exerciseIds), [
      ['squat', 'rdl', 'press'],
      ['bench', 'shoulder', 'triceps'],
      ['row', 'pulldown', 'curl'],
    ]);
    // Reference weights are the 0.1 examples, never prescriptions.
    expect(
      legacyTemplatePlan.routines.first.exercises.first.referenceWeightKg,
      40,
    );
    expect(
      PlanValidator.validate(
        legacyTemplatePlan,
        forAcceptance: true,
        isKnown: (id) => !exerciseFor(id).archived,
      ),
      isEmpty,
    );
  });
  test('an unknown id yields an archived placeholder instead of failing', () {
    final gone = exerciseFor('retired-exercise');
    expect(gone.archived, isTrue);
    expect(gone.id, 'retired-exercise');
    expect(gone.name, 'Ejercicio archivado');
    expect(exerciseFor('squat').archived, isFalse);
  });
}
