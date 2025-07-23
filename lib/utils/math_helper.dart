import 'dart:ui';

/// Lerp value [t] between [minValue] and [maxValue]
/// based on the [tmin] and [tmax] values.
///
/// Normalize value [t] by [tmin] and [tmax] and return the
/// linearly interpolated value between [minValue] and [maxValue].
double lerpBetween(
  double t,
  double minValue,
  double maxValue,
  double tmin,
  double tmax,
) {
  return lerpDouble(
        minValue,
        maxValue,
        normalize(t, tmin, tmax),
      )?.clamp(minValue, maxValue) ??
      t;
}

/// Normalizes [t] value by [min] and [max] values
double normalize(double t, double min, double max) {
  return (t - min) / (max - min);
}
