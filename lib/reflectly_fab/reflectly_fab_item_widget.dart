import 'package:flutter/material.dart';
import 'package:ui_demo_app/reflectly_fab/reflectly_fab.dart' show FabItem;

class ReflectlyFabItemWidget extends StatelessWidget {
  final FabItem item;
  final VoidCallback? onClick;
  final Color contentColor;
  final Color iconBackgroundColor;
  const ReflectlyFabItemWidget({
    Key? key,
    required this.item,
    required this.iconBackgroundColor,
    this.contentColor = Colors.white,
    this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onClick?.call(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item.lable,
                style: TextStyle(color: contentColor, fontSize: 16),
                overflow: TextOverflow.fade,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: iconBackgroundColor,
              ),
              child: Icon(item.iconData, color: contentColor, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
