import 'package:flutter/material.dart';
import 'package:sheetify/widgets/dragger.dart';

/// A [StatelessWidget] that provides a dragger inside a container widget.
///
/// Typically used as an indicator for drag gestures in UI components
/// such as sheets or panels.
///
/// {@tool snippet}
/// Example usage:
///
/// ```dart
/// DraggerContainer()
/// ```
/// {@end-tool}
class DraggerContainer extends StatelessWidget {
  final Color? backgroundColor;
  final Color? draggerColor;

  /// Creates a dragger inside a container widget.
  ///
  /// The [DraggerContainer] is typically used to provide a UI element that can be dragged
  /// by the user, often as part of a custom sheet or panel.
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
