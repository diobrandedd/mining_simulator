import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDb('game_users.db');
      return _database!;
    }
  }

  Future<Database> _initDb(String dbName) async {
    final dbDir = await getDatabasesPath();
    final path = join(dbDir, dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) {
        db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            email TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await instance.database;
    return await db.insert('users', user);
  }

  Future<bool> emailExist(String email) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result =
    await db.query('users', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty;
  }

  Future<int?> userLogin(String email, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db
        .query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (result.isNotEmpty) {
      return result.first['id'] as int;
    } else {
      return null;
    }
  }
  Future<Map<String, dynamic>?> getUserById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

    Future<int> updateUser(int id, Map<String, dynamic> updates) async {
      Database db = await instance.database;
      return await db.update('users', updates, where: 'id = ?', whereArgs: [id]);
    }


}
