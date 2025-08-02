import 'dart:ui';

import 'package:sheetify/sheetify.dart';

class MockMultiStateSheetExtent<StateType>
    implements MultiStateSheetExtent<StateType> {
  @override
  double availablePixels;

  @override
  SheetWidgetSizes componentSizes;

  @override
  SheetWidgetSizes initialComponentSizes;

  @override
  bool isAnimatingOpen = false;

  @override
  bool isEnabled = true;

  @override
  bool isPreformingResize = false;
  MockMultiStateSheetExtent({
    required this.availablePixels,
    double? minOffset,
    double? maxOffset,
    this.initialComponentSizes = const SheetWidgetSizes.zero(),
    this.offset = 0,
    SnappingBehavior? behavior,
  })  : componentSizes = initialComponentSizes,
        _minOffset = minOffset,
        _maxOffset = maxOffset,
        behavior = behavior ?? FractionSnappingBehavior(fractions: {0.0, 1.0});

  @override
  void addPixelDelta(double delta) {}

  @override
  int get anchoredState => throw UnimplementedError();

  @override
  SnappingBehavior behavior;

  @override
  int get currentState => 0;

  @override
  double get durationMultiplier => throw UnimplementedError();

  @override
  int get initialState => 0;

  @override
  bool get isAtMax => throw UnimplementedError();

  @override
  bool get isAtMin => throw UnimplementedError();

  final double? _minOffset;

  @override
  double get minOffset => _minOffset ?? behavior.minOffset;

  final double? _maxOffset;

  @override
  double get maxOffset {
    final maxHeight = _maxOffset ?? behavior.maxOffset;
    return maxHeight > minOffset ? maxHeight : availablePixels;
  }

  @override
  double get safeMaxOffset => maxOffset;

  @override
  double offset;

  @override
  VoidCallback? get onOffsetChanged => throw UnimplementedError();

  @override
  VoidCallback? get onStateChanged => throw UnimplementedError();

  @override
  Duration? get snapAnimationDuration => throw UnimplementedError();

  @override
  void startActivity({required VoidCallback onCanceled}) {}

  @override
  double get stateInterpolation => 0.0;

  @override
  SheetStateMapper<StateType> get stateMapper => throw UnimplementedError();

  @override
  double? updateComponents(double topHeaderHeight, double headerHeight,
      double contentHeight, double footerHeight) {
    initialComponentSizes = SheetWidgetSizes(
        topHeader: topHeaderHeight,
        header: headerHeight,
        content: contentHeight,
        footer: footerHeight);
    componentSizes = initialComponentSizes;

    return offset;
  }

  @override
  void updateSize(double newOffset,
      {bool isAnimating = false, bool notify = true}) {}

  @override
  void updateState() {}

  @override
  double get forceMultiplier => 1.0;
}
