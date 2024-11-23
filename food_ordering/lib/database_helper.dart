import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "FoodOrder.db";
  static final _databaseVersion = 1;

  static final foodTable = 'food';
  static final orderTable = 'orders';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $foodTable (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        cost REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $orderTable (
        id INTEGER PRIMARY KEY,
        date TEXT NOT NULL,
        items TEXT NOT NULL,
        totalCost REAL NOT NULL
      )
    ''');
  }

  Future<int> insertFood(String name, double cost) async {
    Database db = await database;
    return await db.insert(foodTable, {'name': name, 'cost': cost});
  }

  Future<List<Map<String, dynamic>>> fetchFoodItems() async {
    Database db = await database;
    return await db.query(foodTable);
  }

  Future<int> insertOrder(String date, String items, double totalCost) async {
    Database db = await database;
    return await db.insert(orderTable, {'date': date, 'items': items, 'totalCost': totalCost});
  }

  Future<List<Map<String, dynamic>>> fetchOrderByDate(String date) async {
    Database db = await database;
    return await db.query(orderTable, where: 'date = ?', whereArgs: [date]);
  }
}
