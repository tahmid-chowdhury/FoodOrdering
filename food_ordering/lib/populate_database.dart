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

import 'database_helper.dart';

// Populate database class
class PopulateDatabase {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  // Populate the database with food items
  Future<void> populateFoodItems() async {
    final List<Map<String, dynamic>> existingItems = await dbHelper.fetchFoodItems();
    if (existingItems.isNotEmpty) {
      // Database already has food items
      return;
    }

    final List<Map<String, dynamic>> foodItems = [
      {'name': 'Pizza', 'cost': 8.99},
      {'name': 'Burger', 'cost': 5.49},
      {'name': 'Sushi', 'cost': 12.99},
      {'name': 'Pasta', 'cost': 7.49},
      {'name': 'Salad', 'cost': 4.99},
      {'name': 'Tacos', 'cost': 3.99},
      {'name': 'Steak', 'cost': 15.99},
      {'name': 'Fried Chicken', 'cost': 6.99},
      {'name': 'Ice Cream', 'cost': 2.99},
      {'name': 'Sandwich', 'cost': 4.49},
      {'name': 'Noodles', 'cost': 5.99},
      {'name': 'Soup', 'cost': 3.49},
      {'name': 'Curry', 'cost': 8.49},
      {'name': 'Fries', 'cost': 2.49},
      {'name': 'Donut', 'cost': 1.99},
      {'name': 'Hot Dog', 'cost': 3.49},
      {'name': 'Grilled Cheese', 'cost': 4.99},
      {'name': 'Smoothie', 'cost': 5.49},
      {'name': 'Pancakes', 'cost': 6.99},
      {'name': 'Waffles', 'cost': 7.49},
    ];

    for (var item in foodItems) {
      await dbHelper.insertFood(item['name'], item['cost']);
    }
  }
}
