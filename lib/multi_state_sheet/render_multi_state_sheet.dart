part of 'package:sheetify/multi_state_sheet/multi_state_sheet.dart';

enum _MultiStateSheetSlot {
  topHeader,
  header,
  content,
  footer,
  outside,
}

/// A widget that creates a scrollable and dynamic layout for the [MultiStateSheet] widget.
///
/// This widget uses a [SlottedMultiChildRenderObjectWidget] to manage different slots like
/// `top`, `header`, `footer`, `content`, and `outside`. Each slot is represented by a child widget.
class _MultiStateSheetWidget<StateType>
    extends SlottedMultiChildRenderObjectWidget<_MultiStateSheetSlot,
        RenderBox> {
  /// The controller managing the state and behavior of the sheet.
  final MultiStateSheetController<StateType> scrollController;

  /// Child widgets for the various slots in the sheet.
  final Widget? outside;
  final Widget? topHeader;
  final Widget? header;
  final Widget? content;
  final Widget? footer;

  /// Offset for positioning the `topHeader` relative to the sheet.
  final StatefulSheetDelegate<double>? topHeaderOffset;

  /// Background color of the sheet's content.
  final Color backgroundColor;

  /// Color for the safe area padding at the bottom of the sheet.
  final Color? safeAreaColor;

  /// Defines the shape of the sheet using a custom [ShapeBorder].
  final ShapeBorder? shaper;

  /// Delegate to dynamically calculate the barrier color based on state of controller.
  final StatefulSheetDelegate<Color?>? barrierColorDelegate;

  /// Delegate to calculate the opacity of the [outside] widget based on state of controller.
  final StatefulSheetDelegate<double>? outsideOpacityDelegate;

  /// Determines if the [outside] widget should be drawn behind the background fill color.
  final bool drawOutsideWidgetBehindBackgroundFill;

  /// Determines if the layout of the [outside] widget should account for the [topHeader].
  final bool offsetOutsideWidgetByTopheader;

  /// Determines if the content should be kept behind the footer and not cut by it.
  final bool keepContentBehindFooter;

  /// Padding for the bottom part of safe area around the sheet.
  final double? safeAreaBottomPadding;

  /// Whether to resize the sheet to avoid bottom padding (e.g., keyboard).
  final bool resizeToAvoidBottomPadding;

  const _MultiStateSheetWidget({
    required this.scrollController,
    required this.shaper,
    this.topHeaderOffset,
    this.topHeader,
    this.header,
    this.content,
    this.footer,
    this.outside,
    this.barrierColorDelegate,
    this.outsideOpacityDelegate,
    this.safeAreaColor,
    this.backgroundColor = Colors.transparent,
    this.drawOutsideWidgetBehindBackgroundFill = false,
    this.offsetOutsideWidgetByTopheader = true,
    this.keepContentBehindFooter = false,
    this.safeAreaBottomPadding,
    this.resizeToAvoidBottomPadding = true,
    super.key,
  });

  @override
  Widget? childForSlot(_MultiStateSheetSlot slot) {
    return switch (slot) {
      _MultiStateSheetSlot.topHeader => topHeader,
      _MultiStateSheetSlot.header => header,
      _MultiStateSheetSlot.content => content,
      _MultiStateSheetSlot.footer => footer,
      _MultiStateSheetSlot.outside => outside,
    };
  }

  @override
  Iterable<_MultiStateSheetSlot> get slots => _MultiStateSheetSlot.values;

  @override
  SlottedContainerRenderObjectMixin<_MultiStateSheetSlot, RenderBox>
      createRenderObject(BuildContext context) => _RenderMultiStateSheet(
            scrollController: scrollController,
            topHeaderOffset: topHeaderOffset,
            barrierColorDelegate: barrierColorDelegate,
            backgroundColor: backgroundColor,
            safeAreaColor: safeAreaColor,
            safeAreaBottomPadding: safeAreaBottomPadding,
            shaper: shaper,
            drawOutsideWidgetBehindBackgroundFill:
                drawOutsideWidgetBehindBackgroundFill,
            offsetOutsideWidgetByTopheader: offsetOutsideWidgetByTopheader,
            outsideOpacityDelegate: outsideOpacityDelegate,
            keepContentBehindFooter: keepContentBehindFooter,
            resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
          );

  @override
  void updateRenderObject(BuildContext context,
      covariant _RenderMultiStateSheet<StateType> renderObject) {
    renderObject
      ..scrollController = scrollController
      ..topHeaderOffset = topHeaderOffset
      ..barrierColorDelegate = barrierColorDelegate
      ..backgroundColor = backgroundColor
      ..safeAreaColor = safeAreaColor
      ..safeAreaBottomPadding = safeAreaBottomPadding
      ..shaper = shaper
      ..drawOutsideWidgetBehindBackgroundFill =
          drawOutsideWidgetBehindBackgroundFill
      ..offsetOutsideWidgetByTopheader = offsetOutsideWidgetByTopheader
      ..outsideOpacityDelegate = outsideOpacityDelegate
      ..resizeToAvoidBottomPadding = resizeToAvoidBottomPadding
      ..keepContentBehindFooter = keepContentBehindFooter;

    super.updateRenderObject(context, renderObject);
  }
}

/// A custom render object for managing the layout and rendering of the [MultiStateSheet].
///
/// This render object handles complex layout scenarios such as scrolling content, animating
/// the height of the sheet, and adjusting for safe area padding.
class _RenderMultiStateSheet<StateType> extends RenderBox
    with SlottedContainerRenderObjectMixin<_MultiStateSheetSlot, RenderBox> {
  MultiStateSheetController<StateType> _scrollController;
  MultiStateSheetController<StateType> get scrollController =>
      _scrollController;
  set scrollController(MultiStateSheetController<StateType> value) {
    if (_scrollController != value) {
      _scrollController.removeListener(onSheetOffsetChanges);
      _scrollController = value;
      _scrollController.addListener(onSheetOffsetChanges);
      markNeedsLayout();
    }
  }

  StatefulSheetDelegate<Color?>? _barrierColorDelegate;
  StatefulSheetDelegate<Color?>? get barrierColorDelegate =>
      _barrierColorDelegate;
  set barrierColorDelegate(StatefulSheetDelegate<Color?>? value) {
    if (_barrierColorDelegate != value) {
      _barrierColorDelegate = value;
      markNeedsPaint();
    }
  }

  StatefulSheetDelegate<double>? _outsideOpacityDelegate;
  StatefulSheetDelegate<double>? get outsideOpacityDelegate =>
      _outsideOpacityDelegate;
  set outsideOpacityDelegate(StatefulSheetDelegate<double>? value) {
    if (_outsideOpacityDelegate != value) {
      _outsideOpacityDelegate = value;
      markNeedsLayout();
    }
  }

  StatefulSheetDelegate<double>? _topHeaderOffset;
  StatefulSheetDelegate<double>? get topHeaderOffset => _topHeaderOffset;
  set topHeaderOffset(StatefulSheetDelegate<double>? value) {
    if (_topHeaderOffset != value) {
      _topHeaderOffset = value;
      markNeedsLayout();
    }
  }

  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    if (_backgroundColor != value) {
      _backgroundColor = value;
      markNeedsPaint();
    }
  }

  Color? _safeAreaColor;
  Color? get safeAreaColor => _safeAreaColor;
  set safeAreaColor(Color? value) {
    if (_safeAreaColor != value) {
      _safeAreaColor = value;
      markNeedsPaint();
    }
  }

  ShapeBorder? _shaper;
  ShapeBorder? get shaper => _shaper;
  set shaper(ShapeBorder? value) {
    if (_shaper != value) {
      _shaper = value;
      markNeedsPaint();
    }
  }

  bool _drawOutsideWidgetBehindBackgroundFill;
  bool get drawOutsideWidgetBehindBackgroundFill =>
      _drawOutsideWidgetBehindBackgroundFill;
  set drawOutsideWidgetBehindBackgroundFill(bool value) {
    if (_drawOutsideWidgetBehindBackgroundFill != value) {
      _drawOutsideWidgetBehindBackgroundFill = value;
      markNeedsPaint();
    }
  }

  bool _offsetOutsideWidgetByTopheader;
  bool get offsetOutsideWidgetByTopheader => _offsetOutsideWidgetByTopheader;
  set offsetOutsideWidgetByTopheader(bool value) {
    if (_offsetOutsideWidgetByTopheader != value) {
      _offsetOutsideWidgetByTopheader = value;
      markNeedsLayout();
    }
  }

  bool _keepContentBehindFooter;
  bool get keepContentBehindFooter => _keepContentBehindFooter;
  set keepContentBehindFooter(bool value) {
    if (_keepContentBehindFooter != value) {
      _keepContentBehindFooter = value;
      markNeedsLayout();
    }
  }

  double? _topHeaderOffsetValue;
  double? get topHeaderOffsetValue => _topHeaderOffsetValue;
  set topHeaderOffsetValue(double? value) {
    if (_topHeaderOffsetValue != value) {
      _topHeaderOffsetValue = value;
      markNeedsLayout();
    }
  }

  double? _viewBottomPadding;
  double get viewBottomPadding => _viewBottomPadding ?? 0.0;
  set viewBottomPadding(double? value) {
    if (_viewBottomPadding != value) {
      _viewBottomPadding = value;
      markNeedsLayout();
    }
  }

  double? _safeAreaBottomPadding;
  double get safeAreaBottomPadding => _safeAreaBottomPadding ?? 0.0;
  set safeAreaBottomPadding(double? value) {
    if (_safeAreaBottomPadding != value) {
      _safeAreaBottomPadding = value;
      markNeedsLayout();
    }
  }

  bool _resizeToAvoidBottomPadding;
  bool get resizeToAvoidBottomPadding => _resizeToAvoidBottomPadding;
  set resizeToAvoidBottomPadding(bool value) {
    if (_resizeToAvoidBottomPadding != value) {
      _resizeToAvoidBottomPadding = value;
      if (value) {
        _insetStream =
            KeyboardInsets.insets.listen((value) => viewBottomPadding = value);
      } else {
        _insetStream?.cancel();
        _insetStream = null;
        viewBottomPadding = 0.0;
      }
    }
  }

  double draggedSheetOffset = 0.0;
  int outsideOpacity = 255;

  _RenderMultiStateSheet({
    required MultiStateSheetController<StateType> scrollController,
    required ShapeBorder? shaper,
    required Color backgroundColor,
    StatefulSheetDelegate<double>? topHeaderOffset,
    Color? safeAreaColor,
    double? safeAreaBottomPadding,
    StatefulSheetDelegate<Color?>? barrierColorDelegate,
    StatefulSheetDelegate<double>? outsideOpacityDelegate,
    bool drawOutsideWidgetBehindBackgroundFill = false,
    bool offsetOutsideWidgetByTopheader = true,
    bool keepContentBehindFooter = false,
    bool resizeToAvoidBottomPadding = true,
  })  : _scrollController = scrollController,
        _barrierColorDelegate = barrierColorDelegate,
        _outsideOpacityDelegate = outsideOpacityDelegate,
        _topHeaderOffset = topHeaderOffset,
        _backgroundColor = backgroundColor,
        _safeAreaColor = safeAreaColor,
        _safeAreaBottomPadding = safeAreaBottomPadding,
        _shaper = shaper,
        _drawOutsideWidgetBehindBackgroundFill =
            drawOutsideWidgetBehindBackgroundFill,
        _offsetOutsideWidgetByTopheader = offsetOutsideWidgetByTopheader,
        _keepContentBehindFooter = keepContentBehindFooter,
        draggedSheetOffset = scrollController._extent.offset,
        _resizeToAvoidBottomPadding = resizeToAvoidBottomPadding;

  // Slot getters for accessing child render objects.
  RenderBox? get topHeader => childForSlot(_MultiStateSheetSlot.topHeader);
  RenderBox? get header => childForSlot(_MultiStateSheetSlot.header);
  RenderBox? get content => childForSlot(_MultiStateSheetSlot.content);
  RenderBox? get footer => childForSlot(_MultiStateSheetSlot.footer);
  RenderBox? get outside => childForSlot(_MultiStateSheetSlot.outside);

  double get sheetHeightExtent => math.max(
      0.0,
      constraints.maxHeight -
          draggedSheetOffset -
          math.max(0.0, viewBottomPadding - safeAreaBottomPadding));

  @override
  bool get sizedByParent => true;

  AnimationController? get safeAreaAnimationController =>
      scrollController._extent._safeAreaAnimationController;

  // The returned list is ordered for hit testing.
  @override
  Iterable<RenderBox> get children {
    final _topHeader = topHeader;
    final _header = header;
    final _content = content;
    final _footer = footer;
    final _outside = outside;

    return <RenderBox>[
      if (_header != null) _header,
      if (_footer != null) _footer,
      if (_content != null) _content,
      if (_topHeader != null) _topHeader,
      if (_outside != null) _outside,
    ];
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return content != null
        ? math.max(content!.getMinIntrinsicWidth(height), 0)
        : 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return content != null
        ? math.max(content!.getMaxIntrinsicWidth(height), 0)
        : 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return math.max(
      0,
      content!.getMinIntrinsicHeight(width) +
          (header?.getMinIntrinsicHeight(width) ?? 0.0),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeMinIntrinsicHeight(width);
  }

  StreamSubscription<double>? _insetStream;

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    if (resizeToAvoidBottomPadding) {
      _insetStream = KeyboardInsets.insets.listen((value) {
        if (viewBottomPadding != value) {
          viewBottomPadding = value;
          markNeedsLayout();
        }
      });
    }
    scrollController.addListener(onSheetOffsetChanges);
    safeAreaAnimationController?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _insetStream?.cancel();
    scrollController.removeListener(onSheetOffsetChanges);
    safeAreaAnimationController?.removeListener(markNeedsPaint);
    super.detach();
  }

  /// Called when the sheet's offset changes by a controller.
  void onSheetOffsetChanges() {
    /// Skip frame and reset marker for the current notification.
    if (scrollController._doNotMarkNeedsLayout) {
      scrollController._doNotMarkNeedsLayout = false;
      return;
    }
    final currentOffset = scrollController._extent.offset;
    final maxOffset = constraints.maxHeight;
    final isOpening = scrollController._extent.isAnimatingOpen;

    // Update dragged sheet offset based on the offset from controller's extent.
    if (currentOffset != draggedSheetOffset &&
        (isOpening || currentOffset <= maxOffset)) {
      if (hasSize && !scrollController._extent.isPreformingResize) {
        markNeedsLayout();
      }
    }

    if (scrollController._forceRepaint) {
      scrollController._forceRepaint = false;
      markNeedsPaint();
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      Size(constraints.maxWidth, constraints.maxHeight);

  @override
  void performResize() {
    scrollController._extent.isPreformingResize = true;
    scrollController._maxHeight = constraints.maxHeight - viewBottomPadding;
    super.performResize();
  }

  @override
  void performLayout() {
    // Calculate available space for the bottom sheet.
    final constraints = this.constraints;

    final avaliableHeight = constraints.maxHeight -
        math.max(0.0, viewBottomPadding - safeAreaBottomPadding);

    /// Updates the `lastMaxOffset` of the scroll controller's extent behavior to the current `maxOffset`.
    ///
    /// This is used to keep track of the safe maximum offset value is valid or not.
    scrollController._extent.behavior.lastMaxOffset =
        scrollController._extent.maxOffset;

    if (scrollController._extent.availablePixels == kStartOfTheViewport ||
        viewBottomPadding > kStartOfTheViewport) {
      scrollController._maxHeight = avaliableHeight;
    }

    if (!scrollController.isEnabled) {
      draggedSheetOffset = avaliableHeight;
    } else {
      draggedSheetOffset = scrollController._extent.offset;
    }

    /// Flag that is false then bottom sheet is animating open state.
    /// This is necessary for enabling/disabling clipping by the height
    /// of the header for minimum displayed height of the bottom sheet.
    /// Then this flag is set to false, disable clipping and bottom sheet
    /// can go outside of bounding box of the viewport.
    final shiftByHeader = !scrollController._extent.isAnimatingOpen &&
        scrollController._extent.behavior.clipByHeader;

    // Layout header
    final headerLayoutExtend =
        _layoutChild(header, constraints)?.height ?? kStartOfTheViewport;

    draggedSheetOffset = clampDouble(
        draggedSheetOffset,
        kStartOfTheViewport,
        avaliableHeight -
            (shiftByHeader ? headerLayoutExtend : kStartOfTheViewport));

    var sheetFreeSpace = clampDouble(
        sheetHeightExtent,
        (shiftByHeader ? headerLayoutExtend : kStartOfTheViewport),
        avaliableHeight);
    assert(sheetFreeSpace >= kStartOfTheViewport,
        'Max height should not be negative');

    /// footerLayoutExtend
    final footerLayoutExtend =
        _layoutChild(footer, constraints)?.height ?? kStartOfTheViewport;

    var sheetContentSpace = math.max(
        kStartOfTheViewport,
        sheetFreeSpace -
            headerLayoutExtend -
            (keepContentBehindFooter
                ? kStartOfTheViewport
                : footerLayoutExtend));

    /// Layout overflow header
    final topLayoutExtend =
        _layoutChild(topHeader, constraints)?.height ?? kStartOfTheViewport;

    /// Layout bottom sheet content sliver list
    var contentLayoutExtend =
        _layoutChild(content, constraints, height: sheetContentSpace)?.height ??
            kStartOfTheViewport;

    /// Update components height layout
    final sheetOffsetAfterUpdatingComponentSizes =
        scrollController._updateComponents(
              headerHeight: headerLayoutExtend,
              contentHeight: contentLayoutExtend,
              footerHeight: footerLayoutExtend,
              topHeaderHeight: topLayoutExtend,
            ) ??
            draggedSheetOffset;

    /// Relayout the content because the offset of the sheet changed by updated components.
    if (sheetOffsetAfterUpdatingComponentSizes != draggedSheetOffset) {
      draggedSheetOffset = sheetOffsetAfterUpdatingComponentSizes;

      /// The drag offset is been corrected by the current state of the sheet, so we need to recalculate the the free space and content space.
      sheetFreeSpace = clampDouble(
          sheetHeightExtent,
          (shiftByHeader ? headerLayoutExtend : kStartOfTheViewport),
          avaliableHeight);
      assert(sheetFreeSpace >= kStartOfTheViewport,
          'Max height should not be negative');

      sheetContentSpace = math.max(
          kStartOfTheViewport,
          sheetFreeSpace -
              headerLayoutExtend -
              (keepContentBehindFooter
                  ? kStartOfTheViewport
                  : footerLayoutExtend));

      contentLayoutExtend =
          _layoutChild(content, constraints, height: sheetContentSpace)
                  ?.height ??
              kStartOfTheViewport;
    }

    /// If the sheet is should be open instantly, we need to recalculate the height of the sheet
    /// based on the widgets sizes which were layouted and enable sheet to it to be drawn at the first frame.
    if (!scrollController.isEnabled &&
        !scrollController._extent.isAnimatingOpen) {
      draggedSheetOffset = clampDouble(
          scrollController._calculateInitialPositionAndSetEnabled(),
          kStartOfTheViewport,
          avaliableHeight -
              (shiftByHeader ? headerLayoutExtend : kStartOfTheViewport));

      /// The drag offset is been corrected by the current state of the sheet, so we need to recalculate the the free space and content space.
      sheetFreeSpace = clampDouble(
          sheetHeightExtent,
          (shiftByHeader ? headerLayoutExtend : kStartOfTheViewport),
          avaliableHeight);
      assert(sheetFreeSpace >= kStartOfTheViewport,
          'Max height should not be negative');

      sheetContentSpace = math.max(
          kStartOfTheViewport,
          sheetFreeSpace -
              headerLayoutExtend -
              (keepContentBehindFooter
                  ? kStartOfTheViewport
                  : footerLayoutExtend));

      /// Relayout the content because the height the content occupies has changed.
      contentLayoutExtend =
          _layoutChild(content, constraints, height: sheetContentSpace)
                  ?.height ??
              kStartOfTheViewport;
    }

    if (scrollController.needsSetupBehavior) {
      scrollController._extent.behavior.setup(scrollController._extent);
    }

    final footerOffsetPositionAbsolute =
        math.min(sheetFreeSpace - headerLayoutExtend, footerLayoutExtend);
    final offsetSheetFromTop = draggedSheetOffset;

    scrollController._actualOffset = draggedSheetOffset;
    // We make it to not call the delegate function if the value is already set.
    // It improves performance and avoid unnecessary calls.
    final topOffset = topHeaderOffsetValue ??
        topHeaderOffset?.getValue(scrollController) ??
        kStartOfTheViewport;

    /// Layout outside widget
    final opacity = outsideOpacityDelegate?.getValue(scrollController);
    if (opacity != null) {
      outsideOpacity = Color.getAlphaFromOpacity(opacity.clamp(0, 1));
    }
    if (outsideOpacity > 0) {
      final outsideSize = (offsetSheetFromTop -
              (offsetOutsideWidgetByTopheader
                  ? topLayoutExtend
                  : kStartOfTheViewport))
          .clamp(kStartOfTheViewport, avaliableHeight);
      final _ = _layoutChild(outside, constraints, height: outsideSize);
      _positionChild(outside, constraints, kStartOfTheViewport);
    }

    /// Setup children's offsets
    _positionChild(
        content, constraints, offsetSheetFromTop + headerLayoutExtend);
    _positionChild(
        topHeader,
        constraints,
        math.max(kStartOfTheViewport,
            offsetSheetFromTop - topLayoutExtend - topOffset));
    _positionChild(header, constraints, offsetSheetFromTop);
    _positionChild(
        footer, constraints, avaliableHeight - footerOffsetPositionAbsolute);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    scrollController._extent.isPreformingResize = false;
    final _scrollController = scrollController;

    if (!_scrollController.isEnabled) {
      super.paint(context, offset);
      return;
    }

    final painter = Paint()
      ..color = backgroundColor
      ..isAntiAlias = true;

    void doPaint(RenderBox? child, PaintingContext context, Offset offset) {
      if (child != null) {
        final BoxParentData parentData = child.parentData! as BoxParentData;
        context.paintChild(child, parentData.offset + offset);
      }
    }

    /// A `Path` object used to clip sheet layer and background.
    final path = shaper?.getInnerPath(
          Rect.fromLTWH(
            kStartOfTheViewport,
            draggedSheetOffset,
            constraints.maxWidth,
            sheetHeightExtent +
                math.max(0.0, viewBottomPadding - safeAreaBottomPadding),
          ),
        ) ??
        (Path()
          ..addRRect(
            RRect.fromRectAndCorners(
              Rect.fromLTWH(
                kStartOfTheViewport,
                draggedSheetOffset,
                constraints.maxWidth,
                sheetHeightExtent +
                    math.max(0.0, viewBottomPadding - safeAreaBottomPadding),
              ),
              topLeft: const Radius.circular(kDefaultRadius),
              topRight: const Radius.circular(kDefaultRadius),
            ),
          ));

    void paintOutsideWidget() {
      context.pushLayer(OpacityLayer()..alpha = outsideOpacity,
          (context, offset) => doPaint(outside, context, offset), offset);
    }

    void paintSheet(PaintingContext context, Offset offset) {
      /// Paint the background of the sheet.
      context.canvas.drawPath(path.shift(offset), painter);
      doPaint(content, context, offset);
      doPaint(header, context, offset);
      doPaint(footer, context, offset);
    }

    /// Paint the outside widget behind the background fill color.
    final paintOutside = outsideOpacity > 0;
    if (drawOutsideWidgetBehindBackgroundFill && paintOutside) {
      paintOutsideWidget();
    }

    /// Draw barrier color from the color delegate.
    final barrierColor = barrierColorDelegate?.getValue(_scrollController);
    if (barrierColor != null) {
      final backgroundPainter = Paint()..color = barrierColor;
      context.canvas.drawPaint(backgroundPainter);
    }

    /// Paint the outside widget above the background fill color.
    if (!drawOutsideWidgetBehindBackgroundFill && paintOutside) {
      paintOutsideWidget();
    }

    /// Paint the top header widget above the background fill color.
    doPaint(topHeader, context, offset);

    layer = context.pushClipPath(
      needsCompositing,
      offset,
      Rect.fromLTWH(
        offset.dx,
        draggedSheetOffset,
        constraints.maxWidth,
        sheetHeightExtent,
      ),
      path,
      paintSheet,
      oldLayer: layer as ClipPathLayer?,
    );

    /// Paint the safe area padding at the bottom of the sheet.
    if (safeAreaColor != null) {
      painter.color = safeAreaColor!;
    }

    const safeAreaCorrection = 1.0;
    context.canvas.drawRect(
      Rect.fromLTWH(
        offset.dx,
        constraints.maxHeight -
            math.max(0.0, viewBottomPadding - safeAreaBottomPadding) +
            offset.dy -
            safeAreaCorrection +
            safeAreaBottomPadding * (safeAreaAnimationController?.value ?? 0.0),
        constraints.maxWidth,
        math.max(0.0, viewBottomPadding - safeAreaBottomPadding) > 0.0
            ? 0.0
            : safeAreaBottomPadding + safeAreaCorrection,
      ),
      painter,
    );
  }

  @override
  bool hitTestSelf(Offset position) => false;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (!scrollController.isEnabled || !hasSize) {
      return super.hitTestChildren(result, position: position);
    }

    for (final child in children) {
      /// If the outside widget is not visible then skip it.
      if (child == outside && outsideOpacity == 0) {
        continue;
      }
      final BoxParentData parentData = child.parentData! as BoxParentData;
      final isHit =
          child.hitTest(result, position: position - parentData.offset);
      if (isHit) {
        return isHit;
      }
    }
    return false;
  }

  Size? _layoutChild(RenderBox? child, BoxConstraints constraints,
      {double? height}) {
    if (child == null) {
      return null;
    }
    child.layout(
        constraints.copyWith(
            minHeight: 0, maxHeight: height ?? constraints.maxHeight),
        parentUsesSize: true);
    return child.size;
  }

  void _positionChild(
      RenderBox? child, BoxConstraints constraints, double offset) {
    if (child == null) {
      return;
    }

    final leftPadding = (constraints.maxWidth - child.size.width) / 2;
    (child.parentData as BoxParentData?)?.offset = Offset(leftPadding, offset);
  }
}
