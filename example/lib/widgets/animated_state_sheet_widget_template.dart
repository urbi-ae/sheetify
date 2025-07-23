import 'package:sheetify/sheetify.dart';
import 'package:flutter/material.dart';

class AnimatedStateSheetWidgetTemplate extends SheetAnimatedWidget<FourStateSheet> {
  const AnimatedStateSheetWidgetTemplate({super.key, super.defaultState = FourStateSheet.hidden});

  @override
  Widget build(BuildContext context, FourStateSheet state, double interpolation) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: switch (state) {
        FourStateSheet.hidden => Container(
            color: HSLColor.fromAHSL(1.0, interpolation * 360 / 4, 1.0, 0.5).toColor(),
            height: 100 * interpolation,
            width: double.infinity,
            child: Text(state.name),
          ),
        FourStateSheet.halfOpen => Container(
            color: HSLColor.fromAHSL(1.0, interpolation * 360 / 4 + 360 / 4, 1.0, 0.5).toColor(),
            height: 100 * interpolation + 100,
            width: double.infinity,
            child: Text(state.name),
          ),
        FourStateSheet.open => Container(
            color: HSLColor.fromAHSL(1.0, interpolation * 360 / 4 + 360 / 2, 1.0, 0.5).toColor(),
            height: 100 * (1 - interpolation) + 100,
            width: double.infinity,
            child: Text(state.name),
          ),
        FourStateSheet.expanded => Container(
            color: const HSLColor.fromAHSL(1.0, 360 * 3 / 4, 1.0, 0.5).toColor(),
            height: 100,
            width: double.infinity,
            child: Text(state.name),
          ),
      },
    );
  }
}
