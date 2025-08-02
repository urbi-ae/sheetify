import 'package:sheetify/sheetify.dart';

/// A sealed class that represents a delegate for the sheet.
sealed class ToggleSheetDelegate<T> {
  const ToggleSheetDelegate();

  /// Creates a [ToggleSheetDelegate] that holds a fixed [value].
  ///
  /// The [value] parameter specifies the value to be used by the delegate.
  ///
  /// ⚠️ **Important:** You should create this delegate **outside** the widget's build method —
  /// ideally as a `final` field in a `State` class, or within a view model or other persistent scope.
  /// Avoid constructing it inline within `build()` to ensure consistency and performance.
  ///
  /// Returns an instance of [ToggleSheetDelegateValue] with the provided [value].
  factory ToggleSheetDelegate.value(T value) => ToggleSheetDelegateValue<T>(value: value);

  /// Creates a [ToggleSheetDelegate] using a custom function that takes a [ToggleSheetController]
  /// and returns an optional value of type [T]. This allows for dynamic control of the sheet's behavior
  /// based on the controller's state.
  ///
  /// The [function] parameter is a callback that receives the current [ToggleSheetController]
  /// and returns a value of type [T] or null.
  ///
  /// ⚠️ **Important:** You should create this delegate **outside** the widget's build method —
  /// ideally as a `final` field in a `State` class, or within a view model or other persistent scope.
  /// Avoid constructing it inline within `build()` to ensure consistency and performance.
  ///
  /// Returns an instance of [ToggleSheetDelegateFunction] with the provided [function].
  factory ToggleSheetDelegate.func(T? Function(ToggleSheetController controller) function) =>
      ToggleSheetDelegateFunction<T>(function: function);

  /// We need this method to get the value of the delegate if it is a static value.
  /// We want to avoid calling the function every time we need the value and we can use this method in [init()]
  /// to get the value of the delegate and store it in a variable.
  ///
  /// Example:
  /// ```dart
  /// class A {
  ///   double? value;
  ///   final StatelessSheetDelegate<T> valueDelegate;
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
    if (this is ToggleSheetDelegateValue<T>) {
      return (this as ToggleSheetDelegateValue<T>).value;
    }
    return null;
  }

  T? getValue<K>(ToggleSheetController controller) {
    return switch (this) {
      final ToggleSheetDelegateValue<T> value => value.value,
      final ToggleSheetDelegateFunction<T> function => function.function(controller),
    };
  }
}

/// A delegate that always returns a constant, static value.
///
/// This is useful when the value controlling sheet behavior (e.g., `barrierColor`)
/// is fixed and does not need to respond to dynamic state or controller input.
///
/// Typically used like this:
///
/// ```dart
/// barrierColorDelegate: ToggleSheetDelegate.value(Colors.black.withOpacity(0.5))
/// ```
///
/// ⚠️ It is recommended to initialize this delegate as a final field (e.g., in your `State` class),
/// not directly inside the `build()` method, to avoid unnecessary widget rebuilds.
class ToggleSheetDelegateValue<T> extends ToggleSheetDelegate<T> {
  /// Creates a [ToggleSheetDelegateValue] with a constant [value].
  const ToggleSheetDelegateValue({required this.value});

  /// The constant value returned by the delegate.
  final T value;
}

/// A delegate that dynamically computes a value based on the [ToggleSheetController] state.
///
/// Useful when you need to interpolate, animate, or conditionally change sheet visuals
/// depending on the current state of the sheet (e.g., position, snapping progress).
///
/// For example:
///
/// ```dart
/// barrierColorDelegate: ToggleSheetDelegate.func(
///   (controller) => Colors.black.withOpacity(controller.interpolation * 0.6),
/// )
/// ```
///
/// ⚠️ Like all `ToggleSheetDelegate`s, this should be created **outside** of the widget `build()` method,
/// ideally as a `final` field inside your `State` class or a separate function,
/// to prevent unnecessary re-evaluation and performance issues.
class ToggleSheetDelegateFunction<T> extends ToggleSheetDelegate<T> {
  /// Creates a [ToggleSheetDelegateFunction] using a [function] that takes the sheet controller.
  ///
  /// The function returns a value of type [T].
  const ToggleSheetDelegateFunction({required this.function});

  /// Function that computes a value from the current controller state.
  final T? Function(ToggleSheetController controller) function;
}
