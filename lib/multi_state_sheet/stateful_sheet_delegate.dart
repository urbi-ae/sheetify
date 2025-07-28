import 'package:sheetify/sheetify.dart';

typedef StatefulFunctionDelegate<T, S> = T? Function(MultiStateSheetController<S> controller);

/// A sealed class that represents a delegate for the [MultiStateSheet].
sealed class StatefulSheetDelegate<T> {
  const StatefulSheetDelegate();

  /// Creates a [ToggleSheetDelegate] that holds a fixed [value].
  ///
  /// The [value] parameter specifies the value to be used by the delegate.
  ///
  /// Returns an instance of [ToggleSheetDelegateValue] with the provided [value].
  factory StatefulSheetDelegate.value(T value) => StatefulSheetDelegateValue<T>(value: value);

  /// Creates a [StatefulSheetDelegate] using a custom function that takes a [MultiStateSheetController]
  /// and returns an optional value of type [T]. This allows for dynamic control of the sheet's behavior
  /// based on the controller's state.
  ///
  /// The [function] parameter is a callback that receives the current [MultiStateSheetController]
  /// and returns a value of type [T] or null.
  static StatefulSheetDelegate<T> func<T, S>(StatefulFunctionDelegate<T, S> function) =>
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
      final StatefulSheetDelegateFunction<T, StateType> function => function.function(controller),
      _ => null,
    };
  }
}

/// A delegate that holds a static value.
class StatefulSheetDelegateValue<T> extends StatefulSheetDelegate<T> {
  const StatefulSheetDelegateValue({required this.value});

  final T value;
}

/// A delegate that holds a function that uses the [MultiStateSheetController] to calculate the value.
class StatefulSheetDelegateFunction<T, S> extends StatefulSheetDelegate<T> {
  const StatefulSheetDelegateFunction({required this.function});

  final T? Function(MultiStateSheetController<S> controller) function;
}
