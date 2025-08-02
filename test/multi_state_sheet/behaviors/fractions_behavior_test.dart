import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sheetify/sheetify.dart';
import 'package:sheetify/utils/math_helper.dart';
import 'package:sheetify/utils/round_double.dart';

import '../mocks/mock_multi_state_sheet_extent.dart';

void main() {
  late SnappingBehavior behavior;
  late MultiStateSheetExtent<dynamic> extent;
  late SheetStateMapper<dynamic> stateMapper;
  late List<double> fractions;

  const double avaliablePixels = 900;
  const double headerHeight = 200;
  const int initialState = 0;

  group('FractionSnappingBehavior', () {
    late FractionSnappingBehavior<int> behavior;

    test('should calculate correct snapping offsets for valid fractions', () {
      // Arrange
      behavior = FractionSnappingBehavior(fractions: {0.25, 0.5, 0.75});
      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        behavior: behavior,
      )..updateComponents(0, 50, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [250.0, 500.0, 750.0], // Calculated as (1 - ar) * availablePixels
      );
    });

    test('should calculate correct minOffset and maxOffset', () {
      // Arrange
      behavior = FractionSnappingBehavior(fractions: {0, 0.5, 0.75});
      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        behavior: behavior,
      )..updateComponents(0, 50, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(behavior.minOffset,
          250.0); // Corresponds to largest fraction (1 - 0.75) * 1000
      expect(behavior.maxOffset,
          950.0); // Clamped to availablePixels - headerShiftHeight
    });

    test('should clamp snapping offsets within available space', () {
      // Arrange
      behavior = FractionSnappingBehavior(fractions: {0.1, 0.2, 0.9});
      final extent = MockMultiStateSheetExtent(
        availablePixels: 500.0,
        behavior: behavior,
      )..updateComponents(0, 100, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [50.0, 400.0], // Offsets clamped within availablePixels
      );
      expect(behavior.maxOffset,
          400.0); // Clamped to availablePixels - headerShiftHeight
    });

    test('should throw AssertionError when fractions are less than two', () {
      // Act & Assert
      expect(
        () => FractionSnappingBehavior(fractions: {0.5}),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            'Fractions must contain at least 2 snapping states',
          ),
        ),
      );
    });

    test('should handle edge case with fraction of 0.0 and 1.0', () {
      // Arrange
      behavior = FractionSnappingBehavior(fractions: {0.0, 1.0});
      final extent = MockMultiStateSheetExtent(
        availablePixels: 800.0,
        behavior: behavior,
      )..updateComponents(0, 50, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [0.0, 750.0], // 0.0 maps to full size - header, 1.0 maps to 0
      );
      expect(behavior.minOffset, 0.0); // Smallest snapping position
      expect(behavior.maxOffset,
          750.0); // Clamped to availablePixels - headerShiftHeight
    });

    test(
        'should correctly calculate snapping offsets when header shift height is large',
        () {
      // Arrange
      behavior = FractionSnappingBehavior(fractions: {0.25, 0.5});
      final extent = MockMultiStateSheetExtent(
        availablePixels: 800.0,
        behavior: behavior,
      )..updateComponents(0, 350, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [400.0, 450.0], // Calculated offsets
      );
      expect(behavior.minOffset, 400.0); // Based on the largest fraction
      expect(behavior.maxOffset,
          450.0); // Clamped to availablePixels - headerShiftHeight
    });
  });

  /// Snap positions: [0, 300, 625, 900]
  /// fractions:  [0, 0.33, 0.75, 1]
  group('GIVEN fractions [0, 1/3, 3/4, 1]', () {
    setUp(() {
      stateMapper = const FourStateMapper();
      fractions = <double>[0, 1 / 3, 3 / 4, 1];
      behavior = FractionSnappingBehavior(fractions: fractions.toSet());
      extent = MultiStateSheetExtent(
        behavior: behavior,
        stateMapper: stateMapper,
        initialState: initialState,
        availablePixels: avaliablePixels,
        durationMultiplier: 1,
      )
        ..updateComponents(0, 200, 0, 0)
        ..updateSize(900);
      behavior.setup(extent);
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position of hidden state', () {
        setUp(() async {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(900);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
          extent.updateSize(900);
        });

        test(
          'Test get current position:',
          () => expect(extent.offset, avaliablePixels - 200),
        );
        test(
          'Test get position state hidden',
          () => expect(behavior.statePosition(extent: extent, state: 0),
              avaliablePixels - 200),
        );
        test(
          'Test get position state half open',
          () => expect(behavior.statePosition(extent: extent, state: 1),
              avaliablePixels - avaliablePixels / 3),
        );
        test(
          'Test get position state open',
          () => expect(behavior.statePosition(extent: extent, state: 2),
              avaliablePixels - avaliablePixels * 3 / 4),
        );
        test(
          'Test get position state expanded',
          () => expect(behavior.statePosition(extent: extent, state: 3), 0),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position of hidden state', () {
        setUp(() {
          extent.updateComponents(0, 200, 0, 0);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
          extent.updateSize(900);
        });

        test(
          'Test get position state half open',
          () => expect(behavior.statePosition(extent: extent, state: 1),
              avaliablePixels - avaliablePixels / 3),
        );
        test(
          'Test get position state open',
          () => expect(behavior.statePosition(extent: extent, state: 2),
              avaliablePixels - avaliablePixels * 3 / 4),
        );
        test(
          'Test get position state expanded',
          () => expect(behavior.statePosition(extent: extent, state: 3), 0),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state hidden', () {
        setUp(() {
          extent.updateComponents(0, 200, 0, 0);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
          extent.updateSize(avaliablePixels);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal().roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
              behavior.getInterpolation(extent: extent, offset: extent.offset),
              0.0),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state hidden but draggen for 50 pixels', () {
        setUp(() {
          extent.updateComponents(0, 200, 0, 0);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
          extent.updateSize(avaliablePixels - 50);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal().roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
              behavior.getInterpolation(extent: extent, offset: extent.offset),
              0.0),
        );
      });
    });
    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state hidden but draggen for 100 pixels',
          () {
        setUp(() {
          extent.updateComponents(0, 200, 0, 0);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
          extent.updateSize(avaliablePixels - 100);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal().roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
            behavior.getInterpolation(extent: extent, offset: extent.offset),
            0.0,
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state hidden but draggen for 150 pixels',
          () {
        setUp(() {
          extent.updateComponents(0, 200, 0, 0);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
          extent.updateSize(avaliablePixels - 150);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
              behavior.getInterpolation(extent: extent, offset: extent.offset),
              0.0),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state half open but draggen for 200 pixels',
          () {
        setUp(() {
          extent.updateComponents(0, 200, 0, 0);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
          extent.updateSize(avaliablePixels - 200);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
              behavior.getInterpolation(extent: extent, offset: extent.offset),
              0.0),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state half open but draggen for 225 pixels',
          () {
        setUp(() {
          extent.updateComponents(0, 200, 0, 0);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
          extent.updateSize(avaliablePixels - 225);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior.getInterpolation(extent: extent, offset: extent.offset),
            1.0 -
                lerpBetween(
                  1.0 - (extent.offset / extent.availablePixels),
                  0,
                  1,
                  fractions.first,
                  fractions[1],
                ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state half open but draggen for 230 pixels',
          () {
        setUp(() {
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
          extent.updateSize(avaliablePixels - 230);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));

        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior.getInterpolation(extent: extent, offset: extent.offset),
            lerpBetween(
              1.0 - extent.offset / extent.availablePixels,
              0,
              1,
              clampDouble(
                fractions.first,
                (extent.availablePixels - extent.maxOffset) /
                    extent.availablePixels,
                1.0,
              ),
              fractions[1],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state half open but draggen for 300 pixels',
          () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 300);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 1));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 1));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
            behavior.getInterpolation(extent: extent, offset: extent.offset),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              fractions[1],
              fractions[2],
            ).roundDecimal(),
          ),
        );
      });
    });
    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state open but draggen for 500 pixels', () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 500);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 2));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 1));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior
                .getInterpolation(extent: extent, offset: extent.offset)
                .roundDecimal(),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              fractions[1],
              fractions[2],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state open but draggen for 600 pixels', () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 600);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 2));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 1));

        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior.getInterpolation(extent: extent, offset: extent.offset),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              fractions[1],
              fractions[2],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state open but draggen for 700 pixels', () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 700);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 2));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 2));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior
                .getInterpolation(extent: extent, offset: extent.offset)
                .roundDecimal(),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              fractions[2],
              fractions[3],
            ).roundDecimal(),
          ),
        );
      });
    });
    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state open but draggen for 750 pixels', () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 750);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 2));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 2));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior
                .getInterpolation(extent: extent, offset: extent.offset)
                .roundDecimal(),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              fractions[2],
              fractions[3],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state expanded but draggen for 800 pixels',
          () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 800);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 3));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 2));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior
                .getInterpolation(extent: extent, offset: extent.offset)
                .roundDecimal(),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              fractions[2],
              fractions[3],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state expanded but draggen for 850 pixels',
          () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 850);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 3));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 2));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior
                .getInterpolation(extent: extent, offset: extent.offset)
                .roundDecimal(),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              fractions[2],
              fractions[3],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state expanded but draggen for 900 pixels',
          () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 900);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 3));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 3));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
            behavior.getInterpolation(extent: extent, offset: extent.offset),
            1.0 -
                lerpBetween(
                  1.0 - (extent.offset / extent.availablePixels),
                  0,
                  1,
                  fractions[2],
                  fractions[3],
                ).roundDecimal(),
          ),
        );
      });
    });
  });

  group('GIVEN fractions [0, 1/2, 1]', () {
    setUp(() {
      stateMapper = const FourStateMapper();
      fractions = <double>[0, 1 / 2, 1];
      behavior = FractionSnappingBehavior(fractions: fractions.toSet());
      extent = MultiStateSheetExtent(
        behavior: behavior,
        stateMapper: stateMapper,
        initialState: initialState,
        availablePixels: avaliablePixels,
        durationMultiplier: 1,
      );
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position of hidden state', () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(900);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test(
          'Test get position state hidden',
          () => expect(behavior.statePosition(extent: extent, state: 0),
              avaliablePixels - headerHeight),
        );
        test(
          'Test get position state half open',
          () => expect(behavior.statePosition(extent: extent, state: 1),
              avaliablePixels - avaliablePixels / 2),
        );
        test(
          'Test get position state open',
          () => expect(behavior.statePosition(extent: extent, state: 2), 0),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position of hidden state', () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(900);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test(
          'Test get position state half open',
          () => expect(behavior.statePosition(extent: extent, state: 1),
              avaliablePixels - avaliablePixels / 2),
        );
        test(
          'Test get position state open',
          () => expect(behavior.statePosition(extent: extent, state: 2), 0),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state hidden', () {
        setUp(() {
          extent.updateComponents(0, 200, 0, 0);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
            'THEN get snapping positions',
            () => expect(
                behavior.snappingPixelOffsets,
                fractions.map((e) => clampDouble(
                    e * avaliablePixels, extent.minOffset, extent.maxOffset))));
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));

        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
              behavior.getInterpolation(extent: extent, offset: extent.offset),
              0.0),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state hidden but draggen for 50 pixels', () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 50);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
            'THEN get snapping positions',
            () => expect(
                behavior.snappingPixelOffsets,
                fractions.map((e) => clampDouble(
                    e * avaliablePixels, extent.minOffset, extent.maxOffset))));
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
            behavior.getInterpolation(extent: extent, offset: extent.offset),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              clampDouble(
                  fractions.first,
                  (extent.availablePixels - extent.maxOffset) /
                      extent.availablePixels,
                  1.0),
              fractions[1],
            ).roundDecimal(),
          ),
        );
      });
    });
    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state hidden but draggen for 100 pixels',
          () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 100);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
            behavior.getInterpolation(extent: extent, offset: extent.offset),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              clampDouble(
                fractions.first,
                (extent.availablePixels - extent.maxOffset) /
                    extent.availablePixels,
                1.0,
              ),
              fractions[1],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state hidden but draggen for 150 pixels',
          () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 150);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
            behavior.getInterpolation(extent: extent, offset: extent.offset),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              clampDouble(
                fractions.first,
                (extent.availablePixels - extent.maxOffset) /
                    extent.availablePixels,
                1.0,
              ),
              fractions[1],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state half open but draggen for 200 pixels',
          () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 200);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
            behavior.getInterpolation(extent: extent, offset: extent.offset),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              clampDouble(
                fractions.first,
                (extent.availablePixels - extent.maxOffset) /
                    extent.availablePixels,
                1.0,
              ),
              fractions[1],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state half open but draggen for 300 pixels',
          () {
        setUp(() {
          extent.updateComponents(0, 200, 0, 0);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
          extent.updateSize(avaliablePixels - 300);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 0));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 0));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior.getInterpolation(extent: extent, offset: extent.offset),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              clampDouble(
                fractions.first,
                (extent.availablePixels - extent.maxOffset) /
                    extent.availablePixels,
                1.0,
              ),
              fractions[1],
            ).roundDecimal(),
          ),
        );
      });
    });
    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state open but draggen for 500 pixels', () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 500);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 1));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 1));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior
                .getInterpolation(extent: extent, offset: extent.offset)
                .roundDecimal(),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              fractions[1],
              fractions[2],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state open but draggen for 600 pixels', () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 600);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 1));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 1));

        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior
                .getInterpolation(extent: extent, offset: extent.offset)
                .roundDecimal(),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              fractions[1],
              fractions[2],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state open but draggen for 700 pixels', () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 700);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 2));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 1));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior.getInterpolation(extent: extent, offset: extent.offset),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              fractions[1],
              fractions[2],
            ),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state expanded but draggen for 800 pixels',
          () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 800);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 2));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 1));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior
                .getInterpolation(extent: extent, offset: extent.offset)
                .roundDecimal(),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              fractions[1],
              fractions[2],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state expanded but draggen for 850 pixels',
          () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 850);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 2));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 1));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                false));

        test(
          'THEN get interpolation',
          () => expect(
            behavior
                .getInterpolation(extent: extent, offset: extent.offset)
                .roundDecimal(),
            lerpBetween(
              1.0 - (extent.offset / extent.availablePixels),
              0,
              1,
              fractions[1],
              fractions[2],
            ).roundDecimal(),
          ),
        );
      });
    });

    group(
        'GIVEN fractionSnappingBehaviour with MultiStateSheet height $avaliablePixels',
        () {
      group('WHEN initial position state expanded but draggen for 900 pixels',
          () {
        setUp(() {
          extent
            ..updateComponents(0, 200, 0, 0)
            ..updateSize(avaliablePixels - 900);
          behavior
            ..setup(extent)
            ..lastMaxOffset = behavior.maxOffset
            ..setup(extent);
        });

        test('THEN get the min height', () => expect(behavior.minOffset, 0));

        test('THEN get avaliable size',
            () => expect(behavior.avaliableSpace, avaliablePixels));
        test(
          'THEN get snapping positions',
          () => expect(
            behavior.snappingPixelOffsets,
            fractions
                .map((e) => clampDouble(
                    ((1 - e) * avaliablePixels).roundDecimal(),
                    extent.minOffset,
                    extent.maxOffset))
                .toList()
                .reversed,
          ),
        );
        test(
            'THEN get current state',
            () => expect(
                behavior.getState(extent: extent, offset: extent.offset), 2));
        test('THEN get anchored state',
            () => expect(behavior.anchoredState(extent), 2));
        test(
            'THEN is at snap position',
            () => expect(
                behavior.isAtSnapOffset(extent: extent, toleranceDistance: 0),
                true));

        test(
          'THEN get interpolation',
          () => expect(
            behavior
                .getInterpolation(extent: extent, offset: extent.offset)
                .roundDecimal(),
            1.0 -
                lerpBetween(
                  1.0 - (extent.offset / extent.availablePixels),
                  0,
                  1,
                  fractions[1],
                  fractions[2],
                ).roundDecimal(),
          ),
        );
      });
    });
  });
}
