import 'package:flutter/material.dart';

class ReflectlyFabItemTransition extends StatelessWidget {
  final Animation<double> itemAnimation;
  final Widget child;
  const ReflectlyFabItemTransition(
      {Key? key, required this.itemAnimation, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: itemAnimation,
      child: child,
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
