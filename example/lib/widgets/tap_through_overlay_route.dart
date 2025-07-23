import 'package:flutter/material.dart';

class TapThroughOverlayRoute<T> extends ModalRoute<T> {
  final Duration _transitionDuration;
  final WidgetBuilder builder;

  TapThroughOverlayRoute({
    required this.builder,
    Duration transitionDuration = Duration.zero,
    super.settings,
  }) : _transitionDuration = transitionDuration;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => '';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildModalBarrier() {
    return const SizedBox.shrink();
  }

  @override
  bool get maintainState => true;
}
