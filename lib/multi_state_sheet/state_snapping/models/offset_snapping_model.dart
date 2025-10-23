import 'dart:collection';
import 'dart:ui';

import 'package:sheetify/sheetify.dart';

/// Snapping model that calculates snapping positions based on fixed pixel positions.
///
/// This model defines snapping offsets as absolute positions relative to the bottom of the viewport,
/// allowing for precise snapping states based on the pixel Offset of the bottom sheet.
/// It is used with the sheet's [SnappingBehavior] to implement fixed-Offset snapping logic.
final class OffsetSnappingModel extends SnappingModel {
  /// A set of pixel offsets which are defining the snapping positions.
  /// Each position is measured from the bottom of the viewport upwards.
  final Set<double> offsets;

  /// Constructs a [OffsetSnappingModel] with the specified [offsets].
  ///
  /// - [offsets]: A set of pixel values representing snapping positions.
  ///   These values should typically be greater than or equal to `0.0` and less than or
  ///   equal to the maximum pixel height of the sheet's viewport.
  ///
  /// ### Usage Example:
  /// ```dart
  /// // Define sheet height snapping positions at 100px, 300px, and 600px with a viewport size of 800px.
  /// final snappingModel = OffsetSnappingModel({200.0, 500.0, 700.0});
  /// ```
  /// #### Explanation:
  /// Given a viewport height of 800px:
  /// - An offset of 700px means the sheet will snap to a position 100px from the bottom (800 - 700 = 100).
  /// - An offset of 500px means the sheet will snap to a position 300px from the bottom (800 - 500 = 300).
  /// - An offset of 200px means the sheet will snap to a position 600px from the bottom (800 - 200 = 600).
  /// This allows for intuitive placement of the sheet at specific offset from the top of the screen.
  const OffsetSnappingModel(this.offsets);

  /// Calculates snapping offsets based on Offsetd pixel positions.
  ///
  /// - [extent]: The current state of the sheet.
  /// - Returns a sorted set of snapping offsets, where each offset is clamped within the valid range
  ///   of the sheet's configuration.
  @override
  SplayTreeSet<double> getOffsets<T>(MultiStateSheetExtent<T> extent) =>
      SplayTreeSet.of(offsets.map((offset) {
        print(['get offsets', offset, extent.minOffset, extent.safeMaxOffset]);
        return clampDouble(offset, extent.minOffset, extent.safeMaxOffset);
      }));
}
