import 'dart:collection';
import 'dart:ui';

import 'package:sheetify/sheetify.dart';

/// Snapping model that calculates snapping positions based on fixed pixel positions.
///
/// This model defines snapping offsets as absolute positions relative to the bottom of the viewport,
/// allowing for precise snapping states based on the pixel size of the sheet.
/// It is used with the sheet's [SnappingBehavior] to implement fixed-size snapping logic.
final class SizeSnappingModel extends SnappingModel {
  /// A set of pixel sizes which are defining the snapping positions.
  /// Each position is measured from the bottom of the viewport upwards.
  final Set<double> sizes;

  /// Constructs a [SizeSnappingModel] with the specified [sizes].
  ///
  /// - [sizes]: A set of pixel values representing snapping positions.
  ///   These values should typically be greater than or equal to `0.0` and less than or
  ///   equal to the maximum pixel height of the sheet's viewport.
  ///
  /// ### Usage Example:
  /// ```dart
  /// // Define snapping positions at 100px, 300px, and 600px from the bottom of the viewport.
  /// final snappingModel = SizeSnappingModel({100.0, 300.0, 600.0});
  /// ```
  const SizeSnappingModel(this.sizes);

  /// Calculates snapping offsets based on sized pixel positions.
  ///
  /// - [extent]: The current state of the sheet.
  /// - Returns a sorted set of snapping offsets, where each offset is clamped within the valid range
  ///   of the sheet's configuration.
  @override
  SplayTreeSet<double> getOffsets<T>(MultiStateSheetExtent<T> extent) =>
      SplayTreeSet.of(sizes.map((size) => clampDouble(
          extent.availablePixels - size,
          extent.minOffset,
          extent.safeMaxOffset)));
}
