import 'dart:io';
import '../lib/database/db_connection.dart';
import '../lib/database/migrations/migration-runner.dart';

void main() async {
  print('🚧 Starting Manual Migration...');

  try {
    final db = AppDatabase();

    await db.init();

    final runner = MigrationRunner(db.postgres);
    await runner.run();

    print('✨ Migration Finished Successfully!');
    exit(0);
  } catch (e) {
    print('❌ Migration Failed:');
    print(e);
    exit(1);
  }
}
