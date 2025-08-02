import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:sheetify/sheetify.dart';

import '../mocks/mock_multi_state_sheet_extent.dart';

void main() {
  group('ComponentsSnappingModel', () {
    test('should calculate offsets for provided components', () {
      // Arrange
      final components = [
        const SnapComponent.size(component: Components.header, size: 0.5),
        const SnapComponent.size(component: Components.footer),
      ];
      final snappingModel =
          ComponentsSnappingModel(componentsDescriptions: components);

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 100.0,
          topHeader: 200.0,
          content: 300.0,
          footer: 150.0,
        ),
        offset: 1000.0,
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(
        offsets,
        SplayTreeSet.of([850.0, 950.0]),
      );
    });

    test('should return one offset if availablePixels is zero', () {
      // Arrange
      final components = [
        const SnapComponent.size(component: Components.content),
      ];
      final snappingModel =
          ComponentsSnappingModel(componentsDescriptions: components);

      final extent = MockMultiStateSheetExtent(
        availablePixels: 0.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 100.0,
          topHeader: 200.0,
          content: 300.0,
          footer: 150.0,
        ),
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(
        offsets,
        SplayTreeSet.of([0]),
      );
    });

    test('should clamp offsets to minOffset and maxOffset', () {
      // Arrange
      final components = [
        const SnapComponent.size(component: Components.content, size: 0.0),
      ];
      final snappingModel =
          ComponentsSnappingModel(componentsDescriptions: components);

      final extent = MockMultiStateSheetExtent(
        availablePixels: 500.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 100.0,
          topHeader: 200.0,
          content: 300.0,
          footer: 150.0,
        ),
        offset: 500.0,
        minOffset: 100.0,
        maxOffset: 400.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(offsets, SplayTreeSet.of([400.0])); // Clamped to maxOffset
    });
  });
  group('ComponentsSnappingModel - SnapComponent Variations', () {
    test('should handle SnapComponent.size', () {
      // Arrange
      final components = [
        const SnapComponent.size(component: Components.header, size: 0.5),
      ];
      final snappingModel =
          ComponentsSnappingModel(componentsDescriptions: components);

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          topHeader: 100.0,
          content: 300.0,
          footer: 150.0,
        ),
        offset: 1000.0,
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(offsets, SplayTreeSet.of([900.0])); // 1000 - (200 * 0.5)
    });

    test('should handle SnapComponent.offset', () {
      // Arrange
      final components = [
        const SnapComponent.offset(component: Components.footer, offset: 50.0),
      ];
      final snappingModel =
          ComponentsSnappingModel(componentsDescriptions: components);

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          topHeader: 100.0,
          content: 300.0,
          footer: 150.0,
        ),
        offset: 1000.0,
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(offsets, SplayTreeSet.of([800.0])); // 1000 - (150 * 1.0 + 50.0)
    });

    test('should handle SnapComponent.fractionOffset', () {
      // Arrange
      final components = [
        const SnapComponent.fractionOffset(
            component: Components.content, fraction: 0.2),
      ];
      final snappingModel =
          ComponentsSnappingModel(componentsDescriptions: components);

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          topHeader: 100.0,
          content: 300.0,
          footer: 150.0,
        ),
        offset: 1000.0,
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(
          offsets, SplayTreeSet.of([500.0])); // 1000 - (300 * 1.0 + 0.2 * 1000)
    });

    test('should handle SnapComponent.position', () {
      // Arrange
      final components = [
        const SnapComponent.position(
            component: Components.header, position: 300.0),
      ];
      final snappingModel =
          ComponentsSnappingModel(componentsDescriptions: components);

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          topHeader: 100.0,
          content: 300.0,
          footer: 150.0,
        ),
        offset: 1000.0,
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(offsets, SplayTreeSet.of([700.0])); // 1000 - (300.0)
    });

    test('should handle SnapComponent.fraction', () {
      // Arrange
      final components = [
        const SnapComponent.fraction(
            component: Components.content, fraction: 0.6),
      ];
      final snappingModel =
          ComponentsSnappingModel(componentsDescriptions: components);

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          topHeader: 100.0,
          content: 300.0,
          footer: 150.0,
        ),
        offset: 1000.0,
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(offsets, SplayTreeSet.of([200.0])); // 1000 - (0.6 * 1000 + 200.0)
    });

    test('should handle SnapComponent.map', () {
      // Arrange
      final components = [
        SnapComponent.map(
          const SnapComponent.size(component: Components.header),
          map: (offset) => offset / 2,
        ),
      ];
      final snappingModel =
          ComponentsSnappingModel(componentsDescriptions: components);

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          topHeader: 100.0,
          content: 300.0,
          footer: 150.0,
        ),
        offset: 1000.0,
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(offsets, SplayTreeSet.of([1000 - (200.0 / 2)])); // Apply map
    });

    test('should handle SnapComponent.merge', () {
      // Arrange
      final components = [
        SnapComponent.merge(
          a: const SnapComponent.size(component: Components.header),
          b: const SnapComponent.offset(
              component: Components.footer, offset: 50.0),
          merge: (a, b) => a + b,
        ),
      ];
      final snappingModel =
          ComponentsSnappingModel(componentsDescriptions: components);

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          topHeader: 100.0,
          content: 300.0,
          footer: 150.0,
        ),
        offset: 1000.0,
        minOffset: 0.0,
        maxOffset: 1000.0,
      );

      // Act
      final offsets = snappingModel.getOffsets(extent);

      // Assert
      expect(
          offsets,
          SplayTreeSet.of(
              [1000 - (200.0 + 150.0 + 50)])); // 1000 - (header + footer)
    });
  });
}
