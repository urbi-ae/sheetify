import 'package:flutter/material.dart';
import 'package:sheetify/utils/constants.dart';

/// A [StatelessWidget] that provides a draggable UI element, typically used
/// to indicate that a panel or sheet can be dragged or swiped by the user.
///
/// This widget is commonly used in sheets or modal dialogs to give
/// users a visual cue for drag interactions.
class Dragger extends StatelessWidget {
  final Color? color;

  /// Creates a [Dragger] widget with an optional [color].
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
