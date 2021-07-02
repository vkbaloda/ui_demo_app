import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ui_demo_app/bank_card_details_page/card_details_entity.dart';

class CardWidget extends StatefulWidget {
  final CardDetail cardDetail;
  const CardWidget({Key? key, required this.cardDetail}) : super(key: key);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();

    super.dispose();
  }

  void onVerticalDragUpdate(DragUpdateDetails dragUpdateDetails) {
    _flipController.value =
        (_flipController.value + (dragUpdateDetails.primaryDelta ?? 0) / 150)
            .clamp(0, 1);
  }

  void onVerticalDragEnd(_) {
    if (_flipController.value > 0.5) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: onVerticalDragUpdate,
      onVerticalDragEnd: onVerticalDragEnd,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: LayoutBuilder(
          builder: (context, constraints) => AnimatedBuilder(
            animation: _flipController,
            builder: (context, child) {
              return Transform(
                origin: Offset(
                  constraints.maxWidth / 2,
                  constraints.maxHeight / 2,
                ),
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_flipController.value * math.pi),
                child: _flipController.value > 0.5
                    ? _CardBack(cvcCode: widget.cardDetail.cvcCode)
                    : _CardFront(
                        accountNumber: widget.cardDetail.cardNumber,
                        expiryDate: widget.cardDetail.expiryDate,
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  final String accountNumber;
  final String expiryDate;
  const _CardFront({
    Key? key,
    required this.accountNumber,
    required this.expiryDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 85 / 54,
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.amber,
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  final int cvcCode;
  const _CardBack({Key? key, required this.cvcCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 85 / 54,
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.green,
        ),
      ),
    );
  }
}
