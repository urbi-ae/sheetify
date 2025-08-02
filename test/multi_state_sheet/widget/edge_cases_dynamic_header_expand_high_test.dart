import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheetify/sheetify.dart';

import '../mocks/animated_state_sheet_widget_template.dart';
import '../mocks/expandable_header_widget_demo.dart';
import '../mocks/page_test_widget.dart';

const double sheetHeight = 1000.0;
const double headerHeight = 50.0;

void main() {
  const stateMapper = FourStateMapper();
  final behavior = MultiSnappingBehavior(models: [
    FractionSnappingModel({0.0, 1.0}),
    ComponentsSnappingModel(componentsDescriptions: [
      SnapComponent.merge(
        a: const SnapComponent.size(component: Components.header),
        b: const SnapComponent.size(component: Components.footer),
        merge: (a, b) => a + b,
      ),
      const SnapComponent.fraction(component: Components.header, fraction: 0.7),
    ])
  ]);
  late MultiStateSheetController<FourStateSheet> controller;

  Set<FourStateSheet> stateLog = {};
  Set<double> fractionLog = {};
  Set<double> heightLog = {};
  Set<double> interpolationLog = {};

  const itemsCount = 10;
  FourStateSheet initialState = FourStateSheet.hidden;

  const headerHeights = [50.0, 100.0, 150.0, 200.0];
  const headerExpandHeight = 100;
  const footerHeight = 70.0;
  const footerExpandHeight = 50;

  Widget buildMultiStateSheet() {
    return PageTestWidget(
      sheetHeight: sheetHeight,
      child: MultiStateSheet(
        dragger: null,
        topHeader: const AnimatedStateSheetWidgetTemplate(
          key: ValueKey('Top header'),
        ),
        header: const ExpandableHeaderWidgetDemo(),
        footer: const ExpandableFooterDemoWidget(footerHeight: footerHeight),
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

  group('MultiStateSheet Tests initial hidden state', () {
    setUp(() {
      initialState = FourStateSheet.hidden;
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

    testWidgets('MultiStateSheet sheet opens when commanded to set half open',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        controller.setState(FourStateSheet.halfOpen);
        await tester.pumpAndSettle();

        expect(
            controller.state, equals(FourStateSheet.halfOpen)); // Verify state
      });
    });

    testWidgets('MultiStateSheet sheet opens when commanded to set open',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        controller.setState(FourStateSheet.open);
        await tester.pumpAndSettle();

        expect(controller.state, equals(FourStateSheet.open)); // Verify state
      });
    });

    testWidgets('MultiStateSheet sheet opens when commanded to set expanded',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        final bottomSheet = buildMultiStateSheet();
        await tester.pumpWidget(bottomSheet);
        await tester.pumpFrames(
            bottomSheet, const Duration(microseconds: 1251225));
        controller.setState(FourStateSheet.expanded);
        await tester.pumpAndSettle();

        expect(
            controller.state, equals(FourStateSheet.expanded)); // Verify state
      });
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
      expect(controller.state.index, 3); // Should snap to expanded state
    });

    testWidgets('Tap on header changes size of the sheet', (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        await tester.pumpAndSettle();

        expect(controller.sheetHeight, equals(headerHeights[0]));

        await tester.tap(find.text('Header'));
        await tester.pumpAndSettle();

        expect(controller.sheetHeight,
            equals(headerHeights[0] + headerExpandHeight));
        expect(controller.state, equals(initialState));
      });
    });
    testWidgets('Tap on header changes size of the sheet on half open state',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        await tester.pumpAndSettle();

        expect(controller.sheetHeight, equals(headerHeights[0]));

        await tester.tap(find.text('Header'));
        await tester.pump(const Duration(microseconds: 1));
        controller.setState(FourStateSheet.halfOpen);
        await tester.pumpAndSettle();

        expect(controller.sheetHeight,
            equals(headerHeights[0] + headerExpandHeight + footerHeight));
        expect(controller.state, equals(FourStateSheet.halfOpen));
      });
    });

    testWidgets('User can swipe down to close bottom sheet', (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());

        controller.setState(FourStateSheet.expanded,
            duration: Durations.short1);
        await tester.pumpAndSettle();
        expect(controller.state.index, 3); // Should snap to expanded state

        await tester.fling(find.text('Header'), const Offset(0, 920), 800);
        await tester.pumpAndSettle();

        expect(controller.state.index, 0); // Should snap to hidden state
        expect(controller.sheetHeight,
            headerHeights[0]); // Should snap to hidden state
      });
    });

    void expectCorrectState({
      double offset = 0.0,
      String tag = '',
      double tollerance = 0.0,
      FourStateSheet state = FourStateSheet.hidden,
    }) {
      expect(controller.viewportHeight, equals(sheetHeight - offset),
          reason: tag);
      expect(controller.sheetHeight,
          moreOrLessEquals(headerHeights[state.index], epsilon: tollerance),
          reason: tag);
      expect(
          controller.interpolation, moreOrLessEquals(0.0, epsilon: tollerance),
          reason: tag);
      expect(controller.state, equals(initialState),
          reason: 'Should be initial state at $tag');
    }

    testWidgets(
        'User can swipe down to close bottom sheet from half open state',
        (tester) async {
      await tester.runAsync(() async {
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());

        controller.setState(FourStateSheet.halfOpen,
            duration: Durations.short1);
        await tester.pumpAndSettle();

        await tester.fling(find.text('Header'), const Offset(0, 55), 100);
        await tester.pumpAndSettle();

        expect(controller.state.index, 0); // Should snap to hidden state
        expect(controller.sheetHeight,
            headerHeights[0]); // Should snap to hidden state
      });
    });

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
        await tester.pumpFrames(bottomSheet, Durations.long4);
        expectCorrectState(
            tag: 'Resize while openning', tollerance: 25, state: initialState);

        /// Set small viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 100));
        await tester.pumpAndSettle();
        await tester.pumpFrames(bottomSheet, Durations.short1);
        expectCorrectState(
            offset: 100,
            tag: 'Resize and check after a frame',
            state: initialState);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 50));
        await tester.pumpAndSettle();
        expectCorrectState(
            offset: 50,
            tag: 'Resize and check after all settle',
            state: initialState);
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
            tag: 'Resize while openning (big viewport size)',
            tollerance: 10,
            state: initialState);

        /// Set small viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 100));
        await tester.pumpFrames(bottomSheet, Durations.long3);
        expectCorrectState(
            offset: 100,
            tag: 'Resize while openning (small viewport size)',
            state: initialState);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 50));
        await tester.pumpFrames(bottomSheet, Durations.long3);
        expectCorrectState(
            offset: 50,
            tag: 'Resize and check after a frames',
            state: initialState);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpAndSettle();
        expectCorrectState(
            tag: 'Resize and check after all settle', state: initialState);
      });
    });
  });

  group('MultiStateSheet Tests initial half open state', () {
    setUp(() {
      initialState = FourStateSheet.halfOpen;
      controllerSetup();
    });

    testWidgets('Initial state matches configuration', (tester) async {
      await tester.runAsync(() async {
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
    });

    testWidgets('MultiStateSheet sheet opens when commanded to set hidden',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        controller.setState(FourStateSheet.hidden);
        await tester.pumpAndSettle();

        expect(controller.state.index,
            equals(FourStateSheet.hidden.index)); // Verify state
      });
    });

    testWidgets('MultiStateSheet sheet opens when commanded to set open',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        controller.setState(FourStateSheet.open);
        await tester.pumpAndSettle();

        expect(controller.state, equals(FourStateSheet.open)); // Verify state
      });
    });

    testWidgets('MultiStateSheet sheet opens when commanded to set expanded',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        controller.setState(FourStateSheet.expanded);
        await tester.pumpAndSettle();

        expect(
            controller.state, equals(FourStateSheet.expanded)); // Verify state
      });
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
      expect(controller.state.index, 3); // Should snap to expanded state
    });

    testWidgets('Tap on header changes size of the sheet', (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        await tester.pumpAndSettle();

        expect(controller.sheetHeight, equals(headerHeights[1] + footerHeight));

        await tester.tap(find.text('Header'));
        await tester.pumpAndSettle();

        expect(controller.sheetHeight,
            equals(headerHeights[1] + footerHeight + 100));
        expect(controller.state, equals(initialState));
      });
    });
    testWidgets('Tap on footer changes size of the sheet', (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        await tester.pumpAndSettle();

        expect(controller.sheetHeight, equals(headerHeights[1] + footerHeight));

        await tester.tap(find.text('Footer'));
        await tester.pumpAndSettle();

        expect(controller.sheetHeight,
            equals(headerHeights[1] + footerHeight + footerExpandHeight));
        expect(controller.state, equals(initialState));
      });
    });

    testWidgets('Tap on header changes size of the sheet on hidden state',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Header'));
        await tester.pumpAndSettle();
        controller.setState(FourStateSheet.hidden);
        await tester.pumpAndSettle();

        expect(controller.sheetHeight, equals(headerHeights[0] + 100));
        expect(controller.state, equals(FourStateSheet.hidden));
      });
    });

    testWidgets(
        'Tap on header changes size of the sheet in half open state when changed on other state',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        await tester.pumpAndSettle();

        expect(controller.sheetHeight, equals(headerHeights[1] + footerHeight));

        controller.setState(FourStateSheet.hidden);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Header'));
        await tester.pumpAndSettle();
        controller.setState(FourStateSheet.halfOpen);
        await tester.pumpAndSettle();

        expect(controller.sheetHeight,
            equals(headerHeights[1] + footerHeight + 100));
        expect(controller.state, equals(FourStateSheet.halfOpen));
      });
    });

    testWidgets(
        'Tap on header changes size of the sheet in hidden state when changed on other state',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        await tester.pumpAndSettle();

        expect(controller.sheetHeight, equals(headerHeights[1] + footerHeight));
        await tester.tap(find.text('Header'));
        await tester.pump(const Duration(microseconds: 1));
        controller.setState(FourStateSheet.hidden);
        await tester.pumpAndSettle();

        expect(controller.sheetHeight, equals(headerHeights[0] + 100));

        await tester.tap(find.text('Header'));
        await tester.pumpAndSettle();

        expect(controller.sheetHeight, equals(headerHeights[0]));
        expect(controller.state, equals(FourStateSheet.hidden));
      });
    });

    testWidgets('User can swipe down to close bottom sheet', (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());

        controller.setState(FourStateSheet.expanded,
            duration: Durations.short1);
        await tester.pumpAndSettle();
        expect(controller.state.index, 3); // Should snap to expanded state

        await tester.fling(find.text('Header'), const Offset(0, 920), 800);
        await tester.pumpAndSettle();

        expect(controller.state.index, 0); // Should snap to hidden state
        expect(controller.sheetHeight,
            headerHeights[0]); // Should snap to hidden state
      });
    });

    void expectCorrectState({
      double offset = 0.0,
      String tag = '',
      double tollerance = 0.0,
      FourStateSheet state = FourStateSheet.hidden,
    }) {
      final heightOfHalfOpenState = headerHeights[1] + footerHeight;
      expect(controller.viewportHeight, equals(sheetHeight - offset),
          reason: tag);
      expect(controller.sheetHeight,
          moreOrLessEquals(heightOfHalfOpenState, epsilon: tollerance),
          reason: tag);
      expect(
          controller.interpolation, moreOrLessEquals(0.0, epsilon: tollerance),
          reason: tag);
      expect(controller.state, equals(initialState),
          reason: 'Should be initial state at $tag');
    }

    testWidgets(
        'User can swipe down to close bottom sheet from half open state',
        (tester) async {
      await tester.runAsync(() async {
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());

        controller.setState(FourStateSheet.halfOpen,
            duration: Durations.short1);
        await tester.pumpAndSettle();

        await tester.fling(find.text('Header'), const Offset(0, 20), 100);
        await tester.pumpAndSettle();

        expect(controller.sheetHeight,
            headerHeights[1] + footerHeight); // Should snap to halfOpen state
        expect(controller.state,
            FourStateSheet.halfOpen); // Should snap to halfOpen state
      });
    });

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
        expectCorrectState(
            tag: 'Resize while openning', tollerance: 25, state: initialState);

        /// Set small viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 100));
        await tester.pumpAndSettle();
        await tester.pumpFrames(bottomSheet, Durations.short1);
        expectCorrectState(
            offset: 100,
            tag: 'Resize and check after a frame',
            state: initialState);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 50));
        await tester.pumpAndSettle();
        expectCorrectState(
            offset: 50,
            tag: 'Resize and check after all settle',
            state: initialState);
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
        await tester.pumpAndSettle();
        expectCorrectState(
            tag: 'Resize while openning (big viewport size)',
            tollerance: 10,
            state: initialState);

        /// Set small viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 100));
        await tester.pumpFrames(bottomSheet, Durations.long3);
        expectCorrectState(
            offset: 100,
            tag: 'Resize while openning (small viewport size)',
            state: initialState);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 50));
        await tester.pumpFrames(bottomSheet, Durations.long3);
        expectCorrectState(
            offset: 50,
            tag: 'Resize and check after a frames',
            state: initialState);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpAndSettle();
        expectCorrectState(
            tag: 'Resize and check after all settle', state: initialState);
      });
    });
  });

  group('MultiStateSheet Tests initial open state', () {
    setUp(() {
      initialState = FourStateSheet.open;
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

    testWidgets('MultiStateSheet sheet opens when commanded to set hidden',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        controller.setState(FourStateSheet.hidden);
        await tester.pumpAndSettle();

        expect(controller.state, equals(FourStateSheet.hidden)); // Verify state
      });
    });

    testWidgets('MultiStateSheet sheet opens when commanded to set half open',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        controller.setState(FourStateSheet.halfOpen);
        await tester.pumpAndSettle();

        expect(
            controller.state, equals(FourStateSheet.halfOpen)); // Verify state
      });
    });

    testWidgets('MultiStateSheet sheet opens when commanded to set expanded',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        controller.setState(FourStateSheet.expanded);
        await tester.pumpAndSettle();

        expect(
            controller.state, equals(FourStateSheet.expanded)); // Verify state
      });
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
      expect(controller.state.index, 3); // Should snap to expanded state
    });

    testWidgets('User can swipe down to close bottom sheet', (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());

        controller.setState(FourStateSheet.expanded,
            duration: Durations.short1);
        await tester.pumpAndSettle();
        expect(controller.state.index, 3); // Should snap to expanded state

        await tester.fling(find.text('Header'), const Offset(0, 920), 800);
        await tester.pumpAndSettle();

        expect(controller.state.index, 0); // Should snap to hidden state
        expect(controller.sheetHeight,
            headerHeights[0]); // Should snap to hidden state
      });
    });

    void expectCorrectState({
      double offset = 0.0,
      String tag = '',
      double tollerance = 0.0,
      FourStateSheet state = FourStateSheet.hidden,
    }) {
      expect(controller.viewportHeight, equals(sheetHeight - offset),
          reason: tag);
      expect(
          controller.sheetHeight,
          moreOrLessEquals(controller.viewportHeight * 0.7,
              epsilon: tollerance),
          reason: tag);
      expect(
          controller.interpolation, moreOrLessEquals(0.0, epsilon: tollerance),
          reason: tag);
      expect(controller.state, equals(initialState),
          reason: 'Should be initial state at $tag');
    }

    testWidgets(
        'User can swipe down to close bottom sheet from half open state',
        (tester) async {
      await tester.runAsync(() async {
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());

        controller.setState(FourStateSheet.halfOpen,
            duration: Durations.short1);
        await tester.pumpAndSettle();

        await tester.fling(find.text('Header'), const Offset(0, 20), 100);
        await tester.pumpAndSettle();

        expect(controller.sheetHeight,
            headerHeights[2] + footerHeight); // Should snap to hidden state
        expect(controller.state,
            FourStateSheet.halfOpen); // Should snap to hidden state
      });
    });

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

        /// Set small viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 100));
        await tester.pumpAndSettle();
        await tester.pumpFrames(bottomSheet, Durations.short1);
        expectCorrectState(
            offset: 100,
            tag: 'Resize and check after a frame',
            state: initialState);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 50));
        await tester.pumpAndSettle();
        expectCorrectState(
            offset: 50,
            tag: 'Resize and check after all settle',
            state: initialState);
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
        await tester.pumpAndSettle();
        expectCorrectState(
            tag: 'Resize while openning (big viewport size)',
            tollerance: 10,
            state: initialState);

        /// Set small viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 100));
        await tester.pumpFrames(bottomSheet, Durations.long3);
        expectCorrectState(
            offset: 100,
            tag: 'Resize while openning (small viewport size)',
            state: initialState);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 50));
        await tester.pumpFrames(bottomSheet, Durations.long3);
        expectCorrectState(
            offset: 50,
            tag: 'Resize and check after a frames',
            state: initialState);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpAndSettle();
        expectCorrectState(
            tag: 'Resize and check after all settle', state: initialState);
      });
    });
  });

  group('MultiStateSheet Tests initial expanded state', () {
    setUp(() {
      initialState = FourStateSheet.expanded;
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

    testWidgets('MultiStateSheet sheet opens when commanded to set hidden',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        controller.setState(FourStateSheet.hidden);
        await tester.pumpAndSettle();

        expect(controller.state, equals(FourStateSheet.hidden)); // Verify state
      });
    });

    testWidgets('MultiStateSheet sheet opens when commanded to set half open',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        controller.setState(FourStateSheet.halfOpen);
        await tester.pumpAndSettle();

        expect(
            controller.state, equals(FourStateSheet.halfOpen)); // Verify state
      });
    });

    testWidgets('MultiStateSheet sheet opens when commanded to set open',
        (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());
        controller.setState(FourStateSheet.open);
        await tester.pumpAndSettle();

        expect(controller.state, equals(FourStateSheet.open)); // Verify state
      });
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
      expect(controller.state,
          FourStateSheet.expanded); // Should snap to expanded state
    });

    testWidgets('User can swipe down to close bottom sheet', (tester) async {
      await tester.runAsync(() async {
        addTearDown(() {
          controller.dispose();
        });
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());

        controller.setState(FourStateSheet.expanded,
            duration: Durations.short1);
        await tester.pumpAndSettle();
        expect(controller.state.index, 3); // Should snap to expanded state

        await tester.fling(find.text('Header'), const Offset(0, 920), 800);
        await tester.pumpAndSettle();

        expect(controller.state.index, 0); // Should snap to hidden state
        expect(controller.sheetHeight,
            headerHeights[0]); // Should snap to hidden state
      });
    });

    void expectCorrectState({
      double offset = 0.0,
      String tag = '',
      double tollerance = 0.0,
      FourStateSheet state = FourStateSheet.hidden,
    }) {
      expect(controller.viewportHeight, equals(sheetHeight - offset),
          reason: tag);
      expect(controller.sheetHeight,
          moreOrLessEquals(sheetHeight - offset, epsilon: tollerance),
          reason: tag);
      expect(
          controller.interpolation, moreOrLessEquals(0.0, epsilon: tollerance),
          reason: tag);
      expect(controller.state, equals(initialState),
          reason: 'Should be initial state at $tag');
    }

    testWidgets(
        'User can swipe down to close bottom sheet from half open state',
        (tester) async {
      await tester.runAsync(() async {
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(buildMultiStateSheet());

        controller.setState(FourStateSheet.halfOpen,
            duration: Durations.short1);
        await tester.pumpAndSettle();

        await tester.fling(find.text('Header'), const Offset(0, 20), 100);
        await tester.pumpAndSettle();

        expect(controller.sheetHeight,
            headerHeights[3] + footerHeight); // Should snap to hidden state
        expect(controller.state,
            FourStateSheet.halfOpen); // Should snap to hidden state
      });
    });

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

        /// Set small viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 100));
        await tester.pumpAndSettle();
        await tester.pumpFrames(bottomSheet, Durations.short1);
        expectCorrectState(
            offset: 100,
            tag: 'Resize and check after a frame',
            state: initialState);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 50));
        await tester.pumpAndSettle();
        expectCorrectState(
            offset: 50,
            tag: 'Resize and check after all settle',
            state: initialState);
      });
    });
    testWidgets(
        'MultiStateSheet sheet handles viewport size changes after opens, big to small to big to bigger',
        (tester) async {
      await tester.runAsync(() async {
        final bottomSheet = buildMultiStateSheet();

        /// Set initial big viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(bottomSheet);
        await tester.pumpAndSettle();
        expectCorrectState(
            tag: 'Resize while openning (big viewport size)',
            tollerance: 10,
            state: initialState);

        /// Set small viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 100));
        await tester.pumpFrames(bottomSheet, Durations.long3);
        expectCorrectState(
            offset: 100,
            tag: 'Resize while openning (small viewport size)',
            state: initialState);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 50));
        await tester.pumpFrames(bottomSheet, Durations.long3);
        expectCorrectState(
            offset: 50,
            tag: 'Resize and check after a frames',
            state: initialState);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpAndSettle();
        expectCorrectState(
            tag: 'Resize and check after all settle', state: initialState);
      });
    });
    testWidgets(
        'MultiStateSheet sheet handles viewport size changes while opens, big to small to big to bigger',
        (tester) async {
      await tester.runAsync(() async {
        final bottomSheet = buildMultiStateSheet();

        /// Set initial big viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpWidget(bottomSheet);
        await tester.pumpFrames(bottomSheet, Durations.long3);

        /// Set small viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 100));
        await tester.pumpFrames(bottomSheet, Durations.long3);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight - 50));
        await tester.pumpFrames(bottomSheet, Durations.long3);

        /// Set bigger viewport size
        await tester.binding
            .setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
        await tester.pumpAndSettle();
        expectCorrectState(
            tag: 'Resize and check after all settle', state: initialState);
      });
    });
  });
}

class ExpandableFooterDemoWidget extends StatefulWidget {
  const ExpandableFooterDemoWidget({
    required this.footerHeight,
    super.key,
  });

  final double footerHeight;

  @override
  State<ExpandableFooterDemoWidget> createState() =>
      _ExpandableFooterDemoWidgetState();
}

class _ExpandableFooterDemoWidgetState
    extends State<ExpandableFooterDemoWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: SizedBox(
        height: widget.footerHeight + (isExpanded ? 50 : 0),
        child: const PlaceholderContainer(text: 'Footer'),
      ),
    );
  }
}
