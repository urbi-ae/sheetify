import 'package:sheetify/sheetify.dart';

typedef StatefulFunctionDelegate<T, S> = T? Function(
    MultiStateSheetController<S> controller);

/// A sealed class that represents a delegate for the [MultiStateSheet].
sealed class StatefulSheetDelegate<T> {
  const StatefulSheetDelegate();

  /// Creates a [ToggleSheetDelegate] that holds a fixed [value].
  ///
  /// The [value] parameter specifies the value to be used by the delegate.
  ///
  /// ⚠️ **Important:** You should create this delegate **outside** the widget's build method —
  /// ideally as a `final` field in a `State` class, or within a view model or other persistent scope.
  /// Avoid constructing it inline within `build()` to ensure consistency and performance.
  ///
  /// Returns an instance of [ToggleSheetDelegateValue] with the provided [value].
  factory StatefulSheetDelegate.value(T value) =>
      StatefulSheetDelegateValue<T>(value: value);

  /// Creates a [StatefulSheetDelegate] using a custom function that takes a [MultiStateSheetController]
  /// and returns an optional value of type [T]. This allows for dynamic control of the sheet's behavior
  /// based on the controller's state.
  ///
  /// ⚠️ **Important:** You should create this delegate **outside** the widget's build method —
  /// ideally as a `final` field in a `State` class, or within a view model or other persistent scope.
  /// Avoid constructing it inline within `build()` to ensure consistency and performance.
  ///
  /// The [function] parameter is a callback that receives the current [MultiStateSheetController]
  /// and returns a value of type [T] or null.
  static StatefulSheetDelegate<T> func<T, S>(
          StatefulFunctionDelegate<T, S> function) =>
      StatefulSheetDelegateFunction<T, S>(function: function);

  /// We need this method to get the value of the delegate if it is a static value.
  /// We want to avoid calling the function every time we need the value and we can use this method in [init()]
  /// to get the value of the delegate and store it in a variable.
  ///
  /// Example:
  /// ```dart
  /// class A {
  ///   double? value;
  ///   final StatefulSheetDelegate<T> valueDelegate;
  ///
  ///   A({required this.valueDelegate}) {
  ///     value = valueDelegate.getStaticValue();
  ///   }
  ///
  ///   ...
  ///
  ///   void foo() {
  ///     final z = value ?? valueDelegate.getValue(scrollController) ?? _defaultValue;
  ///   }
  /// }
  /// ```
  T? getStaticValue() {
    if (this is StatefulSheetDelegateValue<T>) {
      return (this as StatefulSheetDelegateValue<T>).value;
    }
    return null;
  }

  T? getValue<StateType>(MultiStateSheetController<StateType> controller) {
    return switch (this) {
      final StatefulSheetDelegateValue<T> value => value.value,
      final StatefulSheetDelegateFunction<T, StateType> function =>
        function.function(controller),
      _ => null,
    };
  }
}

/// A delegate that holds a static value.
///
/// This delegate always returns the same fixed value regardless of the sheet state or controller.
///
/// Typically used when you want to provide a constant value for a property of the sheet
/// that does not depend on the controller's state or animations.
///
/// ⚠️ **Important:** You should create this delegate **outside** the widget's build method —
/// ideally as a `final` field in a `State` class, or within a view model or other persistent scope.
/// Avoid constructing it inline within `build()` to ensure consistency and performance.
///
/// Example:
/// ```dart
/// final delegate = StatefulSheetDelegateValue<int>(value: 42);
/// ```
class StatefulSheetDelegateValue<T> extends StatefulSheetDelegate<T> {
  /// Creates a delegate with a fixed static [value].
  const StatefulSheetDelegateValue({required this.value});

  /// The fixed value returned by this delegate.
  final T value;
}

/// A delegate that holds a function which uses the [MultiStateSheetController]
/// to compute a dynamic value.
///
/// This delegate allows you to provide a callback function that receives the current
/// [MultiStateSheetController] with its generic state type [S], enabling you to
/// return a value of type [T] based on the controller's current state or animation.
///
/// Useful for creating dynamic, responsive properties that update as the sheet
/// moves or changes state.
///
/// ⚠️ **Important:** You should create this delegate **outside** the widget's build method —
/// ideally as a `final` field in a `State` class, or within a view model or other persistent scope.
/// Avoid constructing it inline within `build()` to ensure consistency and performance.
///
/// Example:
/// ```dart
/// final delegate = StatefulSheetDelegateFunction<int, MySheetState>(
///   function: (controller) {
///     if (controller.currentState == MySheetState.expanded) {
///       return 100;
///     }
///     return 50;
///   },
/// );
/// ```
class StatefulSheetDelegateFunction<T, S> extends StatefulSheetDelegate<T> {
  /// Creates a delegate with a function [function] that calculates the value
  /// dynamically based on the given [MultiStateSheetController].
  const StatefulSheetDelegateFunction({required this.function});

  /// A function that receives the current [MultiStateSheetController] and returns
  /// a value of type [T] or null.
  final T? Function(MultiStateSheetController<S> controller) function;
}
