import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:example/widgets/placeholder_container.dart';
import 'package:example/widgets/tap_through_overlay_route.dart';
import 'package:sheetify/sheetify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ToggleSheetDemo extends StatefulWidget {
  const ToggleSheetDemo({super.key});

  @override
  State<ToggleSheetDemo> createState() => _ToggleSheetDemoState();
}

class _ToggleSheetDemoState extends State<ToggleSheetDemo> {
  late ToggleSheetController controller;

  void createController() {
    controller = ToggleSheetController(onClose: (controller) => controller.open());
    controller.addListener(updateState);
  }

  @override
  void initState() {
    super.initState();
    createController();
  }

  void updateState() {
    if (mounted && !(context as ComponentElement).dirty) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext mainContext) {
    final height = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.teal,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: max(0, height - controller.sheetHeight),
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (!controller.isEnabled) {
                  Navigator.of(mainContext).push(TapThroughOverlayRoute(
                    builder: (context) {
                      return Theme(data: Theme.of(mainContext), child: ToggleSheetPage(controller: controller));
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

class ToggleSheetPage<T> extends StatefulWidget {
  final ToggleSheetController controller;

  const ToggleSheetPage({required this.controller, super.key});

  @override
  State<ToggleSheetPage<T>> createState() => _ToggleSheetPageState<T>();
}

class _ToggleSheetPageState<T> extends State<ToggleSheetPage<T>> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: ToggleSheet(
          backgroundColor: Colors.white,
          safeAreaColor: Colors.white,
          hitTestBehavior: HitTestBehavior.opaque,
          topHeader: const SizedBox(
            height: 10,
            width: double.infinity,
            child: ColoredBox(color: Colors.amber),
          ),
          topHeaderOffset: 10,
          shouldPop: (controller) {
            if (controller.isClosed) {
              return true;
            }
            controller.close();
            return false;
          },
          outside: Align(
            alignment: Alignment.centerRight,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              IconButton.filledTonal(
                onPressed: () {
                  widget.controller.close();
                },
                icon: Icon(CupertinoIcons.minus),
              ),
            ]),
          ),
          barrierColorDelegate: ToggleSheetDelegate.func((controller) =>
              Colors.black.withValues(alpha: Curves.easeIn.transform(controller.fraction.clamp(0, 1)) * 0.7)),
          scrollController: widget.controller,
          offsetOutsideWidgetByTopheader: false,
          header: Column(
            children: [
              const PlaceholderContainer(text: 'Header'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Input Field',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          footer: SizedBox(
            height: 100,
            child: GestureDetector(
              onTap: () {
                widget.controller.reset();
                Navigator.of(context).pop();
              },
              child: const PlaceholderContainer(text: 'Close'),
            ),
          ),
          content: [
            const PlaceholderContainer(text: 'Content 1'),
            const PlaceholderContainer(text: 'Content 2'),
          ],
        ),
      ),
    );
  }
}
