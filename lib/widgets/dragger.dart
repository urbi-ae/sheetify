import 'package:flutter/material.dart';
import 'package:sheetify/utils/constants.dart';

class Dragger extends StatelessWidget {
  final Color? color;

  const Dragger({this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      width: 32,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kDefaultRadius),
          color: color ?? Theme.of(context).bottomSheetTheme.dragHandleColor ?? Colors.grey.shade800,
        ),
      ),
    );
  }
}
