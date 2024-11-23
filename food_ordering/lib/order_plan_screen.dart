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

// Order plan screen widget
class OrderPlanScreen extends StatefulWidget {
  const OrderPlanScreen({Key? key}) : super(key: key);

  @override
  State<OrderPlanScreen> createState() => _OrderPlanScreenState();
}

// Order plan screen state
class _OrderPlanScreenState extends State<OrderPlanScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final TextEditingController _targetCostController = TextEditingController();
  DateTime? _selectedDate;

  List<Map<String, dynamic>> foodItems = [];
  List<Map<String, dynamic>> selectedItems = [];
  double currentCost = 0.0;
  double? targetCost;

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

  // Pick a date for the order plan
  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Add an item to the cart
  void _addToCart(Map<String, dynamic> item) {
    if (targetCost == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set target cost and select a date first')),
      );
      return;
    }

    final itemCost = item['cost'];

    if (currentCost + itemCost <= targetCost!) {
      setState(() {
        selectedItems.add(item);
        currentCost += itemCost;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adding this item exceeds your budget')),
      );
    }
  }

  // Remove an item from the cart
  void _removeFromCart(Map<String, dynamic> item) {
    setState(() {
      selectedItems.remove(item);
      currentCost -= item['cost'];
    });
  }

  // Save the order plan
  void _saveOrderPlan() async {
    if (targetCost == null || _selectedDate == null || selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set all fields and add items to cart')),
      );
      return;
    }

    final items = selectedItems.map((item) => item['name']).join(', ');
    await dbHelper.insertOrder(
      _selectedDate!.toIso8601String().split('T')[0],
      items,
      currentCost,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order saved successfully')),
    );

    setState(() {
      selectedItems.clear();
      currentCost = 0.0;
    });
  }

  // Build the order plan screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Set the target cost for the order plan
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _targetCostController,
              decoration: const InputDecoration(
                labelText: 'Target Cost',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                final cost = double.tryParse(value);
                if (cost != null) {
                  setState(() {
                    targetCost = cost;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid number')),
                  );
                }
              },
            ),
          ),
          // Select a date for the order plan
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  _selectedDate != null
                      ? 'Selected Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'
                      : 'No Date Selected',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Pick Date'),
                  style: ElevatedButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          // Display the remaining budget
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Remaining Budget: \$${targetCost != null ? (targetCost! - currentCost).toStringAsFixed(2) : '0.00'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          // Display the food items
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                final isInCart = selectedItems.contains(item);
                return ListTile(
                  title: Text(item['name'], style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text('Cost: \$${item['cost']}', style: Theme.of(context).textTheme.bodyMedium),
                  trailing: isInCart
                      ? IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () => _removeFromCart(item),
                        )
                      : IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () => _addToCart(item),
                        ),
                );
              },
            ),
          ),
          // Display the order preview
          const Divider(),
          const Text(
            'Order Preview:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedItems.length,
              itemBuilder: (context, index) {
                final item = selectedItems[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('Cost: \$${item['cost']}'),
                );
              },
            ),
          ),
          // Save the order plan
          ElevatedButton(
            onPressed: _saveOrderPlan,
            child: const Text('Save Order Plan'),
            style: ElevatedButton.styleFrom(
              textStyle: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
