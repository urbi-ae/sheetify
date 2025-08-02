import 'dart:math';

import 'package:flutter/widgets.dart';

/// Default value for correcting scroll velocity
/// to make sure sheet will be snapping to the closest state
/// and will not skip it due to velocity value
/// being used by framework to scroll to the start or the end of viewport.
const kVelocityCorrectionFactor = 10.0;

class SnappingSimulation extends Simulation {
  final double position;
  final double durationMultiplier;
  late final double velocityPixelsPerSecond;
  late final double _pixelSnapPosition;
  late final double duration;

  SnappingSimulation({
    required this.position,
    required double initialVelocity,
    required List<double> pixelSnapPositions,
    required Duration snapAnimationDuration,
    required this.durationMultiplier,
    required double forceMultiplier,
    super.tolerance,
  }) {
    _pixelSnapPosition =
        _getSnapPosition(initialVelocity * forceMultiplier, pixelSnapPositions);
    const mircosecondsInSecond = 1000000;
    duration = initialVelocity != 0
        ? max(
            snapAnimationDuration.inMicroseconds / mircosecondsInSecond,
            ((position - _pixelSnapPosition) / initialVelocity).abs() *
                durationMultiplier /
                mircosecondsInSecond)
        : snapAnimationDuration.inMicroseconds /
            mircosecondsInSecond *
            durationMultiplier;

    velocityPixelsPerSecond = (_pixelSnapPosition - position) / duration;
  }

  @override
  double dx(double time) {
    if (isDone(time)) {
      return 0.0;
    }

    return velocityPixelsPerSecond;
  }

  @override
  bool isDone(double time) =>
      (x(time) - _pixelSnapPosition).abs() <= tolerance.distance;

  @override
  double x(double time) {
    final double newPosition = position + velocityPixelsPerSecond * time;
    final distanceBetweenPositions = (newPosition - _pixelSnapPosition).abs();

    if (distanceBetweenPositions <= tolerance.distance || time >= duration) {
      return _pixelSnapPosition;
    }

    return newPosition;
  }

  double _getSnapPosition(
      double initialVelocity, List<double> pixelSnapPositions) {
    int nextStateIndex = -1;
    double velocity = initialVelocity;
    double distance = double.infinity;
    for (int i = 0; i < pixelSnapPositions.length; i++) {
      final abs = (pixelSnapPositions[i] - position - velocity * 0.75).abs();
      if (distance > abs) {
        distance = abs;
        nextStateIndex = i;
      }
      velocity *= 0.75; // Decrease velocity to avoid skipping states
    }

    if (nextStateIndex == 0) {
      return pixelSnapPositions.first;
    }

    if (nextStateIndex < 0) {
      nextStateIndex = pixelSnapPositions.length - 1;
    }

    if (initialVelocity < 0.0) {
      return pixelSnapPositions[nextStateIndex - 1];
    }
    return pixelSnapPositions[nextStateIndex];
  }
}
