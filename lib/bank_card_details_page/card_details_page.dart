import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ui_demo_app/bank_card_details_page/data.dart';
import 'package:ui_demo_app/bank_card_details_page/card_widget.dart';

class CardsDetailsPage extends StatefulWidget {
  const CardsDetailsPage({Key? key}) : super(key: key);

  @override
  _CardsDetailsPageState createState() => _CardsDetailsPageState();
}

class _CardsDetailsPageState extends State<CardsDetailsPage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  final _pageValueNotifier = ValueNotifier<double>(0);
  late final AnimationController _animationByScrollController;
  late final Animation<double> _animationPart1;
  late final Animation<double> _animationPart2;
  final ScrollController _transactionListScrollController = ScrollController();
  bool isListScrollable = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.8);
    _pageController.addListener(() {
      _pageValueNotifier.value = _pageController.page!;
    });

    _animationByScrollController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _animationPart1 = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _animationByScrollController,
        curve: Interval(0, 0.5, curve: Curves.easeInOut),
      ),
    );
    _animationPart2 = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _animationByScrollController,
        curve: Interval(0.5, 1, curve: Curves.easeInOut),
      ),
    );

    // _transactionListScrollController.addListener(() {
    //   if (isListScrollable && _transactionListScrollController.offset == 0) {
    //     setState(() {
    //       isListScrollable = false;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationByScrollController.dispose();
    _transactionListScrollController.dispose();

    super.dispose();
  }

  double _getPage() {
    if (!_pageController.hasClients) return 0;
    return _pageController.page!;
  }

  void _onPageChange(_) {}

  void _onListVerticalDragUpdate(DragUpdateDetails updateDetails) {
    //need to control the animation & isListScrollable here
    final scrollDelta = updateDetails.primaryDelta!;
    final isUpScroll = scrollDelta < 0;
    final currentAnimation = _animationByScrollController.value;
    // print(
    //     "${currentAnimation.toStringAsPrecision(4)} , ${scrollDelta.toStringAsPrecision(4)}");

    if (isUpScroll) {
      if (currentAnimation == 1) {
        _transactionListScrollController
            .jumpTo(_transactionListScrollController.offset - scrollDelta);
        return;
      }
    } else {
      if (currentAnimation == 0 ||
          _transactionListScrollController.offset > 0) {
        _transactionListScrollController
            .jumpTo(_transactionListScrollController.offset - scrollDelta);
        return;
      }
    }

    if (currentAnimation > 0.5) {
      _animationByScrollController.value =
          (currentAnimation - scrollDelta / 500).clamp(0, 1);
    } else {
      _animationByScrollController.value =
          (currentAnimation - scrollDelta / 700).clamp(0, 1);
    }

    if (isUpScroll) {
      if (currentAnimation == 1) {
        setState(() {
          isListScrollable = true;
        });
      }
    }
  }

  void _onListVerticalDragEnd(DragEndDetails endDetails) {
    if (_animationByScrollController.value == 0 ||
        _animationByScrollController.value == 1) return;
    print(endDetails.primaryVelocity);
    if (endDetails.primaryVelocity!.abs() > 600) {
      if (_animationByScrollController.value > 0.5) {
        if (endDetails.primaryVelocity! > 0) {
          _animationByScrollController.animateTo(0.5);
        } else {
          _animationByScrollController.forward().whenComplete(
                () => setState(() => isListScrollable = true),
              );
        }
      } else {
        if (endDetails.primaryVelocity! > 0) {
          _animationByScrollController.reverse();
        } else {
          _animationByScrollController.animateTo(0.5);
        }
      }
    } else {
      if (_animationPart1.value > 0.5) {
        _animationByScrollController.reverse();
      } else if (_animationPart2.value > 0.5) {
        _animationByScrollController.animateTo(0.5);
      } else {
        _animationByScrollController.forward().whenComplete(
              () => setState(() => isListScrollable = true),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).viewPadding.top),
          Placeholder(
            fallbackHeight: 100,
          ),
          AnimatedBuilder(
            animation: _animationPart1,
            child: Placeholder(color: Colors.blue),
            builder: (_, child) {
              return Opacity(
                opacity: _animationPart1.value,
                child: SizedBox(
                  height: 50 * _animationPart1.value,
                  child: child,
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _animationPart2,
            child: PageView(
              onPageChanged: _onPageChange,
              controller: _pageController,
              children: List.generate(
                cards.length,
                (index) => _CardScrollTransform(
                  scrollNotifier: _pageValueNotifier,
                  itemIndex: index,
                  child: CardWidget(cardDetail: cards[index]),
                ),
              ),
            ),
            builder: (_, child) {
              return SizedBox(
                height: 300 * _animationPart2.value,
                child: child,
              );
            },
          ),
          AnimatedBuilder(
            animation: _animationPart1,
            child: Placeholder(color: Colors.blue),
            builder: (_, child) {
              return Opacity(
                opacity: _animationPart1.value,
                child: SizedBox(
                  height: 150 * _animationPart1.value,
                  child: child,
                ),
              );
            },
          ),
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: _onListVerticalDragUpdate,
              onVerticalDragEnd: _onListVerticalDragEnd,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                transform: Matrix4.translationValues(0, 0, 0),
                child: ListView.builder(
                  controller: _transactionListScrollController,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (_, index) => Container(
                    height: 100,
                    color: Colors.teal[100 * (index % 9)],
                  ),
                  itemCount: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DynamicHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  DynamicHeaderDelegate({required this.maxHeight, this.minHeight = 0});
  DynamicHeaderDelegate.fixed({required double height})
      : this(maxHeight: height, minHeight: height);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Placeholder(
      color: Colors.red,
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class _CardScrollTransform extends StatelessWidget {
  final Widget child;
  final int itemIndex;
  final ValueNotifier<double> scrollNotifier;
  const _CardScrollTransform(
      {Key? key,
      required this.scrollNotifier,
      required this.child,
      required this.itemIndex})
      : super(key: key);

  Matrix4 _getTransform(double value) {
    if (value > 0) {
      //is in left to current; rotate
      return Matrix4.rotationZ(value * pi / 8)
        ..translate(value * 80, value * 0);
    } else {
      //is in right to current
      return Matrix4.translationValues(value * 5, 0, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: scrollNotifier,
      child: child,
      builder: (_, double value, child) => Transform(
        transform: _getTransform((value - itemIndex).clamp(-1, 1)),
        origin: Offset(200, -100),
        child: child,
      ),
    );
  }
}
