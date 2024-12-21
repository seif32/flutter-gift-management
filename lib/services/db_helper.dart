import 'package:hedieaty/models/event.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _db;

  // Schema for Events and Gifts tables
  static Future<void> createTables(Database db) async {
    await db.execute(
      'CREATE TABLE users(id TEXT PRIMARY KEY, email TEXT, name TEXT,phone TEXT)',
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
  pledgerId TEXT,
  FOREIGN KEY (eventId) REFERENCES events(id) ON DELETE CASCADE,
  FOREIGN KEY (pledgerId) REFERENCES users(id) ON DELETE SET NULL
)
''');

    await db.execute('''
CREATE TABLE friends (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    friend_id TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (friend_id) REFERENCES users (id)
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

  // ######################################## Events Table ########################################

  // Save Event
  static Future<void> saveEvent(Event event) async {
    final db = await getDatabase();

    await db.insert(
      'events',
      event.toSQLite(),
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

  static Future<List<Event>> getEventsByUser(String userId) async {
    final db = await getDatabase();

    final result = await db.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return result.map((event) => Event.fromSQLite(event)).toList();
  }

  // Delete an event
  static Future<void> deleteEvent(String eventId) async {
    final db = await getDatabase();

    await db.delete(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );

    await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  // ######################################## Gifts Table ########################################

// Save Gift
  static Future<void> saveGift(Gift gift) async {
    final db = await getDatabase();

    await db.insert(
      'gifts',
      gift.toSQLite(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update an existing gift
  static Future<void> updateGift(Gift gift) async {
    final db = await getDatabase();

    await db.update(
      'gifts',
      gift.toSQLite(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  // Delete a gift by its ID
  static Future<void> deleteGift(String giftId) async {
    final db = await getDatabase();

    await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }

  static Future<void> updateGiftStatus(
      String giftId, String status, String pledgerId) async {
    final db = await getDatabase();

    await db.update(
      'gifts',
      {'status': status, 'pledgerId': pledgerId},
      where: 'id = ?',
      whereArgs: [giftId],
    );
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

  // ######################################## Friends Table ########################################

  static Future<void> addFriend(String userId, String friendId) async {
    final db = await getDatabase();

    await db.insert(
      'friends',
      {'user_id': userId, 'friend_id': friendId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    await db.insert(
      'friends',
      {'user_id': friendId, 'friend_id': userId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}
