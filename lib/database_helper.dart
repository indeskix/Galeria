import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database _database; // Usunięto ?

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDB('gallery.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        profile_picture TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        image_url TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        image_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (image_id) REFERENCES images(id)
      );
    ''');
  }

  Future<int> insertUser(String username, String password) async {
    final db = await database;
    return await db.insert('users', {'username': username, 'password': password});
  }

  Future<Map<String, dynamic>> getUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getImages() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('images');
    print("📸 Zdjęcia w bazie: $result");
    return result;
  }

  Future<List<int>> getFavorites(int userId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.map((e) => e['image_id'] as int).toList() : [];
  }

  Future<void> toggleFavorite(int userId, int imageId) async {
    final db = await database;
    final exists = await db.query(
      'favorites',
      where: 'user_id = ? AND image_id = ?',
      whereArgs: [userId, imageId],
    );

    if (exists.isNotEmpty) {
      await db.delete(
        'favorites',
        where: 'user_id = ? AND image_id = ?',
        whereArgs: [userId, imageId],
      );
    } else {
      await db.insert('favorites', {'user_id': userId, 'image_id': imageId});
    }
  }

  Future<Map<String, dynamic>> getLoggedInUser() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> logoutUser() async {
  }

  Future<void> insertLocalImages() async {
    final db = await database;

    await db.delete('images');

    List<String> imagePaths = [
      'assets/img/1.jpg',
      'assets/img/2.jpg',
      'assets/img/3.jpg',
      'assets/img/4.jpg',
      'assets/img/5.jpg',
      'assets/img/6.jpg',
      'assets/img/7.jpg',
      'assets/img/8.jpg',
      'assets/img/9.jpg',
      'assets/img/10.jpg',
      'assets/img/11.jpg',
      'assets/img/12.jpg',
      'assets/img/13.jpg',
      'assets/img/14.jpg',
    ];

    for (String path in imagePaths) {
      await db.insert('images', {'image_url': path});
    }
  }

  Future<Map<String, dynamic>> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateUserProfile(int userId, String username, String password, String profilePicture) async {
    final db = await database;
    Map<String, dynamic> updateData = {'username': username};
    if (password != null && password.isNotEmpty) {
      updateData['password'] = password;
    }
    if (profilePicture != null) {
      updateData['profile_picture'] = profilePicture;
    }
    await db.update('users', updateData, where: 'id = ?', whereArgs: [userId]);
  }

  Future<void> insertImage(String imagePath) async {
    final db = await database;
    await db.insert('images', {'image_url': imagePath});
  }
}
