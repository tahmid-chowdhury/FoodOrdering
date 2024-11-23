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
      if (result.isNotEmpty) {
        orderPlan = result.first;
      } else {
        orderPlan = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Date Picker
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
          const Divider(),
          // Display Order Plan
          if (orderPlan != null) ...[
            Text(
              'Order Plan for ${_selectedDate!.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Items: ${orderPlan!['items']}'),
            Text('Total Cost: \$${orderPlan!['totalCost']}'),
          ] else if (_selectedDate != null) ...[
            const Text('No order plan found for the selected date.'),
          ],
        ],
      ),
    );
  }
}
