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
      version: 1,
      onCreate: _onCreate,
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
        timestamp TEXT
      )
    ''');
  }

  Future<int> insertFood(String meal, LoggedFood food) async {
    final db = await database;
    return await db.insert('meals', {
      'meal': meal,
      'name': food.name,
      'amount': food.amount,
      'kcal': food.kcal,
      'protein': food.protein,
      'carbs': food.carbs,
      'fat': food.fat,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<LoggedFood>> fetchFoodsByMeal(String meal) async {
    final db = await database;
    final maps = await db.query('meals', where: 'meal = ?', whereArgs: [meal]);

    return maps.map((map) => LoggedFood(
      name: map['name'] as String,
      amount: map['amount'] as double,
      kcal: map['kcal'] as double,
      protein: map['protein'] as double,
      carbs: map['carbs'] as double,
      fat: map['fat'] as double,
    )).toList();
  }
}
