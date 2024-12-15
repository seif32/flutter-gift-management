import 'package:hedieaty/models/app_user.dart';
import 'package:hedieaty/models/event.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _db;

  // Schema for Events and Gifts tables
  static Future<void> createTables(Database db) async {
    await db.execute(
      'CREATE TABLE users(id TEXT PRIMARY KEY, email TEXT, name TEXT)',
    );
    await db.execute('''
  CREATE TABLE events(
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    date TEXT NOT NULL,
    location TEXT,
    description TEXT,
    userId TEXT NOT NULL,
    isPublished INTEGER NOT NULL DEFAULT 0
  )
''');

    await db.execute('''
    CREATE TABLE gifts(
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      category TEXT,
      price REAL NOT NULL,
      status TEXT,
      eventId TEXT NOT NULL,
      FOREIGN KEY (eventId) REFERENCES events(id) ON DELETE CASCADE
    )
    ''');
  }

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'hedieaty.db'),
      onCreate: (db, version) async {
        await createTables(db);
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

  static Future<AppUser?> getUserById(String userId) async {
    final db = await getDatabase();

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return AppUser.fromSQLite(result.first);
    }
    return null;
  }

  static Future<void> deleteUser() async {
    final db = await getDatabase();
    await db.delete('users');
  }

  // Save Event
  static Future<void> saveEvent(Event event) async {
    final db = await getDatabase();

    await db.insert(
      'events',
      event.toSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateEvent(Event event) async {
    final db = await getDatabase();
    await db.update(
      'events',
      event.toSQLite(), // Convert the Event to SQLite format
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

// Save Gift
  static Future<void> saveGift(Gift gift) async {
    final db = await getDatabase();

    await db.insert(
      'gifts',
      gift.toSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Get Events for a User
  static Future<List<Event>> getUserEvents(String userId) async {
    final db = await getDatabase();

    final eventsData = await db.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return eventsData.map((e) => Event.fromSQLite(e)).toList();
  }

  static Future<Event?> getEventById(String eventId) async {
    final db = await getDatabase();

    final result = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [eventId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Event.fromSQLite(result.first);
    }
    return null;
  }

// Get Gifts for an Event
  static Future<List<Gift>> getGiftsForEvent(String eventId) async {
    final db = await getDatabase();

    final giftsData = await db.query(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );

    return giftsData.map((g) => Gift.fromSQLite(g)).toList();
  }
}
