import 'package:postgres/postgres.dart';
import '001_create_todos_table.dart';

class MigrationRunner {
  final Connection connection;

  MigrationRunner(this.connection);

  Future<void> run() async {
    print('🚀 Starting Database Migrations...');

    // Daftar semua migrasi
    await CreateTodosTable().up(connection);

    print('✅ All Migrations Completed!');
  }
}
