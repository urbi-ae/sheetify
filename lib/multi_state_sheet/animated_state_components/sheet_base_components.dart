import 'package:flutter/material.dart';
import 'package:sheetify/sheetify.dart';

/// A function type used to build sheet's state aware animated widgets.
///
/// - [context]: The [BuildContext] for the widget.
/// - [state]: The current state of the sheet.
/// - [interpolation]: A value between `0.0` and `1.0` representing the animation progress.
/// - [child]: An optional child widget to optimize builds.
typedef MultiStateSheetAnimatedWidgetBuilder<StateType> = Widget Function(
  BuildContext context,
  StateType state,
  double interpolation,
  Widget? child,
);

/// A widget that builds a sheet component based on a given builder function.
///
/// This widget simplifies the creation of animated sheet widgets by
/// delegating the build logic to a [MultiStateSheetAnimatedWidgetBuilder].
final class MultiStateSheetBuilder<StateType>
    extends SheetAnimatedWidget<StateType> {
  /// Constructs a [MultiStateSheetBuilder].
  ///
  /// - [builder]: The function responsible for building the component based on the
  ///   current state and animation progress.
  /// - [defaultState]: The initial or fallback state for the sheet.
  /// - [child]: An optional child widget for optimized builds.
  const MultiStateSheetBuilder({
    required MultiStateSheetAnimatedWidgetBuilder<StateType> builder,
    required super.defaultState,
    super.key,
    Widget? child,
  })  : _builder = builder,
        _child = child;

  /// The builder function for creating the sheet component.
  final MultiStateSheetAnimatedWidgetBuilder<StateType> _builder;

  /// An optional child widget for optimized builds.
  final Widget? _child;

  @override
  Widget build(
    BuildContext context,
    StateType state,
    double interpolation,
  ) =>
      _builder(context, state, interpolation, _child);
}

/// A base class for creating sheet's state aware stateless animated widget.
///
/// This class provides a structure for building sheet components that
/// respond to state changes and animations.
abstract class SheetAnimatedWidget<StateType>
    extends SheetAnimatedStatefulWidget<StateType> {
  /// The default state used when no state is available.
  final StateType defaultState;

  /// Constructs a [SheetAnimatedWidget].
  ///
  /// - [defaultState]: The initial or fallback state for the component.
  const SheetAnimatedWidget({required this.defaultState, super.key});

  /// Builds the widget based on the current state and animation interpolation.
  ///
  /// - [context]: The [BuildContext] for the widget.
  /// - [state]: The current state of the sheet.
  /// - [interpolation]: A value between `0.0` and `1.0` representing the animation progress.
  Widget build(
    BuildContext context,
    StateType state,
    double interpolation,
  );

  @override
  _SheetComponentState<StateType> createState() =>
      _SheetComponentState<StateType>();
}

/// The state for a stateful sheet widget.
///
/// This class provides the context to access the sheet's current state and interpolation.
class _SheetComponentState<StateType>
    extends _SheetComponentBaseState<SheetAnimatedWidget<StateType>> {
  @override
  Widget build(BuildContext context) {
    final state = MultiStateSheetNotifier.of<StateType>(context);

    return widget.build(
      context,
      state?.state ??
          widget
              .defaultState, // Use the notifier's state or fallback to the default.
      state?.stateInterpolation ??
          0.0, // Default interpolation is `0.0` when unavailable.
    );
  }
}

/// A base class for creating sheet's state aware stateful animated widgets.
///
/// This class serves as the foundation for all animated widgets that interact with
/// the sheet's state and respond to state changes.
abstract class SheetAnimatedStatefulWidget<StateType> extends StatefulWidget {
  const SheetAnimatedStatefulWidget({super.key});

  @override
  _SheetComponentState<StateType> createState();
}

/// A base class for the state of sheet animated widgets.
///
/// This class provides the structure for managing the state of animated widgets
/// in the sheet and allows access to the widget instance.
abstract class _SheetComponentBaseState<
    T extends SheetAnimatedStatefulWidget<dynamic>> extends State<T> {}
