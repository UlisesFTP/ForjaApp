import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:forja_app/core/ids.dart';
import 'package:forja_app/data/database/forja_database.dart';
import 'package:forja_app/data/repositories/local_forja_repository.dart';
import 'package:forja_app/data/services/drift_forja_store.dart';

const userTables = [
  'profiles',
  'profile_history',
  'plan_versions',
  'plan_routines',
  'plan_routine_exercises',
  'reminders',
  'workout_sessions',
  'session_exercises',
  'calendar_overrides',
  'check_ins',
  'food_entries',
  'legacy_imports',
  'set_logs',
  'session_events',
  'reschedules',
  'session_adjustments',
  'progression_decisions',
  'monthly_reviews',
  'cardio_sessions',
  'cardio_segments',
  'food_favorites',
  'recipes',
  'recipe_ingredients',
  'nutrition_goals',
];

class InjectedFailure implements Exception {
  InjectedFailure(this.sql);
  final String sql;
  @override
  String toString() => 'InjectedFailure(disk unavailable): $sql';
}

/// Fails statements at the SQL layer, where a real IO error would surface.
/// Statements inside transactions pass through it too.
class FaultInjector extends QueryInterceptor {
  bool Function(String sql)? _failWhen;
  bool failCommit = false;
  int hits = 0;

  void arm(bool Function(String sql) when) {
    _failWhen = when;
    hits = 0;
  }

  void disarm() {
    _failWhen = null;
    failCommit = false;
  }

  void _check(String sql) {
    if (_failWhen?.call(sql) ?? false) {
      hits++;
      throw InjectedFailure(sql);
    }
  }

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    _check(statement);
    return super.runInsert(executor, statement, args);
  }

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    _check(statement);
    return super.runUpdate(executor, statement, args);
  }

  @override
  Future<int> runDelete(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    _check(statement);
    return super.runDelete(executor, statement, args);
  }

  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    _check(statement);
    return super.runCustom(executor, statement, args);
  }

  @override
  Future<void> commitTransaction(TransactionExecutor inner) {
    if (failCommit) {
      hits++;
      throw InjectedFailure('COMMIT');
    }
    return super.commitTransaction(inner);
  }
}

/// A repository over a real SQLite file.
class Opened {
  Opened(this.db, this.store, this.repo);
  final ForjaDatabase db;
  final DriftForjaStore store;
  final LocalForjaRepository repo;
  bool _closed = false;

  /// Waits for writes in flight and closes the database, like app shutdown.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    repo.dispose();
    await repo.close();
  }

  Future<Map<String, int>> counts() async => {
    for (final table in userTables)
      table:
          (await db
                  .customSelect('SELECT COUNT(*) AS n FROM $table')
                  .getSingle())
              .read<int>('n'),
  };
}

/// A temporary directory holding one SQLite file that tests open and reopen.
class StoreHarness {
  StoreHarness._(this.dir);
  static Future<StoreHarness> create() async =>
      StoreHarness._(await Directory.systemTemp.createTemp('forja_test_'));
  final Directory dir;
  final fault = FaultInjector();
  final _opened = <Opened>[];
  final _databases = <ForjaDatabase>[];
  File get file => File('${dir.path}/forja.sqlite');

  /// A connection to the file; [faulty] routes it through the injector,
  /// [background] opens it on its own isolate, as production does, and
  /// [maxPages] caps the file size so growing it fails like a full disk.
  QueryExecutor connection({
    bool faulty = true,
    bool background = false,
    int? maxPages,
  }) {
    final executor = background
        ? NativeDatabase.createInBackground(file)
        : NativeDatabase(
            file,
            setup: maxPages == null
                ? null
                : (raw) => raw.execute('PRAGMA max_page_count = $maxPages'),
          );
    return faulty ? executor.interceptWith(fault) : executor;
  }

  Future<Opened> open({
    DateTime Function()? clock,
    bool background = false,
    IdGenerator? newId,
  }) async {
    final db = ForjaDatabase(connection(background: background));
    _databases.add(db);
    final store = DriftForjaStore(db, clock: clock);
    await store.open();
    final repo = LocalForjaRepository(store, clock: clock, newId: newId);
    await repo.initialize();
    final opened = Opened(db, store, repo);
    _opened.add(opened);
    return opened;
  }

  Future<void> dispose() async {
    for (final opened in _opened) {
      await opened.close();
    }
    for (final db in _databases) {
      try {
        await db.close();
      } catch (_) {}
    }
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}
