import 'package:flutter/material.dart';
import 'database_helper.dart';

class OrderQueryScreen extends StatefulWidget {
  const OrderQueryScreen({Key? key}) : super(key: key);

  @override
  State<OrderQueryScreen> createState() => _OrderQueryScreenState();
}

class _OrderQueryScreenState extends State<OrderQueryScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  final TextEditingController _dateController = TextEditingController();

  String? orderDetails;

  void _queryOrderPlan() async {
    final date = _dateController.text;
    if (date.isNotEmpty) {
      final result = await dbHelper.fetchOrderByDate(date);
      if (result.isNotEmpty) {
        final order = result.first;
        setState(() {
          orderDetails = 'Date: ${order['date']}\n'
              'Items: ${order['items']}\n'
              'Total Cost: \$${order['totalCost']}';
        });
      } else {
        setState(() {
          orderDetails = 'No order found for this date.';
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a date')),
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
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _queryOrderPlan,
            child: const Text('Query Order Plan'),
          ),
          if (orderDetails != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                orderDetails!,
                style: const TextStyle(fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}
