import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/subscriber.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'subscribers.db');
    return openDatabase(
      path,
      version: 8,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE subscribers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        subscriptionStartDate TEXT,
        price REAL,
        isPaid INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 8) {
      // In a real app, you'd add specific ALTER TABLE statements for each version upgrade.
      if (oldVersion < 7) {
        await db.execute('DROP TABLE IF EXISTS subscribers');
        await _onCreate(db, newVersion);
      }
    }
  }

  Future<int> insertSubscriber(Subscriber subscriber) async {
    final db = await database;
    return db.insert('subscribers', subscriber.toMap());
  }

  Future<List<Subscriber>> getSubscribers({String? query}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    String? where;
    List<dynamic>? whereArgs;

    if (query != null && query.isNotEmpty) {
      where = 'name LIKE ? OR phone LIKE ?';
      whereArgs = ['%$query%', '%$query%'];
    }

    maps = await db.query(
      'subscribers',
      where: where,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) => Subscriber.fromMap(maps[i]));
  }

  Future<List<Subscriber>> getAllSubscribers() async {
    final db = await database;
    final maps = await db.query('subscribers');
    return List.generate(maps.length, (i) => Subscriber.fromMap(maps[i]));
  }

  Future<int> deleteAllSubscribers() async {
    final db = await database;
    return db.delete('subscribers');
  }

  Future<int> updateSubscriber(Subscriber subscriber) async {
    final db = await database;
    return db.update(
      'subscribers',
      subscriber.toMap(),
      where: 'id = ?',
      whereArgs: [subscriber.id],
    );
  }

  Future<int> deleteSubscriber(int id) async {
    final db = await database;
    return db.delete(
      'subscribers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
