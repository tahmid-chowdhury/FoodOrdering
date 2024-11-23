import 'package:flutter/material.dart';
import 'database_helper.dart';

class OrderPlanScreen extends StatefulWidget {
  const OrderPlanScreen({Key? key}) : super(key: key);

  @override
  State<OrderPlanScreen> createState() => _OrderPlanScreenState();
}

class _OrderPlanScreenState extends State<OrderPlanScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final TextEditingController _targetCostController = TextEditingController();
  DateTime? _selectedDate;

  List<Map<String, dynamic>> foodItems = [];
  List<Map<String, dynamic>> selectedItems = [];
  double currentCost = 0.0;
  double? targetCost;

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

  void _removeFromCart(Map<String, dynamic> item) {
    setState(() {
      selectedItems.remove(item);
      currentCost -= item['cost'];
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Set Target Cost
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
          // Pick Date
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  _selectedDate != null
                      ? 'Selected Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'
                      : 'No Date Selected',
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text('Pick Date'),
                ),
              ],
            ),
          ),
          // Remaining Budget
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Remaining Budget: \$${targetCost != null ? (targetCost! - currentCost).toStringAsFixed(2) : 'N/A'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // Food Items List
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                final isInCart = selectedItems.contains(item);
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('Cost: \$${item['cost']}'),
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
          // Cart Preview
          const Divider(),
          const Text(
            'Cart Preview:',
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
          // Save Order Button
          ElevatedButton(
            onPressed: _saveOrderPlan,
            child: const Text('Save Order Plan'),
          ),
        ],
      ),
    );
  }
}
