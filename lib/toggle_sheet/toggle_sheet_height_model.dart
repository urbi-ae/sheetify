import 'package:sheetify/sheetify.dart';

/// Model used to calculate the fixed offset of the [ToggleSheet]
///
/// Use it then you need to your [ToggleSheet] be the fixed height.
sealed class ToggleSheetHeightModel {
  /// Returns the offset height for the [ToggleSheetController] to define min height.
  double getHeight(double availablePixels);

  /// Defines [ToggleSheet] height as [height] in pixels.
  ///
  /// For example [height] = `500` means the height of bottom sheet will be `500` pixels
  factory ToggleSheetHeightModel.fixed(double height) => FixedHeightModel(height);

  /// Defines [ToggleSheet] height from it's [offset] from the top of the screen.
  ///
  /// For example [offset] = `100` then `viewport height` is `800`, the height of bottom sheet will be `700` pixels
  factory ToggleSheetHeightModel.offset(double offset) => OffsetHeightModel(offset);

  /// Defines [ToggleSheet] height from [fraction] ratio of the `viewport` of the screen.
  ///
  /// For example [fraction] = `.9` then `viewport height` is `800`, the height of bottom sheet will be `720` pixels
  factory ToggleSheetHeightModel.fraction(double fraction) => FractionHeightModel(fraction);
}

/// Model used to calculate the fixed offset of the [ToggleSheet]
///
/// Use it then you need to your [ToggleSheet] be the fixed height.
///
/// Defines [ToggleSheet] height as [height] in pixels.
///
/// For example [height] = `500` means the height of bottom sheet will be `500` pixels
class FixedHeightModel implements ToggleSheetHeightModel {
  final double height;

  FixedHeightModel(this.height) : assert(height > 0.0, 'Height must be greater than zero');

  @override
  double getHeight(double availablePixels) {
    return availablePixels - height;
  }
}

/// Model used to calculate the fixed offset of the [ToggleSheet]
///
/// Use it then you need to your [ToggleSheet] be the fixed height to have a gap from the top of the screen.
///
/// Defines [ToggleSheet] height from it's [offset] from the top of the screen.
///
/// For example [offset] = `100` then `viewport height` is `800`, the height of bottom sheet will be `700` pixels
class OffsetHeightModel implements ToggleSheetHeightModel {
  final double offset;

  OffsetHeightModel(this.offset) : assert(offset >= 0.0, 'Offset must be equal or greater than zero');

  @override
  double getHeight(double availablePixels) {
    return offset;
  }
}

/// Model used to calculate the fixed offset of the [ToggleSheet]
///
/// Use it then you need to your [ToggleSheet] be the fixed height based on [fraction] ratio.
///
/// Defines [ToggleSheet] height from [fraction] ratio of the `viewport` of the screen.
///
/// For example [fraction] = `.9` then `viewport height` is `800`, the height of bottom sheet will be `720` pixels
class FractionHeightModel implements ToggleSheetHeightModel {
  final double fraction;

  FractionHeightModel(this.fraction)
      : assert(fraction >= 0.0 && fraction <= 1.0, 'Fraction must be between 0.0 and 1.0');

  @override
  double getHeight(double availablePixels) {
    return availablePixels * (1 - fraction);
  }
}
