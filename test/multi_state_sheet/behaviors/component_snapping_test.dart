import 'package:flutter_test/flutter_test.dart';
import 'package:sheetify/sheetify.dart';

import '../mocks/mock_multi_state_sheet_extent.dart';

void main() {
  group('ComponentsSnappingBehavior', () {
    late ComponentsSnappingBehavior behavior;

    test('should calculate snapping offsets for SnapComponent.size', () {
      // Arrange
      behavior = ComponentsSnappingBehavior(
        componentDescriptions: [
          const SnapComponent.size(component: Components.header, size: 0.5),
          const SnapComponent.size(component: Components.footer),
        ],
      );

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          content: 500.0,
          footer: 300.0,
          topHeader: 100.0,
        ),
      );

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [700.0, 900.0], // Calculated offsets based on header and footer sizes
      );
    });

    test('should calculate snapping offsets for SnapComponent.offset', () {
      // Arrange
      behavior = ComponentsSnappingBehavior(
        componentDescriptions: [
          const SnapComponent.offset(component: Components.content, offset: 50.0),
        ],
      );

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          content: 300.0,
          footer: 150.0,
          topHeader: 100.0,
        ),
      );

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [650.0], // Calculated as availablePixels - (content size + offset)
      );
    });

    test('should calculate snapping offsets for SnapComponent.fractionOffset', () {
      // Arrange
      behavior = ComponentsSnappingBehavior(
        componentDescriptions: [
          const SnapComponent.fractionOffset(component: Components.content, fraction: 0.2),
        ],
      );

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          content: 300.0,
          footer: 150.0,
          topHeader: 100.0,
        ),
      );

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [500.0], // Calculated as availablePixels - (content size + 0.2 * availablePixels)
      );
    });

    test('should calculate snapping offsets for SnapComponent.position', () {
      // Arrange
      behavior = ComponentsSnappingBehavior(
        componentDescriptions: [
          const SnapComponent.position(component: Components.header, position: 300.0),
        ],
      );

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          content: 300.0,
          footer: 150.0,
          topHeader: 100.0,
        ),
      );

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [700.0], // Calculated as availablePixels - (position - offsetFromTop)
      );
    });

    test('should calculate snapping offsets for SnapComponent.fraction', () {
      // Arrange
      behavior = ComponentsSnappingBehavior(
        componentDescriptions: [
          const SnapComponent.fraction(component: Components.content, fraction: 0.6),
        ],
      );

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          content: 300.0,
          footer: 150.0,
          topHeader: 100.0,
        ),
      );

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [200.0], // Calculated as (fractionRatio * availablePixels + offsetFromTop)
      );
    });

    test('should calculate snapping offsets for SnapComponent.map', () {
      // Arrange
      behavior = ComponentsSnappingBehavior(
        componentDescriptions: [
          SnapComponent.map(
            const SnapComponent.size(component: Components.header),
            map: (offset) => offset / 2,
          ),
        ],
      );

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          content: 300.0,
          footer: 150.0,
          topHeader: 100.0,
        ),
      );

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [1000 - (200.0 / 2)], // Mapped offset
      );
    });

    test('should calculate snapping offsets for SnapComponent.merge', () {
      // Arrange
      behavior = ComponentsSnappingBehavior(
        componentDescriptions: [
          SnapComponent.merge(
            a: const SnapComponent.size(component: Components.header),
            b: const SnapComponent.offset(component: Components.footer, offset: 50.0),
            merge: (a, b) => a + b,
          ),
        ],
      );

      final extent = MockMultiStateSheetExtent(
        availablePixels: 1000.0,
        initialComponentSizes: const SheetWidgetSizes(
          header: 200.0,
          content: 300.0,
          footer: 150.0,
          topHeader: 100.0,
        ),
      );

      // Act
      behavior.setup(extent);

      // Assert
      expect(
        behavior.snappingPixelOffsets,
        [600.0], // Sum of merged offsets
      );
    });
  });
}
