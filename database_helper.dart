import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      print('Database already initialized.');
      return _database!;
    } else {
      print('Initializing database...');
      _database = await _initDb('game_users.db');
      return _database!;
    }
  }

  Future<Database> _initDb(String dbName) async {
    final dbDir = await getDatabasesPath();
    final path = join(dbDir, dbName);
    print('Database path: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) {
        print('Creating tables...');
        db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            email TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        db.execute('''
          CREATE TABLE progress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            gold INTEGER DEFAULT 0,
            inventory TEXT DEFAULT '',
            tools TEXT DEFAULT '',
            FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');
        print('Tables created successfully.');
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await instance.database;
    print('Inserting user: $user');
    final userId = await db.insert('users', user);

    // Initialize progress for the user
    print('Initializing progress for user ID: $userId');
    await db.insert('progress', {
      'user_id': userId,
      'gold': 0,
      'inventory': '',
      'tools': ''
    });

    return userId;
  }

  Future<bool> emailExist(String email) async {
    Database db = await instance.database;
    print('Checking if email exists: $email');
    List<Map<String, dynamic>> result =
    await db.query('users', where: 'email = ?', whereArgs: [email]);
    print('Email existence check result: ${result.isNotEmpty}');
    return result.isNotEmpty;
  }

  Future<int?> userLogin(String email, String password) async {
    Database db = await instance.database;
    print('Attempting login for email: $email');
    List<Map<String, dynamic>> result = await db.query('users',
        where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (result.isNotEmpty) {
      print('Login successful for user ID: ${result.first['id']}');
      return result.first['id'] as int;
    } else {
      print('Login failed.');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }


  Future<int> updateUser(int id, Map<String, dynamic> updates) async {
    Database db = await instance.database;
    print('Updating user ID: $id with updates: $updates');
    return await db.update('users', updates, where: 'id = ?', whereArgs: [id]);
  }

  // Progress-related methods
  Future<Map<String, dynamic>?> getProgressByUserId(int userId) async {
    Database db = await instance.database;
    print('Fetching progress for user ID: $userId');
    List<Map<String, dynamic>> result =
    await db.query('progress', where: 'user_id = ?', whereArgs: [userId]);
    print('Progress fetch result: ${result.isNotEmpty ? result.first : null}');
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateProgress(int userId, Map<String, dynamic> progress) async {
    Database db = await instance.database;
    print('Updating progress for user ID: $userId with data: $progress');
    return await db.update('progress', progress,
        where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> resetProgress(int userId) async {
    Database db = await instance.database;
    print('Resetting progress for user ID: $userId');
    return await db.update('progress', {
      'gold': 0,
      'inventory': '',
      'tools': ''
    }, where: 'user_id = ?', whereArgs: [userId]);
  }
}
