import 'package:flutter/foundation.dart';
import 'package:sheetify/utils/constants.dart';

@immutable

/// A utility class that provides constants related to sizing of sheet widgets.
///
/// Use this class to manage and standardize the dimensions of widgets used in sheet layouts
/// throughout the application.
class SheetWidgetSizes {
  final double topHeader;
  final double header;
  final double content;
  final double footer;

  /// Creates an instance of [SheetWidgetSizes].
  const SheetWidgetSizes({
    required this.topHeader,
    required this.header,
    required this.content,
    required this.footer,
  });

  @override
  int get hashCode =>
      topHeader.hashCode ^ header.hashCode ^ content.hashCode ^ footer.hashCode;

  @override
  bool operator ==(Object other) {
    return other is SheetWidgetSizes &&
        other.topHeader == topHeader &&
        other.header == header &&
        other.content == content &&
        other.footer == footer;
  }

  /// A constant constructor that creates an instance of [SheetWidgetSizes] with all size values set to zero.
  const SheetWidgetSizes.zero()
      : topHeader = kZeroHeight,
        header = kZeroHeight,
        content = kZeroHeight,
        footer = kZeroHeight;

  /// Returns `true` if the value is considered zero, otherwise `false`.
  bool get isZero =>
      topHeader == kZeroHeight &&
      header == kZeroHeight &&
      content == kZeroHeight &&
      footer == kZeroHeight;

  /// Creates a copy of this [SheetWidgetSizes] with the given fields replaced by new values.
  ///
  /// Any fields that are not provided will retain their current values.
  ///
  /// Returns a new [SheetWidgetSizes] instance with updated properties.
  SheetWidgetSizes copyWith({
    double? topHeader,
    double? header,
    double? content,
    double? footer,
  }) =>
      SheetWidgetSizes(
        topHeader: topHeader ?? this.topHeader,
        header: header ?? this.header,
        content: content ?? this.content,
        footer: footer ?? this.footer,
      );
}
