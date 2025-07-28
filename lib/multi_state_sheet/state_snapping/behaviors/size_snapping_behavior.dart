import 'dart:collection';

import 'package:sheetify/sheetify.dart';

/// Snapping behavior which is using `sheet sizes` in pixels to calculate snapping offsets and it's states.
///
/// Controls the behavior of the sheet when scrolling or dragging.
///
/// It provides information to the sheet to bind the sheet to a specific size for each state.
/// If the provided size exceeds the size of the viewport it will be clamped to the size of the viewport.
final class SizeSnappingBehavior extends SnappingBehavior {
  final Set<double> sizes;
  final SizeSnappingModel model;

  /// Snapping behavior which is using `sheet sizes` in pixels to calculate snapping offsets and it's states.
  ///
  /// Controls the behavior of the sheet when scrolling or dragging.
  ///
  /// It provides information to the sheet to bind the sheet to a specific size for each state.
  /// If the provided `size` exceeds the `size of the viewport` it will be clamped to the `size of the viewport`.
  ///
  /// ## Usage
  ///
  /// ```dart
  /// MultiStateSheetController(
  ///   stateMapper: const FourStateMapper(),
  ///   initialState: FourStateSheet.halfOpen,
  ///   behavior: SizeSnappingBehavior(sizes: {0, 400, 600, 900}),
  /// );
  /// ```
  SizeSnappingBehavior({
    required this.sizes,
    super.clipByHeader,
  }) : model = SizeSnappingModel(sizes);

  @override
  SplayTreeSet<double>? performSetup<T>(MultiStateSheetExtent<T> extent) => model.getOffsets(extent);
}
