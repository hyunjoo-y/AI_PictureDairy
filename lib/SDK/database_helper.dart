import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// 데이터 모델 정의
class ImageData {
  final int? id;
  final String image;
  final String text;
  final String date;

  ImageData(
      {this.id, required this.image, required this.text, required this.date});

  // 데이터베이스에서 사용하기 위한 맵 형식 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'text': text,
      'date': date,
    };
  }
}

class UserData {
  final String name;
  final String birthdate;

  UserData({required this.name, required this.birthdate});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthdate': birthdate,
    };
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'images_database.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT, image TEXT, text TEXT, date TEXT)',
        );
        db.execute(
          'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, birthdate TEXT)',
        );
      },
      version: 2, 
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute(
            'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, birthdate TEXT)',
          );
        }
      },
    );
  }

  Future<void> insertImageData(ImageData imageData) async {
    final db = await database;
    await db.insert(
      'images',
      imageData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertUserData(UserData userData) async {
    final db = await database;
    await db.delete('users');
    await db.insert(
      'users',
      userData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("저장완료 ${userData}");
  }

  Future<UserData?> fetchUserData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    if (maps.isNotEmpty) {
      return UserData(
        name: maps.first['name'],
        birthdate: maps.first['birthdate'],
      );
    } else {
      return null;
    }
  }

  Future<List<ImageData>> fetchAllImageData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('images');

    return List.generate(maps.length, (i) {
      return ImageData(
        id: maps[i]['id'],
        image: maps[i]['image'],
        text: maps[i]['text'],
        date: maps[i]['date'],
      );
    });
  }

  Future<void> deleteImageData(int id) async {
    final db = await database;
    await db.delete(
      'images',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateImageData(ImageData imageData) async {
    final db = await database;
    await db.update(
      'images',
      imageData.toMap(),
      where: 'id = ?',
      whereArgs: [imageData.id],
    );
  }
}
