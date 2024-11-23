import 'package:flutter/material.dart';
import 'food_list_screen.dart';
import 'order_plan_screen.dart';
import 'order_query_screen.dart';
import 'populate_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final PopulateDatabase populator = PopulateDatabase();
  await populator.populateFoodItems();

  runApp(const FoodOrderingApp());
}

class FoodOrderingApp extends StatelessWidget {
  const FoodOrderingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontFamily: 'FiraCode', fontSize: 24, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontFamily: 'FiraCode', fontSize: 16),
          bodyMedium: TextStyle(fontFamily: 'FiraCode', fontSize: 14),
        ),
        appBarTheme: const AppBarTheme(
          color: Colors.teal,
          titleTextStyle: TextStyle(fontFamily: 'FiraCode', fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
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
