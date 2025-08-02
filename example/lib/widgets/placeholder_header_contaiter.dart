import 'package:sheetify/sheetify.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlaceholderHeaderContainer extends SheetAnimatedWidget<FourStateSheet> {
  final String? text;

  const PlaceholderHeaderContainer(
      {required super.defaultState, super.key, this.text});

  @override
  Widget build(
      BuildContext context, FourStateSheet state, double interpolation) {
    final double height;

    if (state == FourStateSheet.hidden) {
      height = 50 * interpolation + 50;
    } else if (state == FourStateSheet.halfOpen) {
      height = 50 * (1 - interpolation) + 50;
    } else {
      height = 50;
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(
        child: GestureDetector(
          child: Text(text ?? ' '),
          onTap: () {
            if (kDebugMode) {
              print('tap on $text');
            }
          },
        ),
      ),
    );
  }
}
