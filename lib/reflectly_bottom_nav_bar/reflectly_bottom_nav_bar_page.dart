import 'package:flutter/material.dart';
import 'reflectly_old_bottom_nav_bar.dart';

class ReflectlyOldBottomNavBarPage extends StatefulWidget {
  const ReflectlyOldBottomNavBarPage({Key? key}) : super(key: key);

  @override
  _ReflectlyOldBottomNavBarPageState createState() =>
      _ReflectlyOldBottomNavBarPageState();
}

class _ReflectlyOldBottomNavBarPageState
    extends State<ReflectlyOldBottomNavBarPage> {
  static const tabIcons = [
    Icons.home,
    Icons.mail,
    Icons.stacked_line_chart,
    Icons.person,
  ];
  int currentTabIndex = 0;

  void _onTabClick(int tabIndex) {
    if (currentTabIndex != tabIndex) {
      setState(() {
        currentTabIndex = tabIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text("Reflectly old-bottomNavBar"),
      ),
      body: Center(
        child: Text(
          "This is tab: ${currentTabIndex + 1}",
          style: const TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: ReflectlyOldBottomNavBar(
        onTap: _onTabClick,
        tabs: tabIcons,
        backgroundColor: Colors.purple,
      ),
    );
  }
}
