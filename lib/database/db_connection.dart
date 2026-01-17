import 'package:postgres/postgres.dart';
import 'package:redis/redis.dart';
import 'package:dotenv/dotenv.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  Connection? _postgres;
  Command? _redisCommand;

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal();

  Connection get postgres {
    if (_postgres == null)
      throw Exception('Database belum terkoneksi! Panggil init() dulu.');
    return _postgres!;
  }

  Command get redisCommand {
    if (_redisCommand == null)
      throw Exception('Redis belum terkoneksi! Panggil init() dulu.');
    return _redisCommand!;
  }

  Future<void> init() async {
    if (_postgres != null && _redisCommand != null) return;

    print('🔄 Loading .env and Connecting to Databases...');

    var env = DotEnv(includePlatformEnvironment: true)..load();

    final dbHost = env['DB_HOST'] ?? 'localhost';
    final dbName = env['DB_NAME'] ?? 'dart_todo_db';
    final dbUser = env['DB_USER'] ?? 'postgres';
    final dbPass = env['DB_PASSWORD'] ?? 'password';

    // Setup Postgres
    _postgres = await Connection.open(
      Endpoint(
        host: dbHost,
        database: dbName,
        username: dbUser,
        password: dbPass, 
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );

    // Setup Redis
    final redisConn = RedisConnection();
    _redisCommand = await redisConn.connect(dbHost, 6379);

    print('✅ Database Connected via .env configuration!');
  }
}
