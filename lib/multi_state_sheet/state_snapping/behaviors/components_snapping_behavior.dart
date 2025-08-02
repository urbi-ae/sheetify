import 'dart:collection';

import 'package:sheetify/sheetify.dart';

/// A snapping behavior that calculates snapping offsets based on component descriptions.
///
/// This behavior determines snapping positions by using a list of [SnapComponent] descriptions
/// and their associated [ComponentsSnappingModel]. It provides smooth transitions between
/// states and ensures offsets respect the available space of the sheet.
final class ComponentsSnappingBehavior extends SnappingBehavior {
  /// A list of component descriptions used to calculate snapping positions.
  ///
  /// Each [SnapComponent] represents a part of the sheet (e.g., header, content, footer)
  /// and defines its snapping logic.
  final List<SnapComponent> componentDescriptions;

  /// The snapping model used to compute offsets based on the component descriptions.
  final ComponentsSnappingModel model;

  /// Constructs a [ComponentsSnappingBehavior] with the specified component descriptions.
  ///
  /// - [componentDescriptions]: A list of [SnapComponent] instances defining the snapping behavior.
  ///
  /// ### Example:
  /// ```dart
  /// ComponentsSnappingBehavior(
  ///   componentDescriptions: [
  ///     SnapComponent.size(component: Components.header, size: 0.5),
  ///     SnapComponent.offset(component: Components.footer, size: 1.0, offset: 50.0),
  ///   ],
  /// );
  /// ```
  ComponentsSnappingBehavior({
    required this.componentDescriptions,
    super.clipByHeader,
  }) : model = ComponentsSnappingModel(
            componentsDescriptions: componentDescriptions);

  @override
  SplayTreeSet<double>? performSetup<T>(MultiStateSheetExtent<T> extent) =>
      model.getOffsets(extent);
}
