import 'dart:async';

import 'package:forja_app/data/repositories/local_forja_repository.dart';
import 'package:forja_app/data/seed/catalog.dart';

/// Since D45 a new install starts without a plan. Most tests were written
/// for a three-day plan, so they keep 0.1's template as the starting plan;
/// `test/no_plan_test.dart` resets it to check the real empty start.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  LocalForjaRepository.debugStartingPlan = legacyTemplatePlan;
  await testMain();
}
