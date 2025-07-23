import 'package:sheetify/sheetify.dart';

/// A sealed class that represents a delegate for the bottom sheet.
sealed class ToggleSheetDelegate<T> {
  const ToggleSheetDelegate();

  /// Creates a [ToggleSheetDelegate] that holds a fixed [value].
  ///
  /// The [value] parameter specifies the value to be used by the delegate.
  ///
  /// Returns an instance of [ToggleSheetDelegateValue] with the provided [value].
  factory ToggleSheetDelegate.value(T value) => ToggleSheetDelegateValue<T>(value: value);

  /// Creates a [ToggleSheetDelegate] using a custom function that takes a [ToggleSheetController]
  /// and returns an optional value of type [T]. This allows for dynamic control of the sheet's behavior
  /// based on the controller's state.
  ///
  /// The [function] parameter is a callback that receives the current [ToggleSheetController]
  /// and returns a value of type [T] or null.
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

/// A delegate that holds a static value.
class ToggleSheetDelegateValue<T> extends ToggleSheetDelegate<T> {
  const ToggleSheetDelegateValue({required this.value});

  final T value;
}

/// A delegate that holds a function that uses the [ToggleSheetController] to calculate the value.
class ToggleSheetDelegateFunction<T> extends ToggleSheetDelegate<T> {
  const ToggleSheetDelegateFunction({required this.function});

  final T? Function(ToggleSheetController controller) function;
}
