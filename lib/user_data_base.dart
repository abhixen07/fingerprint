import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserDatabaseHelper {
  static final UserDatabaseHelper _instance = UserDatabaseHelper._internal();
  factory UserDatabaseHelper() => _instance;
  UserDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, user_id TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<int> insertUser(String userId) async {
    final db = await database;
    return await db.insert('users', {'user_id': userId});
  }

  Future<List<Map<String, dynamic>>> getUser(String userId) async {
    final db = await database;
    return await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
