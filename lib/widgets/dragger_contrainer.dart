import 'package:flutter/material.dart';
import 'package:sheetify/widgets/dragger.dart';

class DraggerContainer extends StatelessWidget {
  final Color? backgroundColor;
  final Color? draggerColor;

  const DraggerContainer({
    this.backgroundColor,
    this.draggerColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? Theme.of(context).bottomSheetTheme.backgroundColor ?? Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
            child: Dragger(color: draggerColor),
          ),
        ),
      ),
    );
  }
}
