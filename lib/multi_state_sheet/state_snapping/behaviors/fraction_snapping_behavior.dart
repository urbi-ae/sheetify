import 'dart:collection';

import 'package:sheetify/sheetify.dart';

/// Controls the snapping behavior of a bottom sheet based on fractions of its bounding box.
///
/// This behavior defines snapping positions for the bottom sheet by calculating offsets
/// relative to specified fractions of the viewport. It ensures smooth transitions
/// between states and provides boundaries for the minimum and maximum offsets.
final class FractionSnappingBehavior<StateType> extends SnappingBehavior {
  /// The set of fractions used to determine snapping positions.
  ///
  /// Each fraction is a value between `0.0` (bottom of the viewport) and `1.0` (top of the viewport).
  final Set<double> fractions;

  /// The snapping model used to calculate offsets based on fractions.
  final FractionSnappingModel model;

  /// Constructs an [FractionSnappingBehavior] with the specified [fractions].
  ///
  /// - [fractions]: A set of fractions defining snapping states. Must contain at least two ratios.
  ///
  /// ### Example:
  /// ```dart
  /// FractionSnappingBehavior(fractions: {0.25, 0.5, 0.75});
  /// ```
  ///
  /// Throws an [AssertionError] if fewer than two fractions are provided.
  FractionSnappingBehavior({
    required this.fractions,
    super.clipByHeader,
  })  : assert(fractions.length >= 2, 'Fractions must contain at least 2 snapping states'),
        model = FractionSnappingModel(fractions.toSet());

  @override
  SplayTreeSet<double>? performSetup<T>(MultiStateSheetExtent<T> extent) => model.getOffsets(extent);
}
