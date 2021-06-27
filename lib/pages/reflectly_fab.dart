import 'dart:math' show pi;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

class ReflectlyFabPage extends StatefulWidget {
  const ReflectlyFabPage({Key? key}) : super(key: key);

  @override
  _ReflectlyFabPageState createState() => _ReflectlyFabPageState();
}

class _ReflectlyFabPageState extends State<ReflectlyFabPage> {
  String _title = "Selected item will come here";

  static const List<FabItem> items = [
    FabItem(lable: "Mood check-in", iconData: Icons.edit_outlined),
    FabItem(lable: "Voice note", iconData: Icons.animation),
    FabItem(lable: "Add photo", iconData: Icons.image_outlined),
  ];

  void onFabItemClick(FabItem item) {
    setState(() {
      _title = item.lable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(_title),
      ),
      body: Center(
        child: ReflectlyFab(
          items: items,
          callback: onFabItemClick,
        ),
      ),
    );
  }
}

/* Code for the fab starts from here
* -currently the location is fixed as bottomCenter
* -colors should be coming from theme*/

@immutable
class FabItem {
  final String lable;
  final IconData iconData;
  const FabItem({required this.iconData, required this.lable});
}

typedef void FabItemCallback(FabItem item);

const _cornerRadius = 25.0;
const _fabWidth = 60.0;
const _fabExpWidth = 200.0;
double get _maxHorizontalPadding => (_fabExpWidth - _fabWidth) / 2;

class ReflectlyFab extends StatefulWidget {
  final List<FabItem> items;
  final FabItemCallback callback;
  const ReflectlyFab({Key? key, required this.items, required this.callback})
      : assert(items.length > 0),
        super(key: key);

  @override
  _ReflectlyFabState createState() => _ReflectlyFabState();
}

class _ReflectlyFabState extends State<ReflectlyFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final Animation<double> _horizontalPaddingAnimation;
  final _listGlobalKey = GlobalKey<AnimatedListState>();
  static const _animationTimeInMillis = 400;
  static const _itemAnimationTimeInMillis = 120;
  static const _itemDelayInMillis = 100;
  final List<FabItem> listItems = [];
  bool _isAdding = false;
  int get _maxTopPadding => 55 * widget.items.length;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _animationTimeInMillis),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
      // reverseCurve: Curves.easeOutCirc,
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

  Future<void> _onTap() async {
    switch (_controller.status) {
      case AnimationStatus.dismissed:
        _controller.forward();
        _updateList();
        break;
      case AnimationStatus.completed:
      case AnimationStatus.forward:
        _updateList(showList: false);
        await Future.delayed(Duration(
            milliseconds: _controller.status == AnimationStatus.completed
                ? _itemDelayInMillis * 2
                : 0));
        _controller.reverse();
        break;
      case AnimationStatus.reverse:
    }
  }

  Future<void> _updateList({bool showList = true}) async {
    _isAdding = showList;
    if (showList) {
      await Future.delayed(Duration(
        milliseconds:
            (_animationTimeInMillis * (0.7 - _animation.value)).round(),
      ));
      for (int i = 0; i < widget.items.length; i++) {
        if (!listItems.contains(widget.items[i])) {
          await Future.delayed(
            Duration(milliseconds: i == 0 ? 0 : _itemDelayInMillis),
          );
          if (!_isAdding) break;
          listItems.add(widget.items[i]);
          _listGlobalKey.currentState?.insertItem(
            i,
            duration: Duration(milliseconds: _itemAnimationTimeInMillis),
          );
        }
      }
    } else {
      for (int i = widget.items.length - 1; i >= 0; i--) {
        if (listItems.contains(widget.items[i])) {
          await Future.delayed(Duration(
            milliseconds: i == widget.items.length ? 0 : _itemDelayInMillis,
          ));
          if (_isAdding) break;
          listItems.removeLast();
          _listGlobalKey.currentState?.removeItem(
            i,
            (context, itemAnimation) => Container(),
            duration: Duration(milliseconds: _itemAnimationTimeInMillis),
          );
        }
      }
    }
  }

  void _onItemTap(FabItem item) {
    if (_controller.status != AnimationStatus.completed) return;
    widget.callback(item);
    _onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_animation.status != AnimationStatus.dismissed)
          GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onTap: _onTap,
            child: FadeTransition(
              opacity: _animation,
              child: Container(
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SizedBox(
              height: _fabWidth + _maxTopPadding,
              width: _fabExpWidth,
              child: AnimatedBuilder(
                animation: _controller,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedList(
                    key: _listGlobalKey,
                    // shrinkWrap: true,
                    itemBuilder: (context, index, itemAnimation) {
                      return FabListItem(
                        item: listItems[index],
                        itemAnimation: itemAnimation,
                        callback: _onItemTap,
                      );
                    },
                  ),
                ),
                builder: (context, child) {
                  // print(_controller.value);
                  return ClipPath(
                    clipper: _horizontalPaddingAnimation.value ==
                            _maxHorizontalPadding
                        ? null
                        : const FabClipper(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: lerpDouble(_maxTopPadding, 0, _animation.value)!,
                        left: _horizontalPaddingAnimation.value,
                        right: _horizontalPaddingAnimation.value,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_cornerRadius),
                          gradient: LinearGradient(
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
            padding: const EdgeInsets.all(16.0),
            child: RotationTransition(
              turns: Tween<double>(begin: 0, end: 3 / 8).animate(_animation),
              child: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onTap,
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

class FabListItem extends StatelessWidget {
  final FabItem item;
  final Animation<double> itemAnimation;
  final FabItemCallback? callback;
  const FabListItem(
      {Key? key,
      required this.item,
      required this.itemAnimation,
      this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: itemAnimation,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => callback?.call(item),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Text(
                item.lable,
                style: TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.fade,
              ),
              const Spacer(),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  color: Colors.pink[400],
                ),
                child: Icon(item.iconData, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
      builder: (context, child) {
        final value = CurveTween(
          curve: Curves.ease,
        ).evaluate(itemAnimation);
        return Transform.translate(
          offset: Tween<Offset>(begin: Offset(0, 20), end: Offset(0, 0))
              .transform(value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }
}

// assumes width > 4*cornerRadius + fabWidth, height > fabWidth + 2*cornerRadius
// ; to get nice shape
class FabClipper extends CustomClipper<Path> {
  const FabClipper();
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
  bool shouldReclip(covariant FabClipper oldClipper) {
    return false;
  }
}
