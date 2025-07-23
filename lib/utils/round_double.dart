import 'dart:math';

/// The basic round factor.
const roundFactor = 1000000000000;

/// Extension on double to add rounding to length
extension RoundDouble on double {
  /// Rounds value to the decimal places
  double roundDecimal({int? places}) {
    if (isNaN || isInfinite) {
      return this;
    }

    final factor = places != null ? pow(10, places) : roundFactor;

    return (this * factor).round() / factor;
  }
}
