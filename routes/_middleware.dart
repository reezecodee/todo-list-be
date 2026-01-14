import 'package:dart_frog/dart_frog.dart';
import '../lib/database/db_connection.dart';

AppDatabase? _db;

Handler middleware(Handler handler) {
  return (context) async {
    if (_db == null) {
      _db = AppDatabase();
      await _db!.init();
      print('✅ Database & Redis Connected!');
    }

    final response = await handler
        .use(provider<AppDatabase>((_) => _db!))
        .call(context);

    return response;
  };
}