import 'package:drift/drift.dart';

import '../../domain/models/models.dart';
import '../../domain/models/storage_failure.dart';
import 'forja_database.steps.dart';
import 'tables.dart';

part 'forja_database.g.dart';

/// The schema version of this build; backups record it for information.
const currentSchemaVersion = 7;

@DriftDatabase(
  tables: [
    Profiles,
    ProfileHistory,
    Reminders,
    WorkoutSessions,
    SessionExercises,
    CalendarOverrides,
    CheckIns,
    FoodEntries,
    LegacyImports,
    PlanVersions,
    PlanRoutines,
    PlanRoutineExercises,
    SetLogs,
    SessionEvents,
    Reschedules,
    SessionAdjustments,
    ProgressionDecisions,
    MonthlyReviews,
    CardioSessions,
    CardioSegments,
    FoodFavorites,
    Recipes,
    RecipeIngredients,
    NutritionGoalsTable,
    CoachDecisions,
    CoachPreferences,
  ],
)
class ForjaDatabase extends _$ForjaDatabase {
  ForjaDatabase(super.executor);

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Atomic: an interruption must not leave a half-created schema behind.
    onCreate: (migrator) => transaction(migrator.createAll),
    onUpgrade: (migrator, from, to) async {
      // `user_version` is only written after this callback succeeds, so
      // throwing here leaves a database from a newer app version untouched.
      if (from > to) {
        throw DatabaseNewerThanApp(databaseVersion: from, appVersion: to);
      }
      // Rebuilding a table needs foreign keys off; they are checked after.
      await customStatement('PRAGMA foreign_keys = OFF');
      await transaction(() async {
        await _upgrade(migrator, from, to);
        final broken = await customSelect('PRAGMA foreign_key_check').get();
        if (broken.isNotEmpty) {
          throw StateError('The migration left broken foreign keys.');
        }
      });
    },
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );

  late final _upgrade = stepByStep(
    from1To2: (m, schema) async {
      // Body weight and age may now be unknown, and the profile gains the
      // days, equipment and time answers (with defaults for existing rows).
      await m.alterTable(
        TableMigration(
          schema.profiles,
          newColumns: [
            schema.profiles.equipment,
            schema.profiles.trainingDays,
            schema.profiles.sessionMinutes,
            schema.profiles.setupSkipped,
            schema.profiles.setupStep,
          ],
        ),
      );
      // 0.1 prefilled 70 kg / 28 years before the profile was ever saved;
      // those were defaults, not answers.
      await m.database.customStatement(
        'UPDATE profiles SET weight_kg = NULL, age = NULL WHERE onboarded = 0',
      );
      await m.createTable(schema.profileHistory);
      await m.createTable(schema.planVersions);
      await m.createTable(schema.planRoutines);
      await m.createTable(schema.planRoutineExercises);
    },
    from2To3: (m, schema) async {
      // Existing check-ins were all taken before training; the unique key now
      // includes the phase, which needs the table rebuilt.
      await m.alterTable(
        TableMigration(schema.checkIns, newColumns: [schema.checkIns.phase]),
      );
      await m.addColumn(schema.profiles, schema.profiles.weightUnit);
      // Sessions imported or saved before P3 keep their checklist state; the
      // new skip columns default to "not skipped" and there are no sets, so
      // nothing about past work is invented.
      await m.addColumn(
        schema.sessionExercises,
        schema.sessionExercises.skipped,
      );
      await m.addColumn(
        schema.sessionExercises,
        schema.sessionExercises.skipReason,
      );
      await m.createTable(schema.setLogs);
      await m.createIndex(schema.setLogsExercise);
      await m.createTable(schema.sessionEvents);
      await m.createTable(schema.reschedules);
      await m.createTable(schema.sessionAdjustments);
    },
    from3To4: (m, schema) async {
      // Nothing about past work is invented: technique starts unknown, no
      // review or decision exists yet, and no review is postponed.
      await m.addColumn(schema.profiles, schema.profiles.reviewSnoozeUntil);
      await m.addColumn(
        schema.profileHistory,
        schema.profileHistory.rulesVersion,
      );
      await m.addColumn(
        schema.sessionExercises,
        schema.sessionExercises.technique,
      );
      await m.createTable(schema.progressionDecisions);
      await m.createTable(schema.monthlyReviews);
    },
    from4To5: (m, schema) async {
      await m.createTable(schema.cardioSessions);
      await m.createTable(schema.cardioSegments);
    },
    from5To6: (m, schema) async {
      // Existing entries keep their calories as the explicit, manual number;
      // portion and macros start unknown (null), never zero.
      final food = schema.foodEntries;
      await m.addColumn(food, food.portion);
      await m.addColumn(food, food.unit);
      await m.addColumn(food, food.proteinG);
      await m.addColumn(food, food.carbsG);
      await m.addColumn(food, food.fatG);
      await m.addColumn(food, food.caloriesSource);
      await m.addColumn(food, food.recipeId);
      await m.createTable(schema.foodFavorites);
      await m.createTable(schema.recipes);
      await m.createTable(schema.recipeIngredients);
      await m.createTable(schema.nutritionGoals);
    },
    from6To7: (m, schema) async {
      // Saved favorites were all typed by hand or worked out from macros
      // before there were estimates: they keep the manual default. The
      // expert system starts with no decisions and nothing silenced.
      await m.addColumn(
        schema.foodFavorites,
        schema.foodFavorites.caloriesSource,
      );
      await m.createTable(schema.coachDecisions);
      await m.createTable(schema.coachPreferences);
    },
  );
}
