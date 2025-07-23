import 'package:flutter/material.dart';

/// An [InheritedWidget] that notifies its descendants about changes in the
/// multi-state sheet's state.
///
/// [MultiStateSheetNotifier] provides a way to propagate state changes of type
/// [StateType] down the widget tree, allowing descendant widgets to react to
/// updates efficiently.
///
/// Typically used to manage and listen to state transitions in a multi-state
/// sheet widgets.
class MultiStateSheetNotifier<StateType> extends InheritedWidget {
  final StateType _state;
  final double _stateInterpolation;

  const MultiStateSheetNotifier({
    required StateType state,
    required double stateInterpolation,
    required super.child,
    super.key,
  })  : _state = state,
        _stateInterpolation = stateInterpolation;

  StateType get state => _state;

  double get stateInterpolation => _stateInterpolation;

  @override
  bool updateShouldNotify(MultiStateSheetNotifier<StateType> oldWidget) =>
      oldWidget._state != state || oldWidget.stateInterpolation != stateInterpolation;

  static MultiStateSheetNotifier<StateType>? of<StateType>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MultiStateSheetNotifier<StateType>>();
  }
}
