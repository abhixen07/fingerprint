// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._init();
//   static Database? _database;
//
//   DatabaseHelper._init();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('auth_database.db');
//     return _database!;
//   }
//
//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);
//
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _createDB,
//     );
//   }
//
//   Future _createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE auth_status (
//         id INTEGER PRIMARY KEY,
//         is_authenticated TEXT
//       )
//     ''');
//   }
//
//   Future<void> setAuthStatus(bool isAuthenticated) async {
//     final db = await instance.database;
//     await db.delete('auth_status');
//     await db.insert('auth_status', {'is_authenticated': isAuthenticated ? 'true' : 'false'});
//   }
//
//   Future<bool> getAuthStatus() async {
//     final db = await instance.database;
//     final result = await db.query('auth_status', limit: 1);
//     return result.isNotEmpty && result.first['is_authenticated'] == 'true';
//   }
//
//   Future<void> clearAuthStatus() async {
//     final db = await instance.database;
//     await db.delete('auth_status');
//   }
//
//   Future close() async {
//     final db = await DatabaseHelper._database;
//     if (db != null) {
//       await db.close();
//     }
//   }
// }
