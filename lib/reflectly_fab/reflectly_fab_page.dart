import 'package:flutter/material.dart';
import 'package:ui_demo_app/reflectly_fab/reflectly_fab.dart';

class ReflectlyFabPage extends StatefulWidget {
  const ReflectlyFabPage({Key? key}) : super(key: key);

  @override
  _ReflectlyFabPageState createState() => _ReflectlyFabPageState();
}

class _ReflectlyFabPageState extends State<ReflectlyFabPage> {
  var _title = "Selected item will come here";

  static const List<FabItem> items = [
    FabItem(lable: "Mood check-in", iconData: Icons.edit_outlined),
    FabItem(lable: "Voice note", iconData: Icons.animation),
    FabItem(lable: "Add photo", iconData: Icons.image_outlined),
  ];

  void onFabItemClick(int index) {
    setState(() {
      _title = items[index].lable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(_title),
      ),
      body: ReflectlyFab(
        items: items,
        callback: onFabItemClick,
      ),
    );
  }
}
