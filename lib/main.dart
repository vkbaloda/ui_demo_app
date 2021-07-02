import 'package:flutter/material.dart';
import 'package:ui_demo_app/bank_card_details_page/card_details_page.dart';
import 'package:ui_demo_app/reflectly_fab/reflectly_fab_page.dart';
import 'package:ui_demo_app/reflectly_bottom_nav_bar/reflectly_bottom_nav_bar_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter UI Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  final components = <String, Widget>{
    "Reflectly Old BottomNavBar": ReflectlyOldBottomNavBarPage(),
    "Reflectly FAB": ReflectlyFabPage(),
    "Cards Details Page": CardsDetailsPage(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      appBar: AppBar(
        title: Text("UI components list"),
      ),
      body: ListView(
        children: components.keys
            .map(
              (key) => ListTile(
                tileColor: Colors.white,
                title: Text(key),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => components[key]!,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

/* widget trial page*/
