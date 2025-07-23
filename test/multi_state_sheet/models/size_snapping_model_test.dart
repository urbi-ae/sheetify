import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:sheetify/sheetify.dart';

import '../mocks/mock_multi_state_sheet_extent.dart';

void main() {
  group('FixedSizeSnappingModel', () {
    test('should calculate offsets for given fixed positions', () {
      // Arrange
      final snappingModel = SizeSnappingModel({100.0, 300.0, 600.0});

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(
        offsets,
        SplayTreeSet.of([900.0, 700.0, 400.0]), // availablePixels - position
      );
    });

    test('should clamp offsets to minOffset', () {
      // Arrange
      final snappingModel = SizeSnappingModel({800.0, 1000.0, 1200.0});

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        minOffset: 100.0, // Minimum allowed offset
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(offsets, SplayTreeSet.of([100.0, 200])); // Clamped to minOffset
    });

    test('should clamp offsets to maxOffset', () {
      // Arrange
      final snappingModel = SizeSnappingModel({100.0, 300.0, 500.0});

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        minOffset: 0.0,
        maxOffset: 400.0, // Maximum allowed offset
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(offsets, SplayTreeSet.of([400.0])); // Clamped to maxOffset
    });

    test('should handle an empty set of state positions', () {
      // Arrange
      const snappingModel = SizeSnappingModel({});

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(offsets, isEmpty);
    });

    test('should handle negative positions', () {
      // Arrange
      final snappingModel = SizeSnappingModel({-100.0, 300.0});

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(offsets, SplayTreeSet.of([1000.0, 700.0]));
    });
  });
}
