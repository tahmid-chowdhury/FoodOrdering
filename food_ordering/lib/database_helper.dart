/* SOFE 4640U: Mobile Application Development
 * Assignment #3: App Development using Flutter
 * Tahmid Chowdhury
 * Faculty of Engineering and Applied Science
 * Ontario Tech University
 * Oshawa, Ontario
 * tahmid.chowdhury1@ontariotechu.net
 * SID: 100822671
 * 2024-11-27
 */

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Database helper class
class DatabaseHelper {
  static final _databaseName = "FoodOrder.db";
  static final _databaseVersion = 1;

  static final foodTable = 'food';
  static final orderTable = 'orders';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  // Get the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // Create the database
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

  // Insert a food item
  Future<int> insertFood(String name, double cost) async {
    Database db = await database;
    return await db.insert(foodTable, {'name': name, 'cost': cost});
  }

  // Fetch all food items
  Future<List<Map<String, dynamic>>> fetchFoodItems() async {
    Database db = await database;
    return await db.query(foodTable);
  }

  // Insert an order
  Future<int> insertOrder(String date, String items, double totalCost) async {
    Database db = await database;
    return await db.insert(orderTable, {'date': date, 'items': items, 'totalCost': totalCost});
  }

  // Fetch orders
  Future<List<Map<String, dynamic>>> fetchOrderByDate(String date) async {
    Database db = await database;
    return await db.query(orderTable, where: 'date = ?', whereArgs: [date]);
  }

  // Delete an orders
  Future<void> deleteOrder(int id) async {
    final db = await _database;
    await db!.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update an order
  Future<void> updateOrder(int id, String updatedItems) async {
    final db = await database;
    await db.update(
      'orders',
      {'items': updatedItems},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
