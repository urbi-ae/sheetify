import 'dart:collection';

import 'package:sheetify/sheetify.dart';

/// Base class for all bottom sheet snapping models used in conjunction with [SnappingBehavior].
///
/// This abstract class provides the foundation for calculating snapping offsets
/// based on the state of the bottom sheet and its components.
/// Implementations define how snapping positions are determined.
abstract class SnappingModel {
  /// Default constructor for a snapping model.
  const SnappingModel();

  /// Abstract method to calculate snapping offsets for the bottom sheet.
  ///
  /// - [extent]: The current state of the bottom sheet.
  /// - Returns a sorted set of snapping offsets, where each offset represents a valid
  ///   snapping position in pixels.
  SplayTreeSet<double> getOffsets<T>(MultiStateSheetExtent<T> extent);
}
