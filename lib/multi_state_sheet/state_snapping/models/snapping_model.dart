import 'dart:collection';

import 'package:sheetify/sheetify.dart';

/// Base class for all [MultiStateSheet] snapping models used in conjunction with [SnappingBehavior].
///
/// This abstract class provides the foundation for calculating snapping offsets
/// based on the state of the sheet and its components.
/// Implementations define how snapping positions are determined.
///
/// See also:
/// - [FractionSnappingModel]: A snapping model based on fractions of the viewport height.
/// - [SizeSnappingModel]: A snapping model based on sheet sizes in pixels.
/// - [OffsetSnappingModel]: A snapping model based on fixed pixel offsets from the top of the viewport.
/// - [ComponentsSnappingModel]: A snapping model based on the sizes of specific sheet components.
abstract class SnappingModel {
  /// Default constructor for a snapping model.
  const SnappingModel();

  /// Abstract method to calculate snapping offsets for the sheet.
  ///
  /// - [extent]: The current state of the sheet.
  /// - Returns a sorted set of snapping offsets, where each offset represents a valid
  ///   snapping position in pixels.
  SplayTreeSet<double> getOffsets<T>(MultiStateSheetExtent<T> extent);
}
