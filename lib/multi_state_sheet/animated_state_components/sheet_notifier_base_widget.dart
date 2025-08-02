import 'package:flutter/widgets.dart';
import 'package:sheetify/multi_state_sheet/animated_state_components/multi_state_sheet_notifier.dart';

/// A base class for creating sheet's state aware stateless animated widgets
/// based on [ValueNotifier].
///
/// This class provides a structure for building sheet components that
/// respond to state changes and animations.
abstract class SheetValueNotifierWidget<StateType>
    extends SheetStateNotifierStatefulWidget<StateType> {
  /// The default state used when no state is available.
  final StateType defaultState;

  /// Constructs a [SheetValueNotifierWidget].
  ///
  /// - [defaultState]: The initial or fallback state for the component.
  const SheetValueNotifierWidget({required this.defaultState, super.key});

  /// Builds the widget based on the current state and animation interpolation.
  ///
  /// - [context]: The [BuildContext] for the widget.
  /// - [state]: The [ValueNotifier] current state of the sheet.
  /// - [interpolation]: A [ValueNotifier] with a value between `0.0` and `1.0` representing the animation progress.
  Widget build(
    BuildContext context,
    ValueNotifier<StateType> state,
    ValueNotifier<double> interpolation,
  );

  @override
  _SheetComponentState<StateType> createState() =>
      _SheetComponentState<StateType>();
}

/// The state for a stateful sheet widget.
///
/// This class provides the context to access the sheet's current state and interpolation.
class _SheetComponentState<StateType>
    extends _SheetNotifierBaseState<SheetValueNotifierWidget<StateType>> {
  late final ValueNotifier<StateType> _state;
  late final ValueNotifier<double> _interpolation;

  @override
  void initState() {
    super.initState();

    _state = ValueNotifier(widget.defaultState);
    _interpolation = ValueNotifier(0.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = MultiStateSheetNotifier.of<StateType>(context);
    if (state != null) {
      _state.value = state.state;
      _interpolation.value = state.stateInterpolation;
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(
        context,
        _state,
        _interpolation,
      );
}

/// A base class for creating sheet's state aware stateful animated widgets.
///
/// This class serves as the foundation for all animated widgets that interact with
/// the sheet's state and respond to state changes.
abstract class SheetStateNotifierStatefulWidget<StateType>
    extends StatefulWidget {
  const SheetStateNotifierStatefulWidget({super.key});

  @override
  _SheetComponentState<StateType> createState();
}

/// A base class for the state of sheet animated widgets.
///
/// This class provides the structure for managing the state of animated widgets
/// in the sheet and allows access to the widget instance.
abstract class _SheetNotifierBaseState<
    T extends SheetStateNotifierStatefulWidget<dynamic>> extends State<T> {}
