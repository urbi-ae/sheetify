import 'dart:math';
import 'package:auto_route/auto_route.dart';
import 'package:example/widgets/placeholder_container.dart';
import 'package:sheetify/sheetify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sheetify/utils/constants.dart';

@RoutePage()
class DynamicPaddingToggleSheetDemo extends StatefulWidget {
  const DynamicPaddingToggleSheetDemo({super.key});

  @override
  State<DynamicPaddingToggleSheetDemo> createState() => _DynamicPaddingToggleSheetDemoState();
}

class _DynamicPaddingToggleSheetDemoState extends State<DynamicPaddingToggleSheetDemo> {
  late ToggleSheetController controller;

  final shapeDelegateValue = ToggleSheetDelegate.func(
    (controller) => RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: const Radius.circular(kDefaultRadius),
        bottom: Radius.circular(kDefaultRadius * controller.interpolation),
      ),
    ),
  );

  late final paddingDelegate = ToggleSheetDelegate.func(
    (controller) {
      final padding = MediaQuery.viewPaddingOf(context);
      return EdgeInsets.only(
        bottom: (padding.bottom + 16.0) * (controller.interpolation),
        left: 16.0 * controller.interpolation,
        right: 16.0 * controller.interpolation,
      );
    },
  );

  final barrierColorDelegate = ToggleSheetDelegate.func(
    (controller) {
      return Colors.black.withValues(alpha: 0.4 * (1 - controller.interpolation));
    },
  );

  void createController() {
    controller = ToggleSheetController(
      clipByHeader: true,
      heightModel: FractionHeightModel(0.75),
      onClose: (_) {},
    );
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

    const topHeader = SizedBox(
      height: 100,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(kDefaultRadius),
          ),
        ),
      ),
    );
    var outside = Align(
      alignment: Alignment.centerRight,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        IconButton.filledTonal(
            onPressed: () {
              controller.open();
            },
            icon: Icon(CupertinoIcons.add)),
        IconButton.filledTonal(
            onPressed: () {
              controller.close();
            },
            icon: Icon(CupertinoIcons.minus)),
      ]),
    );

    return Material(
      color: Colors.teal,
      child: Center(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: max(0, height - controller.sheetHeight),
                child: Center(
                  child: GestureDetector(
                    child: Text(
                      controller.isEnabled ? 'Sheet is being displayed' : 'Tap to open sheet',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 600,
              child: ToggleSheet(
                startConfig: ToggleSheetStart.closed,
                backgroundColor: Colors.white,
                safeAreaColor: Colors.red,
                hitTestBehavior: HitTestBehavior.opaque,
                topHeader: topHeader,
                topHeaderOffset: -50,
                outside: outside,
                shapeBorderDelegate: shapeDelegateValue,
                paddingDelegate: paddingDelegate,
                barrierColorDelegate: barrierColorDelegate,
                scrollController: controller,
                offsetOutsideWidgetByTopheader: false,
                header: const PlaceholderContainer(text: 'Header'),
                footer: SizedBox(
                  height: 100,
                  child: GestureDetector(
                    onTap: () {
                      controller.reset();
                      Navigator.of(context).pop();
                    },
                    child: const PlaceholderContainer(
                      text: 'Close',
                      color: Colors.red,
                    ),
                  ),
                ),
                sliver: DecoratedSliver(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                  ),
                  sliver: SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => PlaceholderContainer(text: 'Content $index'),
                        childCount: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
