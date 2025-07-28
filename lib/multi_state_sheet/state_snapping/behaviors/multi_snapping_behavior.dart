import 'dart:collection';

import 'package:sheetify/sheetify.dart';

/// A snapping behavior that combines multiple [SnappingModel] instances
/// to calculate snapping offsets and states.
///
/// This behavior enables a sheet to snap to positions defined by multiple models.
/// If the calculated offsets exceed the viewport's size, they are clamped to fit within the viewport.
///
/// ### Features:
/// - Supports multiple snapping models, allowing flexible snapping logic.
/// - Ensures offsets are bounded by the size of the viewport.
/// - Facilitates smooth transitions between states during scrolling or dragging.
///
/// ### Usage:
/// ```dart
/// MultiStateSheetController(
///   stateMapper: const FourStateMapper(),
///   initialState: FourStateSheet.halfOpen,
///   behavior: MultiSnappingBehavior(models: [
///     FractionSnappingModel({0.0, 0.95}),
///     FixedSizeSnappingModel({500.0}),
///     ComponentsSnappingModel(componentsDescriptions: [
///       SnapComponent.merge(
///         a: const SnapComponent.size(component: Components.header),
///         b: const SnapComponent.size(component: Components.footer),
///         merge: (a, b) => a + b,
///       )
///     ])
///   ]),
/// );
/// ```
final class MultiSnappingBehavior extends SnappingBehavior {
  /// A list of snapping models used to calculate offsets.
  ///
  /// Each model defines a specific logic for determining snapping positions.
  final List<SnappingModel> models;

  /// Constructs a [MultiSnappingBehavior] with the provided list of snapping models.
  ///
  /// - [models]: A list of snapping models. Must contain at least one model.
  ///
  /// ### Example:
  ///  ```dart
  ///  MultiSnappingBehavior(models: [
  ///    AspectRatioSnappingModel({0.0, 0.95}),
  ///    FixedSizeSnappingModel({500.0}),
  ///    ComponentsSnappingModel(componentsDescriptions: [
  ///      SnapComponent.merge(
  ///        a: const SnapComponent.size(component: Components.header),
  ///        b: const SnapComponent.size(component: Components.footer),
  ///        merge: (a, b) => a + b,
  ///      )
  ///    ])
  ///  ]);
  /// ```
  ///
  /// Throws an [AssertionError] if no models are provided.
  MultiSnappingBehavior({
    required this.models,
    super.clipByHeader,
  }) : assert(models.isNotEmpty, 'At least one snapping model must be provided');

  @override
  SplayTreeSet<double>? performSetup<T>(MultiStateSheetExtent<T> extent) {
    // Combine snapping offsets from all models.
    final snappingOffsets = SplayTreeSet<double>();
    for (final model in models) {
      snappingOffsets.addAll(model.getOffsets(extent).toList());
    }
    return snappingOffsets;
  }
}
