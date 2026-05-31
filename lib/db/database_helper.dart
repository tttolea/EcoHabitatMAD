import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, 'ecohabitat_history.db');
      print("📂 [Database Init] Opening database path: $path");

      return await openDatabase(
        path,
        onCreate: (db, version) async {
          print("🔨 [Database Init] Creating logs table for the first time...");
          await db.execute('''
            CREATE TABLE logs(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              timestamp TEXT,
              latitude REAL,
              longitude REAL,
              condition TEXT
            )
          ''');
        },
        version: 1,
      );
    } catch (e) {
      print("❌ [Database Error] Failed to initialize database: $e");
      rethrow;
    }
  }

  Future<void> insertLog(double lat, double lng, String condition) async {
    try {
      final db = await database;
      int id = await db.insert('logs', {
        'timestamp': DateTime.now().toIso8601String(),
        'latitude': lat,
        'longitude': lng,
        'condition': condition,
      });
      print("💾 [Database Success] Inserted row ID #$id: $condition");
    } catch (e) {
      print("❌ [Database Error] Failed to insert row: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getHistoryLogs() async {
    try {
      final db = await database;
      final results = await db.query('logs', orderBy: 'id DESC');
      print("📊 [Database Fetch] Successfully retrieved ${results.length} rows from local storage.");
      return results;
    } catch (e) {
      print("❌ [Database Error] Failed to query rows: $e");
      return [];
    }
  }

  Future<void> clearLogs() async {
    try {
      final db = await database;
      int count = await db.delete('logs');
      print("🗑️ [Database Clear] Wiped $count rows from logs table.");
    } catch (e) {
      print("❌ [Database Error] Failed to clear logs: $e");
    }
  }
}