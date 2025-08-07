import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/logged_food.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'meals.db');

    return openDatabase(
      path,
      version: 4, // <-- increase this number
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal TEXT,
        name TEXT,
        amount REAL,
        kcal REAL,
        protein REAL,
        carbs REAL,
        fat REAL,
        date TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Check if 'timestamp' column exists first
      final columns = await db.rawQuery("PRAGMA table_info(meals)");
      final hasTimestamp = columns.any((column) => column['name'] == 'timestamp');

      if (!hasTimestamp) {
        await db.execute('ALTER TABLE meals ADD COLUMN timestamp TEXT');
      }
    }

    if (oldVersion < 3) {
      final columns = await db.rawQuery("PRAGMA table_info(meals)");
      final hasUnit = columns.any((column) => column['name'] == 'unit');

      if (!hasUnit) {
        await db.execute('ALTER TABLE meals ADD COLUMN unit TEXT DEFAULT "g"');
      }
    }

    final columns = await db.rawQuery("PRAGMA table_info(meals)");
    final hasDate = columns.any((column) => column['name'] == 'date');
    if (!hasDate) {
      await db.execute('ALTER TABLE meals ADD COLUMN date TEXT');
    }
  }

  Future<int> insertFood(String meal, LoggedFood food) async {
    final db = await database;
    return await db.insert('meals', {
      'meal': meal,
      'name': food.name,
      'amount': food.amount,
      'unit': food.unit,
      'kcal': food.kcal,
      'protein': food.protein,
      'carbs': food.carbs,
      'fat': food.fat,
      'date': food.date.toIso8601String(), // <-- store the date
    });
  }

  Future<int> deleteFood(int id) async {
    final db = await database;
    return await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LoggedFood>> fetchFoodsByMeal(String meal) async {
    final db = await database;
    final maps = await db.query('meals', where: 'meal = ?', whereArgs: [meal]);

    return maps.map((map) => LoggedFood.fromMap(map)).toList(); // <-- use fromMap
  }

  Future<List<LoggedFood>> fetchFoodsByMealAndDate(String meal, DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().substring(0, 10); // 'YYYY-MM-DD'
    final maps = await db.query(
      'meals',
      where: 'meal = ? AND date LIKE ?',
      whereArgs: [meal, '$dateString%'],
    );
    return maps.map((map) => LoggedFood.fromMap(map)).toList();
  }
}
