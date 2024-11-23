import 'package:flutter/material.dart';
import 'food_list_screen.dart';
import 'order_plan_screen.dart';
import 'order_query_screen.dart';

void main() {
  runApp(const FoodOrderingApp());
}

class FoodOrderingApp extends StatelessWidget {
  const FoodOrderingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Food Ordering App'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.fastfood), text: "Food Items"),
              Tab(icon: Icon(Icons.add_shopping_cart), text: "Order Plan"),
              Tab(icon: Icon(Icons.search), text: "Query Orders"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FoodListScreen(),
            OrderPlanScreen(),
            OrderQueryScreen(),
          ],
        ),
      ),
    );
  }
}
