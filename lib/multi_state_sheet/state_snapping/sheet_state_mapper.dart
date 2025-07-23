import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sheetify/sheetify.dart';

enum ThreeStateSheet {
  /// Displays only the header
  hidden,

  /// Displays header with comfortably visible content
  open,

  /// Take all available space
  expanded,
}

enum FourStateSheet {
  /// Displays only the header
  hidden,

  /// Displays header with a small part of content
  halfOpen,

  /// Displays header with comfortably visible content
  open,

  /// Take all available space
  expanded,
}

/// Base interface to create new state handlers for bottom sheet pages.
abstract interface class SheetStateMapper<T> {
  const SheetStateMapper();

  /// Returns mapped state for a given index.
  T state(int state);

  /// Returns state index for a given state.
  int index(T state);

  /// Controls how bottom sheet should react on `pop` events.
  bool shouldPopOn(MultiStateSheetController<T> controller);
}

/// State handler for pages that only have `3` different states.
///
/// Which are described in [ThreeStateSheet] enum.
final class ThreeStateMapper implements SheetStateMapper<ThreeStateSheet> {
  const ThreeStateMapper();

  @override
  ThreeStateSheet state(int state) {
    return switch (state) {
      0 => ThreeStateSheet.hidden,
      1 => ThreeStateSheet.open,
      _ => ThreeStateSheet.expanded,
    };
  }

  @override
  int index(ThreeStateSheet state) {
    return state.index.clamp(0, 2);
  }

  @override
  bool shouldPopOn(MultiStateSheetController<ThreeStateSheet> controller) {
    switch (controller.closestState) {
      case ThreeStateSheet.hidden:
        controller.reset();
        return true;

      case ThreeStateSheet.open:
        controller.setState(ThreeStateSheet.hidden);
        return false;

      case ThreeStateSheet.expanded:
        controller.setState(ThreeStateSheet.open);
        return false;
    }
  }
}

/// State handler for pages that only have `4` different states.
///
/// Which are described in [FourStateSheet] enum.
final class FourStateMapper implements SheetStateMapper<FourStateSheet> {
  const FourStateMapper();

  @override
  FourStateSheet state(int state) {
    return FourStateSheet.values.elementAtOrNull(state) ?? FourStateSheet.expanded;
  }

  @override
  int index(FourStateSheet state) {
    return state.index;
  }

  @override
  bool shouldPopOn(MultiStateSheetController<dynamic> controller) {
    final closestState = controller.closestState as FourStateSheet;
    switch (closestState) {
      case FourStateSheet.hidden:
        controller.reset();
        return true;

      case FourStateSheet.halfOpen:
        controller.setState(FourStateSheet.hidden);
        return false;

      case FourStateSheet.open:
        controller.setState(FourStateSheet.halfOpen);
        return false;

      case FourStateSheet.expanded:
        controller.setState(FourStateSheet.open);
        return false;
    }
  }

  /// Delegate method for calculate barrier color inside sheet.
  static const StatefulSheetDelegateFunction<Color?, FourStateSheet> barrierColorDelegate =
      StatefulSheetDelegateFunction<Color?, FourStateSheet>(function: _barrierColorDelegate);

  /// Delegate method for calculate barrier color inside sheet.
  static Color? _barrierColorDelegate(MultiStateSheetController<FourStateSheet> controller) {
    final state = controller.state;
    final interpolation = controller.interpolation;

    if (state == FourStateSheet.hidden || state == FourStateSheet.expanded) {
      return null;
    }

    const black = Color(0xff000000);
    if (state == FourStateSheet.open) {
      return black.withAlpha((max(0.0, state.index - interpolation * 2 - 1) * 0.7 * 255).round());
    }

    return black.withAlpha(((state.index + interpolation - 1) * 0.7 * 255).round());
  }
}

/// A generic state handler for cases where a page can use any number of states.
final class IntStateMapper implements SheetStateMapper<int> {
  const IntStateMapper();

  @override
  int index(int state) => state;

  @override
  bool shouldPopOn(MultiStateSheetController<int> controller) {
    final closestState = controller.closestState;
    if (closestState == 0) {
      return true;
    } else {
      controller.setState(closestState - 1);
      return false;
    }
  }

  @override
  int state(int state) => state;
}
