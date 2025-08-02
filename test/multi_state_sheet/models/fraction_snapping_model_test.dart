import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:sheetify/sheetify.dart';

import '../mocks/mock_multi_state_sheet_extent.dart';

void main() {
  group('FractionSnappingModel', () {
    test('should calculate offsets for given fractions', () {
      // Arrange
      final snappingModel = FractionSnappingModel({0.25, 0.5, 0.75});

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
        SplayTreeSet.of([750.0, 500.0, 250.0]), // (1 - ar) * availablePixels
      );
    });

    test('should clamp offsets to minOffset', () {
      // Arrange
      final snappingModel = FractionSnappingModel({0.8, 1.0});

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        minOffset: 200.0, // Minimum allowed offset
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(offsets, SplayTreeSet.of([200.0])); // Clamped to minOffset
    });

    test('should clamp offsets to maxOffset', () {
      // Arrange
      final snappingModel = FractionSnappingModel({0.0, 0.1});

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        minOffset: 0.0,
        maxOffset: 900.0, // Maximum allowed offset
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(offsets, SplayTreeSet.of([900.0])); // Clamped to maxOffset
    });

    test('should handle an empty set of fractions', () {
      // Arrange
      final snappingModel = FractionSnappingModel({});

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

    test('should handle fractions outside valid range', () {
      // Arrange
      final snappingModel =
          FractionSnappingModel({-0.5, 1.5}); // Invalid fractions

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(
          offsets, SplayTreeSet.of([1000.0, 0.0])); // Clamped to valid ranges
    });
  });
}
