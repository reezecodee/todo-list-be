import 'package:dart_frog/dart_frog.dart';
import '../lib/database/db_connection.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();

  try {
    final pgResult = await db.postgres.execute('SELECT 1');
    final pgStatus = pgResult.isNotEmpty ? 'OK' : 'Error';

    await db.redisCommand.send_object(['SET', 'test_key', 'Hello Redis']);
    final redisVal = await db.redisCommand.send_object(['GET', 'test_key']);
    final redisStatus = redisVal == 'Hello Redis' ? 'OK' : 'Error';

    return Response.json(body: {
      'status': 'Server Running',
      'checks': {
        'postgres': pgStatus,
        'redis': redisStatus,
      },
      'message': 'Backend Dart is ready to rock! 🚀'
    });
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'status': 'Error', 'error': e.toString()},
    );
  }
}
