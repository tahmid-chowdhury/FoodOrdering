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
import 'food_list_screen.dart';
import 'order_plan_screen.dart';
import 'order_query_screen.dart';
import 'populate_database.dart';

// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Populate the database with some initial data
  final PopulateDatabase populator = PopulateDatabase();
  await populator.populateFoodItems();

  runApp(const FoodOrderingApp());
}

// Main application widget
class FoodOrderingApp extends StatelessWidget {
  const FoodOrderingApp({Key? key}) : super(key: key);

  // Build the application with a dark theme
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      // Set the theme to a dark theme with teal as the primary color
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

// Home screen widget
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Build the home screen with a tab bar
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
        // Display the appropriate screen based on the selected tab
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
