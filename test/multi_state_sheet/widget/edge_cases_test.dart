import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheetify/sheetify.dart';

import '../mocks/animated_state_sheet_widget_template.dart';
import '../mocks/expandable_header_widget_demo.dart';
import '../mocks/page_test_widget.dart';

const double sheetHeight = 1000.0;
const double headerHeight = 50.0;

void main() {
  const stateMapper = IntStateMapper();
  final behavior = MultiSnappingBehavior(models: [
    FractionSnappingModel({0.0, 1.0}),
    ComponentsSnappingModel(componentsDescriptions: [
      SnapComponent.merge(
        a: const SnapComponent.size(component: Components.header),
        b: const SnapComponent.size(component: Components.footer),
        merge: (a, b) => a + b,
      ),
      const SnapComponent.fractionOffset(
          component: Components.header, fraction: 0.7),
    ])
  ]);
  late MultiStateSheetController<int> controller;

  Set<int> stateLog = {};
  Set<double> fractionLog = {};
  Set<double> heightLog = {};
  Set<double> interpolationLog = {};

  const itemsCount = 10;
  int initialState = 0;

  const headerHeight = 100.0;
  const footerHeight = 50.0;
  // const topHeaderHeight = [0, 100, 200, 100];

  Widget buildMultiStateSheet() {
    return PageTestWidget(
      sheetHeight: sheetHeight,
      child: MultiStateSheet(
        dragger: null,
        topHeader: const AnimatedStateSheetWidgetTemplate(
          key: ValueKey('Top header'),
        ),
        header: const SizedBox(
            height: headerHeight, child: PlaceholderContainer(text: 'Header')),
        footer: const SizedBox(
            height: footerHeight, child: PlaceholderContainer(text: 'Footer')),
        content: List.generate(
          itemsCount,
          (index) => PlaceholderContainer(
            text: 'Content $index',
          ),
        ),
        scrollController: controller,
      ),
    );
  }

  void controllerSetup() {
    stateLog = {};
    fractionLog = {};
    heightLog = {};
    interpolationLog = {};

    controller = MultiStateSheetController(
      behavior: behavior,
      stateMapper: stateMapper,
      initialState: initialState,
      durationMultiplier: 5,
    );

    controller.addListener(() {
      stateLog.add(controller.state);
      fractionLog.add(controller.fraction);
      heightLog.add(controller.sheetHeight);
      interpolationLog.add(controller.interpolation);
    });
  }

  group('MultiStateSheet Tests', () {
    setUp(() {
      initialState = 0;
      controllerSetup();
    });

    testWidgets('Initial state matches configuration', (tester) async {
      addTearDown(() {
        controller.dispose();
      });
      await tester.binding
          .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
      await tester.pumpWidget(buildMultiStateSheet());
      await tester.pumpAndSettle();

      expect(controller.state,
          equals(initialState)); // Should start in hidden state
    });

    testWidgets('MultiStateSheet sheet opens when commanded', (tester) async {
      addTearDown(() {
        controller.dispose();
      });
      await tester.binding
          .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
      await tester.pumpWidget(buildMultiStateSheet());

      controller.setState(1); // Half-open
      await tester.pumpAndSettle();

      expect(controller.state, equals(1)); // Verify position
    });

    testWidgets('User can drag bottom sheet to expand', (tester) async {
      addTearDown(() {
        controller.dispose();
      });

      await tester.binding
          .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
      await tester.pumpWidget(buildMultiStateSheet());
      await tester.pumpAndSettle();

      await tester.fling(find.text('Header'), const Offset(0, -900), 800);

      await tester.pumpAndSettle();

      expect(
          controller.sheetHeight, sheetHeight); // Should snap to expanded state
      expect(controller.state, 3); // Should snap to expanded state
    });

    testWidgets('User can swipe down to close bottom sheet', (tester) async {
      addTearDown(() {
        controller.dispose();
      });
      await tester.binding
          .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
      await tester.pumpWidget(buildMultiStateSheet());

      controller.setState(3); // Start fully expanded
      await tester.pumpAndSettle();

      await tester.fling(find.text('Header'), const Offset(0, 900), 800);
      await tester.pumpAndSettle();

      expect(
          controller.sheetHeight, headerHeight); // Should snap to hidden state
      expect(controller.state, 0); // Should snap to hidden state
    });

    void expectCorrectState(
        {double offset = 0.0, String tag = '', double tollerance = 0.0}) {
      expect(controller.viewportHeight, equals(sheetHeight - offset),
          reason: tag);
      expect(controller.sheetHeight,
          moreOrLessEquals(headerHeight, epsilon: tollerance),
          reason: tag);
      expect(controller.state, equals(initialState),
          reason: 'Should be initial state at $tag');
    }

    testWidgets(
        'MultiStateSheet sheet handles viewport size changes, small to big to small to big',
        (tester) async {
      await tester.runAsync(() async {
        final bottomSheet = buildMultiStateSheet();

        /// Set initial small viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 100));
        await tester.pumpWidget(bottomSheet);
        await tester.pumpFrames(bottomSheet, Durations.long4);

        /// Set big viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpFrames(bottomSheet, Durations.long3);
        expectCorrectState(tag: 'Resize while openning', tollerance: 10);

        /// Set small viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 100));
        await tester.pumpFrames(bottomSheet, Durations.short1);
        expectCorrectState(offset: 100, tag: 'Resize and check after a frame');

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 50));
        await tester.pumpAndSettle();
        expectCorrectState(
            offset: 50, tag: 'Resize and check after all settle');
      });
    });
    testWidgets(
        'MultiStateSheet sheet handles viewport size changes, big to small to big to bigger',
        (tester) async {
      await tester.runAsync(() async {
        final bottomSheet = buildMultiStateSheet();

        /// Set initial big viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(bottomSheet);
        await tester.pumpFrames(bottomSheet, Durations.long3);
        expectCorrectState(
            tag: 'Resize while openning (big viewport size)', tollerance: 10);

        /// Set small viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 100));
        await tester.pumpFrames(bottomSheet, Durations.long3);
        expectCorrectState(
            offset: 100, tag: 'Resize while openning (small viewport size)');

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 50));
        await tester.pumpFrames(bottomSheet, Durations.long3);
        expectCorrectState(offset: 50, tag: 'Resize and check after a frames');

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpAndSettle();
        expectCorrectState(tag: 'Resize and check after all settle');
      });
    });
  });
}
