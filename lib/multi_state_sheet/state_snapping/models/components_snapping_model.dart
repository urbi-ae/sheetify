import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sheetify/sheetify.dart';

typedef OffsetMap = double Function(double offset);
typedef OffsetMerge = double Function(double a, double b);

/// Enum representing the various components of a [MultiStateSheet] layout.
///
/// Each component corresponds to a specific layer inside the [MultiStateSheet],
/// used to define snapping positions and sizes for the snapping model.
enum Components {
  /// Represents the header section of the [MultiStateSheet].
  header,

  /// Represents the top section, which is drawn behind on top of the [header].
  top,

  /// Represents the main content section of the [MultiStateSheet].
  content,

  /// Represents the footer section at the bottom of the [MultiStateSheet].
  footer,
}

/// Represents a snapping model for calculating snapping positions and states based on the sizes of [Widget]s in a MultiStateSheet.
/// It generates snapping positions using the provided descriptions of components.
///
/// This model is used inside the sheet [SnappingBehavior] UX objects.
final class ComponentsSnappingModel extends SnappingModel {
  final List<SnapComponent> componentsDescriptions;

  /// Represents a snapping model for calculating snapping positions and states based on the sizes of [Widget]s in a MultiStateSheet.
  /// It generates snapping positions using the provided descriptions of components.
  ///
  /// This model is used inside the sheet [SnappingBehavior] UX objects.
  ComponentsSnappingModel({required this.componentsDescriptions});

  double getOffsetFromDescriptor<T>(
      MultiStateSheetExtent<T> extent, SnapComponent descriptor) {
    if (extent.maxOffset <= 0.0) {
      return extent.maxOffset;
    }

    final size = descriptor.getSize(extent);
    return max(0.0, min(extent.availablePixels - size, extent.safeMaxOffset));
  }

  @override
  SplayTreeSet<double> getOffsets<T>(MultiStateSheetExtent<T> extent) =>
      SplayTreeSet.of(componentsDescriptions
          .map((descriptor) => getOffsetFromDescriptor(extent, descriptor)));
}

/// Abstract base class for snap components, providing a contract for calculating the size of components within a snapping behavior.
@immutable
abstract class SnapComponent {
  const SnapComponent();

  /// Factory constructor to create a [SnapComponentSize] with the specified component and size.
  ///
  /// - [component]: The component to associate with this snap size.
  /// - [size]: A multiplier for the component's base size. Must be non-negative.
  const factory SnapComponent.size({
    required Components component,
    double size,
  }) = SnapComponentSize;

  /// Factory constructor to create a [SnapComponentWithOffset] with a component, size, and offset.
  ///
  /// - [component]: The component to associate with this snap size and offset.
  /// - [offset]: The additional pixel offset to add to the size.
  /// - [size]: A multiplier for the component's base size. Must be non-negative.
  const factory SnapComponent.offset({
    required Components component,
    double offset,
    double size,
  }) = SnapComponentWithOffset;

  /// Factory constructor to create a [SnapComponentWithOffsetFraction], which combines a size multiplier
  /// and an fraction relative to the viewport.
  ///
  /// - [component]: The component to associate with this snap size and fraction.
  /// - [fraction]: A fraction (0.0 to 1.0) of viewport to add to the size.
  /// - [size]: A multiplier for the component's base size. Must be non-negative.
  const factory SnapComponent.fractionOffset({
    required Components component,
    double fraction,
    double size,
  }) = SnapComponentWithOffsetFraction;

  /// Factory constructor to create a [SnapComponentAtPosition], which stops at a specific pixel position.
  ///
  /// - [component]: The component to associate with this position.
  /// - [position]: The fixed pixel position for the snap point.
  const factory SnapComponent.position({
    required Components component,
    required double position,
  }) = SnapComponentAtPosition;

  /// Factory constructor to create a [SnapComponentAtFraction], which stops at a specific fraction position.
  ///
  /// - [component]: The component to associate with this fraction.
  /// - [fraction]: The fraction of the viewport to calculate the position.
  const factory SnapComponent.fraction({
    required Components component,
    required double fraction,
  }) = SnapComponentAtFraction;

  /// Factory constructor to create a [SnapComponentMap], which applies a mapping function to another [SnapComponent].
  ///
  /// - [component]: The base component whose size will be mapped.
  /// - [map]: The mapping function to transform the size of the component.
  const factory SnapComponent.map(
    SnapComponent component, {
    required OffsetMap map,
  }) = SnapComponentMap;

  /// Factory constructor to create a [SnapComponentMerge], which merges the sizes of two components.
  ///
  /// - [a]: The first component in the merge.
  /// - [b]: The second component in the merge.
  /// - [merge]: The function to combine the sizes of the two components.
  const factory SnapComponent.merge({
    required SnapComponent a,
    required SnapComponent b,
    required OffsetMerge merge,
  }) = SnapComponentMerge;

  /// Calculates the size of the snap component relative to the provided extent.
  ///
  /// - [extent]: The available space and configuration of the [MultiStateSheet].
  /// - Returns the calculated size.
  double getSize<T>(MultiStateSheetExtent<T> extent);

  /// Gets the base size of the specified component relative to the extent's initial configuration.
  ///
  /// - [extent]: The available space and configuration of the [MultiStateSheet].
  /// - [component]: The component whose base size is requested.
  /// - Returns the base size of the specified component.
  double getComponentSize<T>(
          MultiStateSheetExtent<T> extent, Components component) =>
      switch (component) {
        Components.header => extent.initialComponentSizes.header,
        Components.top => extent.initialComponentSizes.topHeader,
        Components.content => extent.initialComponentSizes.content,
        Components.footer => extent.initialComponentSizes.footer,
      };

  /// Gets the offset of the specified component from the top of viewport.
  ///
  /// - [extent]: The available space and configuration of the [MultiStateSheet].
  /// - [component]: The component whose offset from the top is requested.
  /// - Returns the offset of the specified component.
  double getComponentOffsetFromTop<T>(
          MultiStateSheetExtent<T> extent, Components component) =>
      switch (component) {
        Components.header => 0.0,
        Components.top => -extent.initialComponentSizes.topHeader,
        Components.content => extent.initialComponentSizes.header,
        Components.footer =>
          extent.offset - extent.initialComponentSizes.footer,
      };
}

/// Represents a snap component with a specified size based on a multiplier of the component's initial size.

class SnapComponentSize extends SnapComponent {
  final Components component;
  final double size;

  /// Represents a snap component with a specified size based on a multiplier of the component's initial size.
  ///
  /// - [component]: The component to associate with this snap size.
  /// - [size]: A multiplier for the component's base size. Must be non-negative.
  const SnapComponentSize({
    required this.component,
    this.size = 1.0,
  }) : assert(size >= 0.0, 'Component size can not be negative');

  @override
  String toString() => '$component with size: $size';

  @override
  double getSize<T>(MultiStateSheetExtent<T> extent) => clampDouble(
        getComponentSize(extent, component) * size,
        extent.minOffset,
        extent.maxOffset,
      );
}

/// Represents a snap component with a specified size and an additional pixel offset.
class SnapComponentWithOffset extends SnapComponent {
  final Components component;
  final double size;
  final double offset;

  /// Represents a snap component with a specified size and an additional pixel offset.
  ///
  /// - [component]: The component to associate with this snap size and offset.
  /// - [offset]: The additional pixel offset to add to the size.
  /// - [size]: A multiplier for the component's base size. Must be non-negative.
  const SnapComponentWithOffset({
    required this.component,
    this.offset = 0.0,
    this.size = 1.0,
  }) : assert(size >= 0.0, 'Component size can not be negative');

  @override
  String toString() => '$component with size: $size, and offset: $offset';

  @override
  double getSize<T>(MultiStateSheetExtent<T> extent) => clampDouble(
        getComponentSize(extent, component) * size + offset,
        extent.minOffset,
        extent.maxOffset,
      );
}

/// Represents a snap component with a size and an fraction, where the fraction is a fraction of viewport.
class SnapComponentWithOffsetFraction extends SnapComponent {
  final Components component;
  final double size;
  final double fraction;

  /// Represents a snap component with a size and an fraction, where the fraction is a fraction of viewport.
  ///
  /// - [component]: The component to associate with this snap size and fraction.
  /// - [fraction]: A fraction (0.0 to 1.0) of viewport to add to the size.
  /// - [size]: A multiplier for the component's base size. Must be non-negative.
  const SnapComponentWithOffsetFraction({
    required this.component,
    this.fraction = 0.0,
    this.size = 1.0,
  })  : assert(size >= 0.0, 'Component size can not be negative'),
        assert(
          fraction >= 0.0 || fraction <= 1.0,
          'Fraction should be in the range from `0.0` to `1.0`',
        );

  @override
  String toString() => '$component with size: $size, and fraction: $fraction';

  @override
  double getSize<T>(MultiStateSheetExtent<T> extent) => clampDouble(
        getComponentSize(extent, component) * size +
            fraction * extent.availablePixels,
        extent.minOffset,
        extent.maxOffset,
      );
}

/// Represents a snap component that stops at a specific pixel position in the MultiStateSheet.
class SnapComponentAtPosition extends SnapComponent {
  final Components component;
  final double position;

  /// Represents a snap component that stops at a specific pixel position in the MultiStateSheet.
  ///
  /// - [component]: The component to associate with this position.
  /// - [position]: The fixed pixel position for the snap point.
  const SnapComponentAtPosition({
    required this.component,
    required this.position,
  });

  @override
  String toString() => '$component at position: $position';

  @override
  double getSize<T>(MultiStateSheetExtent<T> extent) => clampDouble(
        position - getComponentOffsetFromTop(extent, component),
        extent.minOffset,
        extent.maxOffset,
      );
}

/// Represents a snap component that stops at a specified fraction position.
class SnapComponentAtFraction extends SnapComponent {
  final Components component;
  final double fraction;

  /// Represents a snap component that stops at a specified fraction position.
  ///
  /// - [component]: The component to associate with this fraction.
  /// - [fraction]: The fraction of the viewport to calculate the position.
  const SnapComponentAtFraction({
    required this.component,
    required this.fraction,
  });

  @override
  String toString() => '$component at fraction position: $fraction';

  @override
  double getSize<T>(MultiStateSheetExtent<T> extent) => clampDouble(
        fraction * extent.availablePixels +
            getComponentOffsetFromTop(extent, component),
        extent.minOffset,
        extent.maxOffset,
      );
}

/// A wrapper around a snap component that applies a mapping function to its size.
class SnapComponentMap extends SnapComponent {
  final SnapComponent component;
  final OffsetMap map;

  /// A wrapper around a snap component that applies a mapping function to its size.
  ///
  /// - [component]: The base component whose size will be mapped.
  /// - [map]: The mapping function to transform the size of the component.
  const SnapComponentMap(
    this.component, {
    required this.map,
  });

  @override
  String toString() => '$component mapped';

  @override
  double getSize<T>(MultiStateSheetExtent<T> extent) =>
      map(component.getSize(extent));
}

/// A snap component that merges the sizes of two components using a custom merge function.
class SnapComponentMerge extends SnapComponent {
  final SnapComponent a;
  final SnapComponent b;
  final OffsetMerge merge;

  /// A snap component that merges the sizes of two components using a custom merge function.
  ///
  /// - [a]: The first component in the merge.
  /// - [b]: The second component in the merge.
  /// - [merge]: The function to combine the sizes of the two components.
  const SnapComponentMerge({
    required this.a,
    required this.b,
    required this.merge,
  });

  @override
  String toString() => '$a and $b merged';

  @override
  double getSize<T>(MultiStateSheetExtent<T> extent) =>
      merge(a.getSize(extent), b.getSize(extent));
}
