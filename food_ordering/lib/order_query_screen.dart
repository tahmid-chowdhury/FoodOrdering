import 'package:flutter/material.dart';
import 'database_helper.dart';

class OrderQueryScreen extends StatefulWidget {
  const OrderQueryScreen({Key? key}) : super(key: key);

  @override
  State<OrderQueryScreen> createState() => _OrderQueryScreenState();
}

class _OrderQueryScreenState extends State<OrderQueryScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  DateTime? _selectedDate;
  Map<String, dynamic>? orderPlan;

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
      _fetchOrderPlan();
    }
  }

  void _fetchOrderPlan() async {
    if (_selectedDate == null) return;

    final dateString = _selectedDate!.toIso8601String().split('T')[0];
    final result = await dbHelper.fetchOrderByDate(dateString);

    setState(() {
      orderPlan = result.isNotEmpty ? result.first : null;
    });
  }

  void _updateOrderPlan() async {
    if (orderPlan == null) return;

    final itemsController = TextEditingController(text: orderPlan!['items']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Plan'),
        content: TextField(
          controller: itemsController,
          decoration: const InputDecoration(labelText: 'Items'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedItems = itemsController.text;
              if (updatedItems.isNotEmpty) {
                await dbHelper.updateOrder(orderPlan!['id'], updatedItems);
                Navigator.pop(context);
                _fetchOrderPlan();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteOrderPlan() async {
    if (orderPlan == null) return;

    await dbHelper.deleteOrder(orderPlan!['id']);
    setState(() {
      orderPlan = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
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
          const Divider(),
          if (orderPlan != null) ...[
            Text('Items: ${orderPlan!['items']}', style: Theme.of(context).textTheme.bodyLarge),
            Text('Total Cost: \$${orderPlan!['totalCost']}', style: Theme.of(context).textTheme.bodyMedium),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _updateOrderPlan,
                  child: const Text('Update Order Plan'),
                  style: ElevatedButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                ElevatedButton(
                  onPressed: _deleteOrderPlan,
                  child: const Text('Delete Order Plan'),
                  style: ElevatedButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ] else if (_selectedDate != null) ...[
            const Text('No order plan found for the selected date.'),
          ],
        ],
      ),
    );
  }
}
