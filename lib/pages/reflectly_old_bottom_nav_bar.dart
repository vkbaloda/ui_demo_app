import 'dart:math' show pi;
import 'package:flutter/material.dart';

// not sure what was the design exactly, so made a fantasy nav bar
class ReflectlyOldBottomNavBarPage extends StatefulWidget {
  const ReflectlyOldBottomNavBarPage({Key? key}) : super(key: key);

  @override
  _ReflectlyOldBottomNavBarPageState createState() =>
      _ReflectlyOldBottomNavBarPageState();
}

class _ReflectlyOldBottomNavBarPageState
    extends State<ReflectlyOldBottomNavBarPage> {
  final tabIcons = [
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
        title: Text("Reflectly old-bottomNavBar"),
      ),
      body: Center(
        child: Text(
          "This is tab: ${currentTabIndex + 1}",
          style: TextStyle(fontSize: 24),
        ),
      ),
      bottomNavigationBar: ReflectlyOldBottomNavBar(
        onTap: _onTabClick,
        tabs: tabIcons,
        barColor: Colors.purple,
      ),
    );
  }
}

class ReflectlyOldBottomNavBar extends StatefulWidget {
  final ValueChanged<int>? onTap;
  final List<IconData> tabs;
  final int initialTab;
  final Color? barColor;
  const ReflectlyOldBottomNavBar(
      {Key? key,
      this.onTap,
      required this.tabs,
      this.initialTab = 0,
      this.barColor})
      : super(key: key);

  @override
  _ReflectlyOldBottomNavBarState createState() =>
      _ReflectlyOldBottomNavBarState();
}

class _ReflectlyOldBottomNavBarState extends State<ReflectlyOldBottomNavBar> {
  static const bottomNavBarHeight = 56.0;
  late double offsetX;
  late int selectedTabIndex;

  @override
  void initState() {
    super.initState();

    selectedTabIndex = widget.initialTab;
    offsetX = _getOffsetX();
  }

  double _getOffsetX() {
    return (1 + selectedTabIndex * 2) / (widget.tabs.length * 2);
  }

  void _onTap(int index) {
    if (selectedTabIndex != index) {
      setState(() {
        selectedTabIndex = index;
        offsetX = _getOffsetX();
      });
    }
    widget.onTap?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: bottomNavBarHeight,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: offsetX, end: offsetX),
        duration: Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        builder: (context, value, child) {
          // print(value);
          return CustomPaint(
            painter: _NavBarBackgroundPainter(
              offsetXFraction: value,
              navBarBackgroundColor:
                  widget.barColor ?? Theme.of(context).accentColor,
            ),
            child: child,
          );
        },
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            widget.tabs.length,
            (index) => Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onTap(index),
                child: Icon(
                  widget.tabs[index],
                  color:
                      selectedTabIndex == index ? Colors.white : Colors.white60,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarBackgroundPainter extends CustomPainter {
  static const radius = 7.0;
  final double offsetXFraction;
  final Color navBarBackgroundColor;

  _NavBarBackgroundPainter(
      {required this.offsetXFraction, required this.navBarBackgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final navBarPaint = Paint()..color = navBarBackgroundColor;

    final offsetX = offsetXFraction * size.width;
    final smallRadius = 3.0;
    final barTop = radius - 1;

    final navBarPath = Path()
      ..moveTo(0, barTop)
      ..lineTo(offsetX - radius - 2 * smallRadius, barTop)
      ..cubicTo(
        offsetX - radius + smallRadius / 2,
        barTop,
        offsetX - radius + smallRadius / 2,
        barTop + 1 + radius,
        offsetX,
        barTop + 1 + radius,
      )
      ..cubicTo(
        offsetX + radius - smallRadius / 2,
        barTop + 1 + radius,
        offsetX + radius - smallRadius / 2,
        barTop,
        offsetX + radius + 2 * smallRadius,
        barTop,
      )
      ..lineTo(size.width, barTop)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, barTop);

    canvas.drawPath(navBarPath, navBarPaint);

    canvas.drawCircle(
      Offset(offsetX, radius),
      radius - 3,
      navBarPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NavBarBackgroundPainter oldDelegate) {
    return oldDelegate.offsetXFraction != offsetXFraction;
  }
}
