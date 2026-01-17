import 'package:postgres/postgres.dart';
import 'package:todo_backend/models/todo_model.dart';
import 'package:todo_backend/database/db_connection.dart';
import 'dart:convert';

class TodoService {
  final AppDatabase _db;

  TodoService(this._db);

  // 1. GET ALL
  Future<List<Todo>> getAllTodos() async {
    final cacheKey = 'todos:all';

    try {
      final cachedData = await _db.redisCommand.get(cacheKey);

      if (cachedData != null) {
        print('⚡ REDIS CACHE HIT: Mengambil data dari Redis');
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded
            .map((item) => Todo.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('⚠️ Redis Error: $e');
    }

    // Jika di Redis tidak ada (Cache Miss), ambil dari Postgres
    print('🐘 POSTGRES QUERY: Mengambil data dari PostgreSQL');
    final result = await _db.postgres.execute(
      'SELECT id, title, is_completed FROM todos ORDER BY created_at DESC',
    );

    final todos = result.map((row) {
      final map = row.toColumnMap();
      return Todo(
        id: map['id'] as String,
        title: map['title'] as String,
        isCompleted: map['is_completed'] as bool,
      );
    }).toList();

    // Simpan hasil dari Postgres ke Redis (Caching)
    // Kita set durasi expired (misal: 60 detik) agar data tidak basi selamanya
    try {
      final encodedData = jsonEncode(todos.map((e) => e.toJson()).toList());
      await _db.redisCommand.send_object(['SETEX', cacheKey, 60, encodedData]);
    } catch (e) {
      print('⚠️ Gagal menyimpan ke Redis: $e');
    }

    return todos;
  }

  // 2. CREATE
  Future<Todo> createTodo(String title) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // Query dengan Parameter (@nama_param) supaya aman dari SQL Injection
    await _db.postgres.execute(
      Sql.named(
          'INSERT INTO todos (id, title, is_completed) VALUES (@id, @title, @completed)'),
      parameters: {
        'id': id,
        'title': title,
        'completed': false,
      },
    );

    try {
      await _db.redisCommand.send_object(['DEL', 'todos:all']);
      print('🧹 Redis Cache Cleared');
    } catch (e) {
      print('⚠️ Gagal hapus cache: $e');
    }

    return Todo(id: id, title: title, isCompleted: false);
  }

  // 3. GET ONE
  Future<Todo?> getTodoById(String id) async {
    final result = await _db.postgres.execute(
      Sql.named('SELECT id, title, is_completed FROM todos WHERE id = @id'),
      parameters: {'id': id},
    );

    if (result.isEmpty) return null;

    final map = result.first.toColumnMap();
    return Todo(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: map['is_completed'] as bool,
    );
  }

  // 4. UPDATE
  Future<Todo?> updateTodo(String id,
      {String? title, bool? isCompleted}) async {
    final existingTodo = await getTodoById(id);
    if (existingTodo == null) return null;

    // Pakai data lama kalau parameter baru null
    final newTitle = title ?? existingTodo.title;
    final newStatus = isCompleted ?? existingTodo.isCompleted;

    await _db.postgres.execute(
      Sql.named(
          'UPDATE todos SET title = @title, is_completed = @status WHERE id = @id'),
      parameters: {
        'id': id,
        'title': newTitle,
        'status': newStatus,
      },
    );

    try {
      await _db.redisCommand.send_object(['DEL', 'todos:all']);
      print('🧹 Redis Cache Cleared');
    } catch (e) {
      print('⚠️ Gagal hapus cache: $e');
    }

    return Todo(id: id, title: newTitle, isCompleted: newStatus);
  }

  // 5. DELETE
  Future<bool> deleteTodo(String id) async {
    final result = await _db.postgres.execute(
      Sql.named('DELETE FROM todos WHERE id = @id'),
      parameters: {'id': id},
    );

    try {
      await _db.redisCommand.send_object(['DEL', 'todos:all']);
      print('🧹 Redis Cache Cleared');
    } catch (e) {
      print('⚠️ Gagal hapus cache: $e');
    }

    // affectedRows memberi tahu berapa baris yang terhapus
    return result.affectedRows > 0;
  }
}
