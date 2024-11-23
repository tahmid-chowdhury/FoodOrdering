import 'package:flutter/material.dart';
import 'database_helper.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  List<Map<String, dynamic>> foodItems = [];

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  void _fetchFoodItems() async {
    final items = await dbHelper.fetchFoodItems();
    setState(() {
      foodItems = items;
    });
  }

  void _addFoodItem() async {
    final name = _nameController.text;
    final cost = double.tryParse(_costController.text);
    if (name.isNotEmpty && cost != null) {
      await dbHelper.insertFood(name, cost);
      _fetchFoodItems();
      _nameController.clear();
      _costController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Food Name'),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _costController,
                    decoration: const InputDecoration(hintText: 'Cost'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addFoodItem,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('Cost: \$${item['cost']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
