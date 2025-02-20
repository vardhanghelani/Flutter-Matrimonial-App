import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'matrimonial.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            """
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              email TEXT UNIQUE,
              password TEXT,
              mobile TEXT,
              dob TEXT,
              gender TEXT,
              city TEXT,
              hobbies TEXT,
              isFavorite INTEGER
            )
            """,
          );
        },
      );
    } catch (e) {
      print("Error initializing database: $e");
      throw Exception("Database initialization failed");
    }
  }

  // **1️⃣ Insert a new user into the database**
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // **2️⃣ Get all users from the database**
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // **3️⃣ Get a user by email (for login)**
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // **4️⃣ Update user details**
  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  // **5️⃣ Delete a user from the database**
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // **6️⃣ Toggle favorite status**
  Future<void> toggleFavorite(int id, int isFavorite) async {
    final db = await database;
    await db.update(
      'users',
      {'isFavorite': isFavorite == 1 ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
