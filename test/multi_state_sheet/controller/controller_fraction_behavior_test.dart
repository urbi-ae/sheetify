import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheetify/sheetify.dart';

import '../mocks/animated_state_sheet_widget_template.dart';
import '../mocks/expandable_header_widget_demo.dart';
import '../mocks/page_test_widget.dart';

const double sheetHeight = 900.0;
const double headerHeight = 50.0;

void main() async {
  late SnappingBehavior behavior;

  late SheetStateMapper<dynamic> stateMapper;
  late MultiStateSheetController<dynamic> controller;
  late List<double> fractions;

  Set<dynamic> stateLog = {};
  Set<double> fractionLog = {};
  Set<double> heightLog = {};
  Set<double> interpolationLog = {};

  Widget buildMultiStateSheet() {
    return PageTestWidget(
      child: MultiStateSheet(
        dragger: null,
        topHeader: const AnimatedStateSheetWidgetTemplate(),
        header: const PlaceholderContainer(text: 'Header'),
        footer: const SizedBox(height: 100, child: PlaceholderContainer(text: 'Footer')),
        content: List.generate(
          20,
          (index) => PlaceholderContainer(
            text: 'Content $index',
          ),
        ),
        scrollController: controller,
      ),
    );
  }

  group('GIVEN controller fractions [0, 1/3, 3/4, 1]', () {
    setUp(() {
      stateLog = {};
      fractionLog = {};
      heightLog = {};
      interpolationLog = {};

      fractions = <double>[0, 1 / 3, 3 / 4, 1];
      stateMapper = const FourStateMapper();
      behavior = FractionSnappingBehavior(fractions: fractions.toSet());

      controller =
          MultiStateSheetController(behavior: behavior, stateMapper: stateMapper, initialState: FourStateSheet.hidden);

      controller.addListener(() {
        stateLog.add(controller.state);
        fractionLog.add(controller.fraction);
        heightLog.add(controller.sheetHeight);
        interpolationLog.add(controller.interpolation);
      });
    });

    testWidgets('MultiStateSheetController openning animation', (tester) async {
      double realOffset() {
        return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
      }

      addTearDown(() {
        controller.dispose();
      });
      await tester.binding.setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
      await tester.pumpWidget(buildMultiStateSheet());
      await tester.pumpAndSettle();

      expect(stateLog, {FourStateSheet.hidden});
      expect(fractionLog, contains(lessThan(1 / 3)));
      expect(heightLog, contains(0.0));
      expect(heightLog, contains(headerHeight));
      expect(interpolationLog, contains(0.0));
      expect(interpolationLog, contains(lessThan(1.0)));
      expect(realOffset(), 0);
      expect(controller.state, FourStateSheet.hidden);
    });

    testWidgets('MultiStateSheetController set to half openned state', (tester) async {
      double realOffset() {
        return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
      }

      addTearDown(() {
        controller.dispose();
      });

      await tester.pumpWidget(buildMultiStateSheet());
      await tester.pumpAndSettle();
      controller.setState(FourStateSheet.halfOpen);
      await tester.pumpAndSettle();

      expect(stateLog, {FourStateSheet.hidden, FourStateSheet.halfOpen});
      expect(fractionLog, contains(moreOrLessEquals(1 / 3)));
      expect(heightLog, contains(0.0));
      expect(heightLog, contains(headerHeight));
      expect(heightLog, contains(moreOrLessEquals(1 / 3 * sheetHeight)));
      expect(interpolationLog, contains(0.0));
      expect(interpolationLog, contains(lessThan(1.0)));
      expect(realOffset(), 0);
      expect(controller.state, FourStateSheet.halfOpen);
    });

    testWidgets('MultiStateSheetController set to openned state', (tester) async {
      double realOffset() {
        return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
      }

      addTearDown(() {
        controller.dispose();
      });

      await tester.pumpWidget(buildMultiStateSheet());
      await tester.pumpAndSettle();
      controller.setState(FourStateSheet.open);
      await tester.pumpAndSettle();

      expect(stateLog, {FourStateSheet.hidden, FourStateSheet.halfOpen, FourStateSheet.open});
      expect(fractionLog, contains(moreOrLessEquals(3 / 4)));
      expect(heightLog, contains(0.0));
      expect(heightLog, contains(moreOrLessEquals(3 / 4 * sheetHeight)));
      expect(interpolationLog, contains(0.0));
      expect(interpolationLog, contains(lessThan(1.0)));
      expect(realOffset(), 0);
      expect(controller.state, FourStateSheet.open);
    });

    testWidgets('MultiStateSheetController set to expanded state', (tester) async {
      double realOffset() {
        return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
      }

      addTearDown(() {
        controller.dispose();
      });

      await tester.pumpWidget(buildMultiStateSheet());
      await tester.pumpAndSettle();
      controller.setState(FourStateSheet.expanded);
      await tester.pumpAndSettle();

      expect(stateLog, {FourStateSheet.hidden, FourStateSheet.halfOpen, FourStateSheet.open, FourStateSheet.expanded});
      expect(fractionLog, contains(moreOrLessEquals(1.0)));
      expect(heightLog, contains(0.0));
      expect(heightLog, contains(sheetHeight));
      expect(interpolationLog, contains(0.0));
      expect(interpolationLog, contains(lessThan(1.0)));
      expect(realOffset(), 0);
      expect(controller.state, FourStateSheet.expanded);
    });
  });
}
