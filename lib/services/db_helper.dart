import 'package:hedieaty/models/app_user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'hedieaty.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users(id TEXT PRIMARY KEY, email TEXT, name TEXT)',
        );
      },
      version: 1,
    );
    return _db!;
  }

  static Future<void> saveUser(AppUser user) async {
    final db = await getDatabase();
    await db.insert(
      'users',
      user.toSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<AppUser?> getUser() async {
    final db = await getDatabase();
    final result = await db.query('users', limit: 1);
    if (result.isNotEmpty) {
      return AppUser.fromSQLite(result.first);
    }
    return null;
  }

  static Future<void> deleteUser() async {
    final db = await getDatabase();
    await db.delete('users');
  }
}
