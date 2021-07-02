import 'package:flutter/material.dart';

// not sure what was the design exactly, so made a fantasy nav bar
class ReflectlyOldBottomNavBar extends StatefulWidget {
  final ValueChanged<int>? onTap;
  final List<IconData> tabs;
  final int initialTab;
  final Color? backgroundColor;
  final Color unselectedItemColor;
  final Color selectedItemColor;

  const ReflectlyOldBottomNavBar({
    Key? key,
    this.onTap,
    required this.tabs,
    this.initialTab = 0,
    this.backgroundColor,
    this.unselectedItemColor = Colors.white60,
    this.selectedItemColor = Colors.white,
  }) : super(key: key);

  @override
  _ReflectlyOldBottomNavBarState createState() =>
      _ReflectlyOldBottomNavBarState();
}

class _ReflectlyOldBottomNavBarState extends State<ReflectlyOldBottomNavBar> {
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
      height: kBottomNavigationBarHeight,
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
                  widget.backgroundColor ?? Theme.of(context).accentColor,
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
                  color: selectedTabIndex == index
                      ? widget.selectedItemColor
                      : widget.unselectedItemColor,
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
  static const craterRadius = 7.0;
  static const craterBorderRadius = 3.0;
  final double offsetXFraction;
  final Color navBarBackgroundColor;

  _NavBarBackgroundPainter(
      {required this.offsetXFraction, required this.navBarBackgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final navBarPaint = Paint()..color = navBarBackgroundColor;

    final offsetX = offsetXFraction * size.width;
    final barTop = craterRadius - 1;

    final navBarPath = Path()
      ..moveTo(0, barTop)
      ..lineTo(offsetX - craterRadius - 2 * craterBorderRadius, barTop)
      ..cubicTo(
        offsetX - craterRadius + craterBorderRadius / 2,
        barTop,
        offsetX - craterRadius + craterBorderRadius / 2,
        2 * craterRadius,
        offsetX,
        2 * craterRadius,
      )
      ..cubicTo(
        offsetX + craterRadius - craterBorderRadius / 2,
        2 * craterRadius,
        offsetX + craterRadius - craterBorderRadius / 2,
        barTop,
        offsetX + craterRadius + 2 * craterBorderRadius,
        barTop,
      )
      ..lineTo(size.width, barTop)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, barTop);

    canvas.drawPath(navBarPath, navBarPaint);

    canvas.drawCircle(
      Offset(offsetX, craterRadius),
      craterRadius - 3,
      navBarPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NavBarBackgroundPainter oldDelegate) {
    return oldDelegate.offsetXFraction != offsetXFraction;
  }
}
