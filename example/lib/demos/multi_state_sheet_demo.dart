import 'dart:math';

import 'package:example/main.dart';
import 'package:example/widgets/tap_through_overlay_route.dart';
import 'package:flutter/material.dart';
import 'package:sheetify/sheetify.dart';

class MultiStateSheetDemo extends StatefulWidget {
  const MultiStateSheetDemo({super.key});

  @override
  State<MultiStateSheetDemo> createState() => _MultiStateSheetDemoState();
}

class _MultiStateSheetDemoState extends State<MultiStateSheetDemo> {
  late MultiStateSheetController<FourStateSheet> controller;

  void createController() {
    controller = createMultiStateSheetController();
    controller.addListener(updateState);
  }

  void updateState() {
    if (mounted && !(context as ComponentElement).dirty) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    createController();
  }

  @override
  void dispose() {
    controller.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext mainContext) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.teal,
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: max(100, height - controller.sheetHeight),
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (!controller.isEnabled) {
                  Navigator.of(mainContext).push(TapThroughOverlayRoute(
                    builder: (context) {
                      return Theme(data: Theme.of(mainContext), child: MultiStateSheetPage(controller: controller));
                    },
                  ));
                }
              },
              child: Text(
                controller.isEnabled ? 'Sheet is being displayed' : 'Tap to open sheet',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExpandableHeaderWidgetDemo extends StatefulWidget {
  final MultiStateSheetController<dynamic> controller;
  final bool shrinkOnLowerState;

  const ExpandableHeaderWidgetDemo({
    this.shrinkOnLowerState = false,
    super.key,
    required this.controller,
  });

  @override
  State<ExpandableHeaderWidgetDemo> createState() => _ExpandableHeaderWidgetDemoState();
}

class _ExpandableHeaderWidgetDemoState extends State<ExpandableHeaderWidgetDemo> {
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
          final sizeDelta = 20 * interpolation + state.index * 20;
          final height = (widget.shrinkOnLowerState ? 80 - sizeDelta : sizeDelta) + (isExpanded ? 80 : 0);
          return SizedBox(
              height: height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox.shrink(),
                  GestureDetector(
                    child: const Text('Tap to Expand/Collapse'),
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      widget.controller.reset();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ));
        });
  }
}
