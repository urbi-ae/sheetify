import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sheetify/sheetify.dart';

class ExpandableHeaderWidgetDemo extends StatefulWidget {
  final bool shrinkOnLowerState;

  const ExpandableHeaderWidgetDemo({
    this.shrinkOnLowerState = false,
    super.key,
  });

  @override
  State<ExpandableHeaderWidgetDemo> createState() =>
      _ExpandableHeaderWidgetDemoState();
}

class _ExpandableHeaderWidgetDemoState
    extends State<ExpandableHeaderWidgetDemo> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiStateSheetBuilder(
        defaultState: FourStateSheet.halfOpen,
        builder: (context, state, interpolation, _) {
          final sizeDelta = 50 * interpolation + state.index * 50;
          final height =
              (widget.shrinkOnLowerState ? 150 - sizeDelta : sizeDelta) +
                  (isExpanded ? 150 : 50);
          return SizedBox(
              height: height,
              child: GestureDetector(
                child: const PlaceholderContainer(text: 'Header'),
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ));
        });
  }
}

class PlaceholderContainer extends StatelessWidget {
  final String? text;

  const PlaceholderContainer({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(),
      ),
      child: Center(
        child: Text(text ?? ' '),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(),
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
