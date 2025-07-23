import 'package:flutter_test/flutter_test.dart';
import 'package:sheetify/sheetify.dart';

import '../mocks/mock_multi_state_sheet_extent.dart';

void main() {
  group('SizeSnappingBehavior', () {
    late SizeSnappingBehavior behavior;

    test('should calculate snapping offsets correctly for valid state positions', () {
      // Arrange
      behavior = SizeSnappingBehavior(sizes: {100.0, 300.0, 500.0});
      final extent = MockMultiStateSheetExtent(
        availablePixels: 600.0,
        behavior: behavior,
      )..updateComponents(0, 50, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [100.0, 300.0, 500.0], // Directly from statePositions
      );
    });

    test('should calculate correct minOffset and maxOffset for valid positions', () {
      // Arrange
      behavior = SizeSnappingBehavior(sizes: {150.0, 350.0, 550.0});
      final extent = MockMultiStateSheetExtent(
        availablePixels: 600.0,
        behavior: behavior,
      )..updateComponents(0, 50, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(behavior.minOffset, 50.0); // Smallest snapping position
      expect(behavior.maxOffset, 450.0); // Largest snapping position
    });

    test('should clamp snapping offsets within available space', () {
      // Arrange
      behavior = SizeSnappingBehavior(sizes: {0.0, 200.0, 700.0});
      final extent = MockMultiStateSheetExtent(
        availablePixels: 600.0,
        behavior: behavior,
      )..updateComponents(0, 200, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [0.0, 400.0], // 0.0 is clamped out
      );
      expect(behavior.minOffset, 0.0); // Smallest valid offset
      expect(behavior.maxOffset, 400.0); // Largest valid offset within bounds
    });

    test('should handle empty state positions', () {
      // Arrange
      behavior = SizeSnappingBehavior(sizes: {});
      final extent = MockMultiStateSheetExtent(
        availablePixels: 500.0,
        behavior: behavior,
      )..updateComponents(0, 50, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(behavior.snappingPixelOffsets, isEmpty); // No snapping positions
      expect(behavior.minOffset, 0.0); // Default minOffset
      expect(behavior.maxOffset, 450.0); // Default maxOffset
    });

    test('should handle state positions at bounds of the viewport', () {
      // Arrange
      behavior = SizeSnappingBehavior(sizes: {0.0, 600.0});
      final extent = MockMultiStateSheetExtent(
        availablePixels: 600.0,
        behavior: behavior,
      )..updateComponents(0, 50, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [0.0, 550.0], // Valid offsets at viewport bounds
      );
      expect(behavior.minOffset, 0.0); // Smallest offset
      expect(behavior.maxOffset, 550.0); // Largest offset within viewport
    });

    test('should calculate snapping offsets with large headerShiftHeight', () {
      // Arrange
      behavior = SizeSnappingBehavior(sizes: {100.0, 300.0, 500.0});
      final extent = MockMultiStateSheetExtent(
        availablePixels: 700.0,
        behavior: behavior,
      )..updateComponents(0, 500, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [200.0], // 100.0 and 300.0 clamped by headerShiftHeight
      );
      expect(behavior.maxOffset, 200.0); // Clamped to availablePixels - headerShiftHeight
    });
  });
}
