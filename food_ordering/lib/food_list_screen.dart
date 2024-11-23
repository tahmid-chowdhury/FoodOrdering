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

import 'package:flutter/material.dart';
import 'database_helper.dart';

// Food list screen widget
class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

// State for the food list screen
class _FoodListScreenState extends State<FoodListScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  List<Map<String, dynamic>> foodItems = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  // Initialize the state
  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  // Fetch food items from the database
  void _fetchFoodItems() async {
    final items = await dbHelper.fetchFoodItems();
    setState(() {
      foodItems = items;
    });
  }

  // Add or update a food item
  void _addOrUpdateFoodItem({Map<String, dynamic>? item}) async {
    final isUpdate = item != null;

    _nameController.text = isUpdate ? item['name'] : '';
    _costController.text = isUpdate ? item['cost'].toString() : '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isUpdate ? 'Update Food Item' : 'Add Food Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Food Name'),
              ),
              TextField(
                controller: _costController,
                decoration: const InputDecoration(hintText: 'Cost'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = _nameController.text;
                final cost = double.tryParse(_costController.text);
                if (name.isNotEmpty && cost != null) {
                  if (isUpdate) {
                    final db = await dbHelper.database;
                    await db.update(
                      DatabaseHelper.foodTable,
                      {'name': name, 'cost': cost},
                      where: 'id = ?',
                      whereArgs: [item['id']],
                    );
                  } else {
                    await dbHelper.insertFood(name, cost);
                  }
                  Navigator.pop(context);
                  _fetchFoodItems();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Delete a food item
  void _deleteFoodItem(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      DatabaseHelper.foodTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchFoodItems();
  }

  // Build the food list screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _addOrUpdateFoodItem(),
            child: const Text('Add Food Item'),
            style: ElevatedButton.styleFrom(
              textStyle: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                return ListTile(
                  title: Text(item['name'], style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text('Cost: \$${item['cost']}', style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _addOrUpdateFoodItem(item: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFoodItem(item['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
