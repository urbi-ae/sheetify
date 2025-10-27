import 'dart:math';

import 'package:example/demos/multi_state_sheet_demo.dart';
import 'package:example/routes.dart';
import 'package:example/widgets/animated_state_sheet_widget_template.dart';
import 'package:example/widgets/placeholder_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sheetify/sheetify.dart';

void main() {
  PersistentSafeAreaBottom.startObserving();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sheetify Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: appRouter.config(),
    );
  }
}

MultiStateSheetController<FourStateSheet> createMultiStateSheetController() =>
    MultiStateSheetController(
      stateMapper: const FourStateMapper(),
      initialState: FourStateSheet.halfOpen,
      behavior: MultiSnappingBehavior(clipByHeader: false, models: [
        OffsetSnappingModel({50}),
        FractionSnappingModel({0}),
        SizeSnappingModel({350.0}),
        ComponentsSnappingModel(componentsDescriptions: [
          SnapComponent.merge(
            a: const SnapComponent.size(component: Components.header),
            b: const SnapComponent.size(component: Components.footer),
            merge: (a, b) => a + b,
          )
        ])
      ]),
    );

class MultiStateSheetPage<T> extends StatefulWidget {
  final MultiStateSheetController<FourStateSheet> controller;

  const MultiStateSheetPage({required this.controller, super.key});

  @override
  State<MultiStateSheetPage<T>> createState() => _MultiStateSheetPageState<T>();
}

class _MultiStateSheetPageState<T> extends State<MultiStateSheetPage<T>>
    with TickerProviderStateMixin {
  final outsideOpacityDelegate = StatefulSheetDelegate.func(
      (MultiStateSheetController<FourStateSheet> controller) {
    final isSheetCoversHalfOfTheScreen = controller.fraction > 0.4;
    final isSheetStateOpen = controller.state == FourStateSheet.open;
    final isSheetScrolledForHalfOfTheState = controller.interpolation > 0.4;

    final isFull = (!controller.isEnabled &&
            isSheetStateOpen &&
            isSheetScrolledForHalfOfTheState) ||
        isSheetCoversHalfOfTheScreen;

    return !isFull ? 1.0 : max(0.0, 1 - (controller.fraction - 0.4) * 9);
  });

  @override
  Widget build(BuildContext context) {
    final outside = Align(
      alignment: Alignment.centerRight,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        IconButton.filledTonal(
            onPressed: () {
              widget.controller.setState(FourStateSheet.expanded);
            },
            icon: Icon(CupertinoIcons.add)),
        IconButton.filledTonal(
            onPressed: () {
              widget.controller.setState(FourStateSheet.hidden);
            },
            icon: Icon(CupertinoIcons.minus)),
      ]),
    );
    final header = Column(
      children: [
        ExpandableHeaderWidgetDemo(
          shrinkOnLowerState: true,
          controller: widget.controller,
        ),
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
    );
    const footer = SizedBox(
        height: 100,
        child: PlaceholderContainer(
          text: 'Footer',
          color: Colors.amber,
        ));

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 600,
          child: MultiStateSheet<FourStateSheet>(
            scrollController: widget.controller,
            barrierColorDelegate: FourStateMapper.barrierColorDelegate,
            resizeToAvoidBottomPadding: true,
            hitTestBehavior: HitTestBehavior.opaque,
            backgroundColor: Colors.white,
            safeAreaColor: Colors.grey,
            topHeader: const AnimatedStateSheetWidgetTemplate(),
            header: header,
            footer: footer,
            outsideOpacityDelegate: outsideOpacityDelegate,
            outside: outside,
            sliver: DecoratedSliver(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      PlaceholderContainer(text: 'Content $index'),
                  childCount: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
