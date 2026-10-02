import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forja_app/data/database/forja_database.dart';

import 'forja/generated/schema.dart';

// `drift_schemas/forja/` is the committed history of the schema. When tables
// change, bump `schemaVersion`, write the migration step, and run
// `dart run drift_dev make-migrations` before this test passes again.
void main() {
  test(
    'the schema the code declares is exactly the latest committed dump',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      // A database built from the dump, as the latest version has it...
      final schema = await verifier.schemaAt(GeneratedHelper.versions.last);
      final db = ForjaDatabase(schema.newConnection());
      addTearDown(db.close);
      // ...must match what the current code expects to find in it.
      await db.validateDatabaseSchema();
    },
  );
}
