import 'package:dart_frog/dart_frog.dart';
import 'package:todo_backend/database/db_connection.dart';
import 'package:todo_backend/services/todo_service.dart';

final _db = AppDatabase();
final _todoService = TodoService(_db);

Handler middleware(Handler handler) {
  // Urutan: Logger -> Inject DB -> Inject Service -> Handler Asli
  final handlerWithDependencies = handler
      .use(requestLogger())
      .use(provider<AppDatabase>((_) => _db))
      .use(provider<TodoService>((_) => _todoService));

  return (context) async {
    await _db.init();

    return handlerWithDependencies(context);
  };
}
