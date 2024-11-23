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
  final TextEditingController _dateController = TextEditingController();

  List<Map<String, dynamic>> foodItems = [];
  List<Map<String, dynamic>> selectedItems = [];
  double currentCost = 0.0;

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

  void _toggleSelection(Map<String, dynamic> item) {
    final isSelected = selectedItems.contains(item);
    final itemCost = item['cost'];

    if (isSelected) {
      setState(() {
        selectedItems.remove(item);
        currentCost -= itemCost;
      });
    } else if (currentCost + itemCost <= (double.tryParse(_targetCostController.text) ?? 0.0)) {
      setState(() {
        selectedItems.add(item);
        currentCost += itemCost;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot exceed target cost')),
      );
    }
  }

  void _saveOrderPlan() async {
    final date = _dateController.text;
    if (date.isNotEmpty && selectedItems.isNotEmpty) {
      final items = selectedItems.map((item) => item['name']).join(', ');
      await dbHelper.insertOrder(date, items, currentCost);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order saved successfully')),
      );
      setState(() {
        selectedItems.clear();
        currentCost = 0.0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select items and set a date')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _targetCostController,
              decoration: const InputDecoration(
                labelText: 'Target Cost',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                final isSelected = selectedItems.contains(item);
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('Cost: \$${item['cost']}'),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(item),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _saveOrderPlan,
            child: const Text('Save Order Plan'),
          ),
        ],
      ),
    );
  }
}
