import 'package:flutter/foundation.dart';
import 'package:sheetify/utils/constants.dart';

@immutable
class SheetWidgetSizes {
  final double topHeader;
  final double header;
  final double content;
  final double footer;

  const SheetWidgetSizes({
    required this.topHeader,
    required this.header,
    required this.content,
    required this.footer,
  });

  @override
  int get hashCode => topHeader.hashCode ^ header.hashCode ^ content.hashCode ^ footer.hashCode;

  @override
  bool operator ==(Object other) {
    return other is SheetWidgetSizes &&
        other.topHeader == topHeader &&
        other.header == header &&
        other.content == content &&
        other.footer == footer;
  }

  const SheetWidgetSizes.zero()
      : topHeader = kZeroHeight,
        header = kZeroHeight,
        content = kZeroHeight,
        footer = kZeroHeight;

  bool get isZero =>
      topHeader == kZeroHeight && header == kZeroHeight && content == kZeroHeight && footer == kZeroHeight;

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
