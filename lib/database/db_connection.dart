import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';

class AppDatabase {
  late Connection postgres;
  late Command redisCommand;

  Future<void> init() async {
    postgres = await Connection.open(
      Endpoint(
        host: Platform.environment['DB_HOST'] ?? 'localhost',
        database: Platform.environment['DB_NAME'] ?? 'postgres',
        username: Platform.environment['DB_USER'] ?? 'postgres',
        password: Platform.environment['DB_PASSWORD'] ?? 'password',
        port: int.parse(Platform.environment['DB_PORT'] ?? '5432'),
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );

    final redisConn = RedisConnection();
    final redisHost = Platform.environment['REDIS_HOST'] ?? 'localhost';
    final redisPort = int.parse(Platform.environment['REDIS_PORT'] ?? '6379');

    redisCommand = await redisConn.connect(redisHost, redisPort);
  }
}
