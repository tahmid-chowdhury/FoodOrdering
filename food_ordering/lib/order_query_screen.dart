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

// Order query screen widget
class OrderQueryScreen extends StatefulWidget {
  const OrderQueryScreen({Key? key}) : super(key: key);

  @override
  State<OrderQueryScreen> createState() => _OrderQueryScreenState();
}

// Order query screen state
class _OrderQueryScreenState extends State<OrderQueryScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  DateTime? _selectedDate;
  Map<String, dynamic>? orderPlan;

  // Initialize the state
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

  // Fetch the order plan for the selected date
  void _fetchOrderPlan() async {
    if (_selectedDate == null) return;

    final dateString = _selectedDate!.toIso8601String().split('T')[0];
    final result = await dbHelper.fetchOrderByDate(dateString);

    setState(() {
      orderPlan = result.isNotEmpty ? result.first : null;
    });
  }

  // Update the order plan
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

  // Delete the order plan
  void _deleteOrderPlan() async {
    if (orderPlan == null) return;

    await dbHelper.deleteOrder(orderPlan!['id']);
    setState(() {
      orderPlan = null;
    });
  }

  // Build the order query screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Display the selected date and a button to pick a date
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
          // Display the order plan details
          if (orderPlan != null) ...[
            Text('Items: ${orderPlan!['items']}', style: Theme.of(context).textTheme.bodyLarge),
            Text('Total Cost: \$${orderPlan!['totalCost']}', style: Theme.of(context).textTheme.bodyMedium),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _updateOrderPlan,
                  child: const Text('Update Plan'),
                  style: ElevatedButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                ElevatedButton(
                  onPressed: _deleteOrderPlan,
                  child: const Text('Delete Plan'),
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
