import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sheetify/sheetify.dart';

import '../multi_state_sheet/mocks/expandable_header_widget_demo.dart';

const double sheetHeight = 900.0;
const double childHeight = 50.0;
const double footerAndHeaderHeight = 100;

void main() async {
  late ToggleSheetController controller;

  Set<String> stateLog = {};
  Set<double> fractionLog = {};
  Set<double> heightLog = {};
  Set<bool> enabledLog = {};
  int childCount = 0;

  Widget buildToggleSheetSheet() {
    return ToggleSheetSheetTestWidget(
      controller: controller,
      childCount: childCount,
    );
  }

  group('GIVEN toggle sheet with 3 items in the list', () {
    setUp(() {
      stateLog = {};
      fractionLog = {};
      heightLog = {};
      enabledLog = {};

      childCount = 3;

      controller = ToggleSheetController(
        durationMultiplier: 10,
        onClose: (_) => stateLog.add('closed'),
      );

      controller.addListener(() {
        fractionLog.add(controller.fraction);
        heightLog.add(controller.sheetHeight);
        enabledLog.add(controller.isEnabled);
      });
    });

    testWidgets('ToggleSheet sheet build', (tester) async {
      double realOffset() {
        return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
      }

      addTearDown(() {
        controller.dispose();
      });
      await tester.binding.setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
      await tester.pumpWidget(buildToggleSheetSheet());
      await tester.pumpAndSettle();

      expect(stateLog, <dynamic>{});
      expect(fractionLog, contains(0));
      expect(heightLog, contains(0));
      expect(controller.isClosed, isTrue);
      expect(enabledLog, contains(true));

      expect(realOffset(), 0);
    });

    testWidgets('ToggleSheet sheet openning and close animation', (tester) async {
      double realOffset() {
        return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
      }

      addTearDown(() {
        controller.dispose();
      });

      await tester.pumpWidget(buildToggleSheetSheet());
      await tester.pumpAndSettle();

      expect(controller.isClosed, isTrue);

      /// Clear logs
      stateLog.clear();
      heightLog.clear();
      fractionLog.clear();

      controller.open();
      await tester.pumpAndSettle();

      expect(stateLog, isNot({'closed'}));
      expect(heightLog, contains(greaterThan(0)));
      expect(heightLog, contains(lessThan(childCount * childHeight + footerAndHeaderHeight)));
      expect(controller.isClosed, isFalse);
      expect(enabledLog, contains(true));
      expect(realOffset(), 0);
    });
  });

  group('GIVEN toggle sheet with 0 items in the list', () {
    setUp(() {
      stateLog = {};
      fractionLog = {};
      heightLog = {};
      enabledLog = {};

      childCount = 0;

      controller = ToggleSheetController(
          durationMultiplier: 10,
          onClose: (_) {
            stateLog.add('closed');
          });

      controller.addListener(() {
        fractionLog.add(controller.fraction);
        heightLog.add(controller.sheetHeight);
        enabledLog.add(controller.isEnabled);
      });
    });

    testWidgets('ToggleSheet sheet build', (tester) async {
      double realOffset() {
        return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
      }

      addTearDown(() {
        controller.dispose();
      });
      await tester.binding.setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
      await tester.pumpWidget(buildToggleSheetSheet());
      await tester.pumpAndSettle();

      expect(stateLog, <dynamic>{});
      expect(fractionLog, contains(0));
      expect(heightLog, contains(0));
      expect(controller.isClosed, isTrue);
      expect(enabledLog, contains(true));

      expect(realOffset(), 0);
    });

    testWidgets('ToggleSheet sheet openning and close animation', (tester) async {
      double realOffset() {
        return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
      }

      addTearDown(() {
        controller.dispose();
      });

      await tester.pumpWidget(buildToggleSheetSheet());
      await tester.pumpAndSettle();

      expect(controller.isClosed, isTrue);

      /// Clear logs
      stateLog.clear();
      heightLog.clear();
      fractionLog.clear();

      controller.open();
      await tester.pumpAndSettle();

      expect(stateLog, isNot({'closed'}));
      expect(heightLog, contains(greaterThan(0)));
      expect(heightLog, contains(lessThan(childCount * childHeight + footerAndHeaderHeight)));
      expect(controller.isClosed, isFalse);
      expect(enabledLog, contains(true));
      expect(realOffset(), 0);
    });
  });

  group('GIVEN toggle sheet with 6 items in the list', () {
    setUp(() {
      stateLog = {};
      fractionLog = {};
      heightLog = {};
      enabledLog = {};

      childCount = 6;

      controller = ToggleSheetController(
          durationMultiplier: 10,
          onClose: (_) {
            stateLog.add('closed');
          });

      controller.addListener(() {
        fractionLog.add(controller.fraction);
        heightLog.add(controller.sheetHeight);
        enabledLog.add(controller.isEnabled);
      });
    });

    testWidgets('ToggleSheet sheet build', (tester) async {
      double realOffset() {
        return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
      }

      addTearDown(() {
        controller.dispose();
      });
      await tester.binding.setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
      await tester.pumpWidget(buildToggleSheetSheet());
      await tester.pumpAndSettle();

      expect(stateLog, <dynamic>{});
      expect(fractionLog, contains(0));
      expect(heightLog, contains(0));
      expect(controller.isClosed, isTrue);
      expect(enabledLog, contains(true));

      expect(realOffset(), 0);
    });

    testWidgets('ToggleSheet sheet openning animation', (tester) async {
      double realOffset() {
        return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
      }

      addTearDown(() {
        controller.dispose();
      });

      await tester.pumpWidget(buildToggleSheetSheet());
      await tester.pumpAndSettle();

      expect(controller.isClosed, isTrue);

      /// Clear logs
      stateLog.clear();
      heightLog.clear();
      fractionLog.clear();

      controller.open();
      await tester.pumpAndSettle();

      expect(stateLog, isNot({'closed'}));
      expect(heightLog, contains(greaterThan(0)));
      expect(heightLog, contains(lessThan(childCount * childHeight + footerAndHeaderHeight)));
      expect(controller.isClosed, isFalse);
      expect(enabledLog, contains(true));
      expect(realOffset(), 0);
    });
  });

  group('GIVEN toggle sheet with 20 items in the list', () {
    setUp(() {
      stateLog = {};
      fractionLog = {};
      heightLog = {};
      enabledLog = {};

      childCount = 20;

      controller = ToggleSheetController(
          durationMultiplier: 10,
          onClose: (_) {
            stateLog.add('closed');
          });

      controller.addListener(() {
        fractionLog.add(controller.fraction);
        heightLog.add(controller.sheetHeight);
        enabledLog.add(controller.isEnabled);
      });
    });

    testWidgets('ToggleSheet sheet openning animation', (tester) async {
      double realOffset() {
        return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
      }

      addTearDown(() {
        controller.dispose();
      });
      await tester.binding.setSurfaceSize(const Size(sheetHeight / 2, sheetHeight));
      await tester.pumpWidget(buildToggleSheetSheet());
      await tester.pumpAndSettle();

      expect(stateLog, <dynamic>{});
      expect(fractionLog, contains(0));
      expect(heightLog, contains(0));
      expect(controller.isClosed, isTrue);
      expect(enabledLog, contains(true));

      expect(realOffset(), 0);
    });

    testWidgets('ToggleSheet sheet openning and close animation', (tester) async {
      double realOffset() {
        return tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels;
      }

      addTearDown(() {
        controller.dispose();
      });

      await tester.pumpWidget(buildToggleSheetSheet());
      await tester.pumpAndSettle();

      expect(controller.isClosed, isTrue);

      /// Clear logs
      stateLog.clear();
      heightLog.clear();
      fractionLog.clear();

      controller.open();
      await tester.pumpAndSettle();

      expect(stateLog, isNot({'closed'}));
      expect(heightLog, contains(greaterThan(0)));
      expect(heightLog, contains(lessThan(childCount * childHeight + footerAndHeaderHeight)));
      expect(controller.isClosed, isFalse);
      expect(enabledLog, contains(true));
      expect(realOffset(), 0);
    });
  });
}

class ToggleSheetSheetTestWidget extends StatelessWidget {
  const ToggleSheetSheetTestWidget({
    required this.controller,
    required this.childCount,
    super.key,
  });

  final ToggleSheetController controller;
  final int childCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: sheetHeight,
      width: 400,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ToggleSheet(
          dragger: null,
          startConfig: ToggleSheetStart.closed,
          header: const PlaceholderContainer(text: 'Header'),
          footer: const SizedBox(height: 50, child: PlaceholderContainer(text: 'Footer')),
          content: List.generate(
            childCount,
            (index) => PlaceholderContainer(
              text: 'Content $index',
            ),
          ),
          scrollController: controller,
        ),
      ),
    );
  }
}
