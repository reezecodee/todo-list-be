import 'package:postgres/postgres.dart';

class CreateTodosTable {
  Future<void> up(Connection connection) async {
    print('   -> Migrating: 001_create_todos_table');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS todos (
        id VARCHAR(50) PRIMARY KEY,
        title TEXT NOT NULL,
        is_completed BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');
  }
}
