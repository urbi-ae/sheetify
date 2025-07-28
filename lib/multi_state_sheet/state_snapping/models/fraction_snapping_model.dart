import 'dart:collection';
import 'dart:ui';

import 'package:sheetify/sheetify.dart';
import 'package:sheetify/utils/round_double.dart';

/// Snapping model that calculates snapping positions based on fraction of the sheet's viewport.
///
/// This model defines snapping offsets as proportions of the viewport's height,
/// allowing for dynamic adjustments based on the available space. It is used with
/// the sheet's [SnappingBehavior] to provide fraction-based snapping states.
final class FractionSnappingModel extends SnappingModel {
  /// A set of fraction where:
  /// - `0` represents the bottom of the viewport.
  /// - `1` represents the top of the viewport.
  ///
  /// Each fraction defines a relative snapping position as a proportion of the available viewport height.
  final Set<double> fractions;

  /// Constructs an [FractionSnappingModel] with the given [fractions].
  ///
  /// - [fractions]: A set of fractions defining snapping positions. Each value should
  ///   fall between `0.0` (bottom of the viewport) and `1.0` (top of the viewport).
  ///
  /// ### Usage Example:
  /// ```dart
  /// // Define snapping positions at 25%, 50%, and 75% of the viewport height.
  /// final snappingModel = FractionSnappingModel({0.25, 0.5, 0.75});
  /// ```
  FractionSnappingModel(this.fractions);

  /// Calculates snapping offsets based on the fractions of the viewport.
  ///
  /// - [extent]: The current state of the sheet.
  /// - Returns a sorted set of snapping offsets, where each offset is a clamped value derived
  ///   from the fractions and the available pixels.
  @override
  SplayTreeSet<double> getOffsets<T>(MultiStateSheetExtent<T> extent) => SplayTreeSet.of(fractions.map(
      (ar) => clampDouble(((1 - ar) * extent.availablePixels).roundDecimal(), extent.minOffset, extent.safeMaxOffset)));
}
