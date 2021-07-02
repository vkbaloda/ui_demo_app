import 'dart:math' show pi, pow;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:ui_demo_app/reflectly_fab/reflectly_fab_item_transition.dart';
import 'package:ui_demo_app/reflectly_fab/reflectly_fab_item_widget.dart';

/*
* -currently the location of FAB is fixed as bottomCenter
* -horizontal width of expanded form is also fixed
* -colors should be coming from theme (as in the original app); here its hardcoded*/

@immutable
class FabItem {
  final String lable;
  final IconData iconData;
  const FabItem({required this.iconData, required this.lable});
}

const _cornerRadius = 25.0;
const _fabWidth = 60.0;
const _fabExpandedWidth = 200.0;
const _maxHorizontalPadding = (_fabExpandedWidth - _fabWidth) / 2;

// assumes width > 4*cornerRadius + fabWidth, height > fabWidth + 2*cornerRadius
// ; to get nice shape
class _FabClipper extends CustomClipper<Path> {
  const _FabClipper();
  @override
  Path getClip(Size size) {
    assert(size.width > 4 * _cornerRadius + _fabWidth);
    assert(size.height > 2 * _cornerRadius + _fabWidth);

    return Path()
      ..arcTo(
          Rect.fromCircle(
              center: Offset(
                  _cornerRadius, size.height - _fabWidth - _cornerRadius),
              radius: _cornerRadius),
          pi,
          -pi / 2,
          false)
      ..arcTo(
          Rect.fromCircle(
              center: Offset((size.width - _fabWidth) / 2 - _cornerRadius,
                  size.height - _fabWidth + _cornerRadius),
              radius: _cornerRadius),
          -pi / 2,
          pi / 2,
          false)
      ..arcTo(
          Rect.fromCircle(
              center: Offset((size.width - _fabWidth) / 2 + _cornerRadius,
                  size.height - _cornerRadius),
              radius: _cornerRadius),
          pi,
          -pi / 2,
          false)
      ..arcTo(
          Rect.fromCircle(
              center: Offset((size.width + _fabWidth) / 2 - _cornerRadius,
                  size.height - _cornerRadius),
              radius: _cornerRadius),
          pi / 2,
          -pi / 2,
          false)
      ..arcTo(
          Rect.fromCircle(
              center: Offset((size.width + _fabWidth) / 2 + _cornerRadius,
                  size.height - _fabWidth + _cornerRadius),
              radius: _cornerRadius),
          pi,
          pi / 2,
          false)
      ..arcTo(
          Rect.fromCircle(
              center: Offset(size.width - _cornerRadius,
                  size.height - _fabWidth - _cornerRadius),
              radius: _cornerRadius),
          pi / 2,
          -pi / 2,
          false)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0);
  }

  @override
  bool shouldReclip(covariant _FabClipper oldClipper) {
    return false;
  }
}

class ReflectlyFab extends StatefulWidget {
  final List<FabItem> items;
  final ValueChanged<int> callback;
  const ReflectlyFab({Key? key, required this.items, required this.callback})
      : assert(items.length > 0),
        super(key: key);

  @override
  _ReflectlyFabState createState() => _ReflectlyFabState();
}

class _ReflectlyFabState extends State<ReflectlyFab>
    with SingleTickerProviderStateMixin {
  static const _fabBottomPadding = 16.0;
  static const _animationTimeInMillis = 400;
  static const _itemAnimationTimeInMillis = 120;
  static const _itemDelayInMillis = 100;
  late final int _maxTopPadding;
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Animation<double> _horizontalPaddingAnimation;
  final _fabOverlayColor = Colors.grey.withOpacity(0.5);
  final _listGlobalKey = GlobalKey<AnimatedListState>();
  final List<FabItem> _visibleItemsList = [];
  bool _isAddingItems = false;

  @override
  void initState() {
    super.initState();

    _maxTopPadding = 55 * widget.items.length;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _animationTimeInMillis),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    );
    _horizontalPaddingAnimation =
        Tween<double>(begin: _maxHorizontalPadding, end: 0).animate(
      CurvedAnimation(
        parent: _animation,
        curve: Interval(0.2, 0.7),
      ),
    );
    _controller.addStatusListener((status) {
      if (_controller.value == 0) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _onItemTap(int index) {
    if (_controller.status != AnimationStatus.completed) return;
    widget.callback(index);
    _onExpandCollapse(collapse: true);
  }

  Future<void> _onExpandCollapse({bool? collapse}) async {
    switch (_controller.status) {
      case AnimationStatus.completed:
      case AnimationStatus.forward:
        _updateList(addItems: false);
        await Future.delayed(
          Duration(
              milliseconds: _controller.status == AnimationStatus.completed
                  ? _itemDelayInMillis * 2
                  : 0),
        );
        _controller.reverse();
        break;
      case AnimationStatus.dismissed:
        if (collapse ?? false) return; //to avoid expand by fab outside click
        _controller.forward();
        _updateList();
        break;
      case AnimationStatus.reverse:
    }
  }

  Future<void> _updateList({bool addItems = true}) async {
    _isAddingItems = addItems;
    if (addItems) {
      await Future.delayed(Duration(
        milliseconds:
            (_animationTimeInMillis * (0.7 - _animation.value)).round(),
      ));
      for (int i = 0; i < widget.items.length; i++) {
        if (!_visibleItemsList.contains(widget.items[i])) {
          await Future.delayed(
            Duration(milliseconds: i == 0 ? 0 : _itemDelayInMillis),
          );
          if (!_isAddingItems) break;
          _visibleItemsList.add(widget.items[i]);
          _listGlobalKey.currentState?.insertItem(
            i,
            duration: Duration(milliseconds: _itemAnimationTimeInMillis),
          );
        }
      }
    } else {
      for (int i = widget.items.length - 1; i >= 0; i--) {
        if (_visibleItemsList.contains(widget.items[i])) {
          await Future.delayed(Duration(
            milliseconds: i == widget.items.length ? 0 : _itemDelayInMillis,
          ));
          if (_isAddingItems) break;
          final item = _visibleItemsList.removeLast();
          _listGlobalKey.currentState?.removeItem(
            i,
            (context, itemAnimation) => ReflectlyFabItemTransition(
              itemAnimation: itemAnimation,
              child: ReflectlyFabItemWidget(
                item: item,
                iconBackgroundColor: Colors.pink[400]!,
              ),
            ),
            duration: Duration(
              milliseconds: (_itemAnimationTimeInMillis *
                      (pow(0.5, widget.items.length - 1 - i)))
                  .toInt(),
            ),
          );
        }
      }
    }
  }

  Widget _expandedFabContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedList(
        key: _listGlobalKey,
        // shrinkWrap: true,
        itemBuilder: (context, index, itemAnimation) {
          return ReflectlyFabItemTransition(
            itemAnimation: itemAnimation,
            child: ReflectlyFabItemWidget(
              item: _visibleItemsList[index],
              onClick: () => _onItemTap(index),
              iconBackgroundColor: Colors.pink[400]!,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_animation.status != AnimationStatus.dismissed)
          GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: () => _onExpandCollapse(collapse: true),
            child: FadeTransition(
              opacity: _animation,
              child: Container(
                color: _fabOverlayColor,
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: _fabWidth + _maxTopPadding,
              width: _fabExpandedWidth,
              child: AnimatedBuilder(
                animation: _controller,
                child: _expandedFabContent(),
                builder: (context, child) {
                  // print(_controller.value);
                  return ClipPath(
                    clipper: _horizontalPaddingAnimation.value ==
                            _maxHorizontalPadding
                        ? null
                        : const _FabClipper(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: lerpDouble(_maxTopPadding, 0, _animation.value)!,
                        left: _horizontalPaddingAnimation.value,
                        right: _horizontalPaddingAnimation.value,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_cornerRadius),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            stops: [0.2, 0.7],
                            colors: [Colors.pink, Colors.pinkAccent],
                          ),
                        ),
                        child: child,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(_fabBottomPadding),
            child: RotationTransition(
              turns: Tween<double>(begin: 0, end: 3 / 8).animate(_animation),
              child: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onExpandCollapse,
                icon: const Icon(Icons.add, color: Colors.white),
                padding: const EdgeInsets.all((_fabWidth - 24) / 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
