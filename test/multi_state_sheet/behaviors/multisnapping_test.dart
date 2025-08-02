import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:sheetify/sheetify.dart';

import '../mocks/mock_multi_state_sheet_extent.dart';
import '../mocks/snapping_model_mock.dart';

const availablePixels = 300.0;
const headerHeight = 50.0;

void main() {
  group('MultiSnappingBehavior', () {
    late MultiSnappingBehavior behavior;

    setUp(() {
      behavior = MultiSnappingBehavior(models: [
        MockSnappingModel(SplayTreeSet.of([100.0, 200.0])),
        MockSnappingModel(SplayTreeSet.of([150.0, 250.0])),
      ]);
    });

    test('should combine offsets from all models', () {
      // Arrange
      final extent = MockMultiStateSheetExtent<int>(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      // Act
      behavior.setup<int>(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [100.0, 150.0, 200.0, 250.0], // Combined and sorted offsets from models
      );
    });

    test('should calculate minOffset and maxOffset correctly', () {
      // Arrange
      final extent = MockMultiStateSheetExtent(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(behavior.minOffset, 100.0); // Smallest offset
      expect(behavior.maxOffset, 250.0); // Largest offset
    });

    test('should return correct snapping offsets for given extent', () {
      // Arrange
      final extent = MockMultiStateSheetExtent(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(behavior.snappingPixelOffsets, [100.0, 150.0, 200.0, 250.0]);
    });

    test('should determine anchored state correctly', () {
      // Arrange
      final extent = MockMultiStateSheetExtent(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      behavior.setup(extent);

      // Act
      final anchoredState = behavior.anchoredState(extent);

      // Assert
      expect(
          anchoredState,
          behavior.snappingPixelOffsets.length -
              1); // State index for offset 0.0
    });

    test('should calculate interpolation correctly between states', () {
      // Arrange
      final extent = MockMultiStateSheetExtent(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      behavior.setup(extent);

      // Act
      final interpolation = behavior.getInterpolation(
        extent: extent,
        offset: 175.0, // Midway between 150.0 and 200.0
      );

      // Assert
      expect(interpolation,
          closeTo(0.5, 0.01)); // Midway should give interpolation 0.5
    });

    test('should determine snapping state for a given offset', () {
      // Arrange
      final extent = MockMultiStateSheetExtent(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      behavior.setup(extent);

      // Act
      final state = behavior.getState(
        extent: extent,
        offset: 300.0,
      );

      // Assert
      expect(state, 0); // Corresponds to the first snapping offset
    });

    test('should detect if offset is at snapping position', () {
      // Arrange
      final extent = MockMultiStateSheetExtent(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      behavior.setup(extent);

      // Act
      final isAtSnap = behavior.isAtSnapOffset(
        extent: extent,
        toleranceDistance: 5.0,
      );

      // Assert
      expect(isAtSnap, isFalse); // Offset is not within tolerance
    });
  });

  group('MultiSnappingBehavior - Additional Test Cases', () {
    late MultiSnappingBehavior behavior;

    setUp(() {
      behavior = MultiSnappingBehavior(models: [
        MockSnappingModel(SplayTreeSet.of([50.0, 150.0])),
        MockSnappingModel(SplayTreeSet.of([200.0, 300.0])),
        MockSnappingModel(SplayTreeSet.of([100.0, 250.0])),
      ]);
    });

    test('should handle empty snapping models', () {
      // Arrange

      expect(
        () => MultiSnappingBehavior(models: []),
        throwsA(
          isA<AssertionError>().having(
            (e) => e.message,
            'message',
            'At least one snapping model must be provided',
          ),
        ),
      );
    });

    test('should handle snapping offsets with duplicates correctly', () {
      // Arrange
      behavior = MultiSnappingBehavior(models: [
        MockSnappingModel(SplayTreeSet.of([100.0, 200.0])),
        MockSnappingModel(SplayTreeSet.of([200.0, 300.0])),
      ]);

      final extent = MockMultiStateSheetExtent(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [100.0, 200.0, 300.0], // Duplicates removed
      );
    });

    test('should return correct closest offsets for a given position', () {
      // Arrange
      final extent = MockMultiStateSheetExtent(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      behavior.setup(extent);

      // Act
      final closestOffsets = behavior.getClosestOffsets(
        125.0, // Between 100.0 and 150.0
        extent,
      );

      // Assert
      expect(closestOffsets, (150.0, 100.0)); // Correct closest offsets
    });

    test('should return first offset after a given position', () {
      // Arrange
      final extent = MockMultiStateSheetExtent(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      behavior.setup(extent);

      // Act
      final firstOffsetAfter = behavior.getFirstOffsetAfter(120.0);

      // Assert
      expect(firstOffsetAfter, 150.0); // First offset greater than 120.0
    });

    test('should return last offset before a given position', () {
      // Arrange
      final extent = MockMultiStateSheetExtent(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      behavior.setup(extent);

      // Act
      final lastOffsetBefore = behavior.getLastOffsetBefore(220.0);

      // Assert
      expect(
          lastOffsetBefore, 200.0); // Last offset less than or equal to 220.0
    });

    test('should compute correct state for exact snapping offset', () {
      // Arrange
      final extent = MockMultiStateSheetExtent(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      behavior.setup(extent);

      // Act
      final state = behavior.stateOfOffset(150.0);

      // Assert
      expect(state, 3); // Index of 150.0 in snapping offsets
    });

    test('should determine state position clamped within boundaries', () {
      // Arrange
      final extent = MockMultiStateSheetExtent(
        availablePixels: availablePixels,
        behavior: behavior,
      )..updateComponents(0, headerHeight, 0, 0);

      behavior.setup(extent);

      // Act
      final position = behavior.statePosition(
        extent: extent,
        state: 2, // Corresponds to offset 200.0
      );

      // Assert
      expect(position, 200.0); // Clamped within available space
    });
  });
}
