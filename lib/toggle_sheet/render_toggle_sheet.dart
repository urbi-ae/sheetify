part of 'package:sheetify/toggle_sheet/toggle_sheet.dart';

enum _ToggleSheetSlot {
  topHeader,
  header,
  content,
  footer,
  outside,
}

/// A widget that creates a scrollable and dynamic layout for the [ToggleSheet] widget.
///
/// This widget uses a [SlottedMultiChildRenderObjectWidget] to manage different slots like
/// `header`, `footer`, `content`, and `outside`. Each slot is represented by a child widget.
class _ToggleSheetWidget extends SlottedMultiChildRenderObjectWidget<_ToggleSheetSlot, RenderBox> {
  /// The controller managing the behavior of the sheet.
  final ToggleSheetController scrollController;

  /// Child widgets for the various slots in the sheet.
  final Widget? outside;
  final Widget? topHeader;
  final Widget? header;
  final Widget? content;
  final Widget? footer;

  /// Offset for positioning the `topHeader` relative to the sheet.
  final double? topHeaderOffset;

  /// Background color of the sheet.
  final Color backgroundColor;

  /// Color for the safe area padding at the bottom of the sheet.
  final Color? safeAreaColor;

  /// Delegate to dynamically calculate the border radius based on controller state.
  final ToggleSheetDelegate<ShapeBorder?>? shapeBorderDelegate;

  /// Delegate to calculate the padding outside the sheet.
  final ToggleSheetDelegate<EdgeInsets?>? paddingDelegate;

  /// Delegate to dynamically calculate the barrier color based on controller state.
  final ToggleSheetDelegate<Color?>? barrierColorDelegate;

  /// Delegate to calculate the opacity of the [outside] widget based on controller state.
  final ToggleSheetDelegate<double>? outsideOpacityDelegate;

  /// Determines if the [outside] widget should be drawn behind the background fill color.
  final bool drawOutsideWidgetBehindBackgroundFill;

  /// Determines if the layout of the [outside] widget should account for the [topHeader].
  final bool offsetOutsideWidgetByTopheader;

  /// Padding for the bottom of the viewport to accommodate UI elements like keyboard.
  final double? viewBottomPadding;

  const _ToggleSheetWidget({
    required this.scrollController,
    required this.backgroundColor,
    this.outsideOpacityDelegate,
    this.outside,
    this.topHeader,
    this.header,
    this.content,
    this.footer,
    this.barrierColorDelegate,
    this.safeAreaColor,
    this.topHeaderOffset = 0.0,
    this.offsetOutsideWidgetByTopheader = true,
    this.drawOutsideWidgetBehindBackgroundFill = false,
    this.viewBottomPadding,
    this.shapeBorderDelegate,
    this.paddingDelegate,
    super.key,
  });

  @override
  Widget? childForSlot(_ToggleSheetSlot slot) {
    return switch (slot) {
      _ToggleSheetSlot.topHeader => topHeader,
      _ToggleSheetSlot.header => header,
      _ToggleSheetSlot.content => content,
      _ToggleSheetSlot.footer => footer,
      _ToggleSheetSlot.outside => outside,
    };
  }

  @override
  Iterable<_ToggleSheetSlot> get slots => _ToggleSheetSlot.values;

  @override
  SlottedContainerRenderObjectMixin<_ToggleSheetSlot, RenderBox> createRenderObject(BuildContext context) {
    return _RenderToggleSheet(
      scrollController: scrollController,
      topHeaderOffset: topHeaderOffset,
      backgroundColor: backgroundColor,
      shaperBorderDelegate: shapeBorderDelegate,
      backgroundColorDelegate: barrierColorDelegate,
      outsideOpacityDelegate: outsideOpacityDelegate,
      safeAreaColor: safeAreaColor,
      viewBottomPadding: viewBottomPadding,
      offsetOutsideWidgetByTopheader: offsetOutsideWidgetByTopheader,
      drawOutsideWidgetBehindBackgroundFill: drawOutsideWidgetBehindBackgroundFill,
      paddingDelegate: paddingDelegate,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderToggleSheet renderObject) {
    renderObject
      ..scrollController = scrollController
      ..barrierColorDelegate = barrierColorDelegate
      ..backgroundColor = backgroundColor
      ..safeAreaColor = safeAreaColor
      ..viewBottomPadding = viewBottomPadding
      ..draggedSheetOffset = scrollController._extent.offset
      ..outsideOpacityDelegate = outsideOpacityDelegate
      ..drawOutsideWidgetBehindBackgroundFill = drawOutsideWidgetBehindBackgroundFill
      ..paddingDelegate = paddingDelegate
      ..shaperBorderDelegate = shapeBorderDelegate;

    super.updateRenderObject(context, renderObject);
  }
}

/// A custom render object for managing the layout and rendering of the [ToggleSheet].
///
/// This render object handles complex layout scenarios such as scrolling content, animating
/// the height of the sheet, and adjusting for safe area padding.
class _RenderToggleSheet extends RenderBox with SlottedContainerRenderObjectMixin<_ToggleSheetSlot, RenderBox> {
  ToggleSheetController _scrollController;

  ToggleSheetController get scrollController => _scrollController;

  set scrollController(ToggleSheetController value) {
    if (_scrollController != value) {
      _scrollController = value;
      markNeedsLayout();
    }
  }

  ToggleSheetDelegate<Color?>? _backgroundColorDelegate;

  ToggleSheetDelegate<Color?>? get barrierColorDelegate => _backgroundColorDelegate;

  set barrierColorDelegate(ToggleSheetDelegate<Color?>? value) {
    if (_backgroundColorDelegate != value) {
      _backgroundColorDelegate = value;
      markNeedsPaint();
    }
  }

  ToggleSheetDelegate<double>? _outsideOpacityDelegate;

  ToggleSheetDelegate<double>? get outsideOpacityDelegate => _outsideOpacityDelegate;

  set outsideOpacityDelegate(ToggleSheetDelegate<double>? value) {
    if (_outsideOpacityDelegate != value) {
      _outsideOpacityDelegate = value;
      markNeedsLayout();
    }
  }

  ToggleSheetDelegate<ShapeBorder?>? _shaperBorderDelegate;

  ToggleSheetDelegate<ShapeBorder?>? get shaperBorderDelegate => _shaperBorderDelegate;

  set shaperBorderDelegate(ToggleSheetDelegate<ShapeBorder?>? value) {
    if (_shaperBorderDelegate != value) {
      _shaperBorderDelegate = value;
      markNeedsPaint();
    }
  }

  ToggleSheetDelegate<EdgeInsets?>? paddingDelegate;

  double? _topHeaderOffset;

  double? get topHeaderOffset => _topHeaderOffset;

  set topHeaderOffset(double? value) {
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

  bool _drawOutsideWidgetBehindBackgroundFill;

  bool get drawOutsideWidgetBehindBackgroundFill => _drawOutsideWidgetBehindBackgroundFill;

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

  double? _viewBottomPadding;
  double get viewBottomPadding => _viewBottomPadding ?? 0.0;
  set viewBottomPadding(double? value) {
    if (_viewBottomPadding != value) {
      _viewBottomPadding = value;
      markNeedsLayout();
    }
  }

  EdgeInsets? innerPadding;
  double _draggedSheetHeight = 0.0;
  double get draggedSheetOffset => _draggedSheetHeight;
  set draggedSheetOffset(double value) {
    if (_draggedSheetHeight != value) {
      _draggedSheetHeight = value;
    }
  }

  int outsideOpacity = 255;

  _RenderToggleSheet({
    required ToggleSheetController scrollController,
    required Color backgroundColor,
    double? topHeaderOffset,
    ToggleSheetDelegate<Color?>? backgroundColorDelegate,
    Color? safeAreaColor,
    ToggleSheetDelegate<double>? outsideOpacityDelegate,
    ToggleSheetDelegate<ShapeBorder?>? shaperBorderDelegate,
    this.paddingDelegate,
    double? viewBottomPadding,
    bool offsetOutsideWidgetByTopheader = true,
    bool drawOutsideWidgetBehindBackgroundFill = false,
  })  : _offsetOutsideWidgetByTopheader = offsetOutsideWidgetByTopheader,
        _drawOutsideWidgetBehindBackgroundFill = drawOutsideWidgetBehindBackgroundFill,
        _safeAreaColor = safeAreaColor,
        _backgroundColor = backgroundColor,
        _topHeaderOffset = topHeaderOffset,
        _shaperBorderDelegate = shaperBorderDelegate,
        _outsideOpacityDelegate = outsideOpacityDelegate,
        _backgroundColorDelegate = backgroundColorDelegate,
        _scrollController = scrollController,
        _viewBottomPadding = viewBottomPadding;

  // Slot getters for accessing child render objects.
  RenderBox? get topHeader => childForSlot(_ToggleSheetSlot.topHeader);
  RenderBox? get header => childForSlot(_ToggleSheetSlot.header);
  RenderBox? get content => childForSlot(_ToggleSheetSlot.content);
  RenderBox? get footer => childForSlot(_ToggleSheetSlot.footer);
  RenderBox? get outside => childForSlot(_ToggleSheetSlot.outside);

  double get sheetHeightExtent => math.max(0.0, constraints.maxHeight - draggedSheetOffset);

  @override
  bool get sizedByParent => true;

  // The returned list is ordered for hit testing.
  @override
  Iterable<RenderBox> get children {
    final _topHeader = topHeader;
    final _header = header;
    final _content = content;
    final _footer = footer;
    final _outside = outside;

    return <RenderBox>[
      if (_topHeader != null) _topHeader,
      if (_header != null) _header,
      if (_footer != null) _footer,
      if (_content != null) _content,
      if (_outside != null) _outside,
    ];
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return content != null ? math.max(content!.getMinIntrinsicWidth(height), 0) : 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return content != null ? math.max(content!.getMaxIntrinsicWidth(height), 0) : 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return math.max(
      0,
      content!.getMinIntrinsicHeight(width) + (header?.getMinIntrinsicHeight(width) ?? 0.0),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeMinIntrinsicHeight(width);
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    scrollController.addListener(onSheetOffsetChanges);
  }

  @override
  void detach() {
    scrollController.removeListener(onSheetOffsetChanges);
    super.detach();
  }

  /// Called when the sheet's offset changes by a controller.
  void onSheetOffsetChanges() {
    final currentOffset = scrollController._extent.offset;
    final maxHeight = scrollController._extent.maxHeight;
    final isOpening = scrollController._isAnimatingOpen;

    /// Update dragged sheet offset based on the offset from controller's extent.
    if (currentOffset != draggedSheetOffset && (isOpening || currentOffset <= maxHeight) ||
        scrollController._isChangingHeightModel) {
      draggedSheetOffset = currentOffset;
      if (hasSize && !scrollController._isPreformingResize) {
        scrollController._isChangingHeightModel = false;
        markNeedsLayout();
      }
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => Size(constraints.maxWidth, constraints.maxHeight);

  @override
  void performResize() {
    scrollController._isPreformingResize = true;
    scrollController._extent.minHeight = 0.0;
    scrollController._extent.availablePixels = constraints.maxHeight;
    scrollController._extent.updateSize(scrollController.isClosed ? constraints.maxHeight : 0.0);
    super.performResize();
  }

  @override
  void performLayout() {
    final heightModel = scrollController._extent.heightModel;
    draggedSheetOffset = scrollController._extent.offset;

    // Calculate available space for the sheet.
    final avaliableHeight = constraints.maxHeight;
    assert(
      avaliableHeight != double.infinity,
      'ToggleSheet: `constraints.maxHeight` is infinite. '
      'Please provide a finite height for the sheet.',
    );

    final opacity = outsideOpacityDelegate?.getValue(scrollController);
    if (opacity != null) {
      outsideOpacity = Color.getAlphaFromOpacity(opacity.clamp(0, 1));
    }

    innerPadding = paddingDelegate?.getValue(scrollController);

    final topPadding = innerPadding?.bottom ?? 0.0;
    final bottomPadding = innerPadding?.bottom ?? 0.0;
    final leftPadding = innerPadding?.left ?? 0.0;
    final horizontalPadding = innerPadding?.horizontal ?? 0.0;

    final correctedConstraints = constraints.copyWith(
      minWidth: constraints.maxWidth - horizontalPadding,
      maxWidth: constraints.maxWidth - horizontalPadding,
    );

    // Layout header
    final headerLayoutExtend = _layoutChild(header, correctedConstraints)?.height ?? 0.0;
    scrollController._extent.componentSizes = scrollController.componentSizes.copyWith(
      header: headerLayoutExtend,
    );

    if (!scrollController.isEnabled) {
      if (scrollController._isAnimatingOpen) {
        draggedSheetOffset = avaliableHeight;
      } else {
        draggedSheetOffset =
            scrollController._calculateInitialPositionAndSetEnabled() ?? scrollController._extent._offset;
      }
    }

    /// footerLayoutExtend
    final footerLayoutExtend = _layoutChild(footer, correctedConstraints)?.height ?? 0.0;

    /// Layout overflow header
    final topLayoutExtend = _layoutChild(topHeader, correctedConstraints)?.height ?? kStartOfTheViewport;
    final topOffset = topHeaderOffset ?? kStartOfTheViewport;

    /// Layout sheet content slivers
    final contentLayoutExtend = _layoutChild(
          content,
          correctedConstraints,
          height: math.max(
            0.0,
            (heightModel != null
                    ? correctedConstraints.maxHeight - heightModel.getHeight(correctedConstraints.maxHeight)
                    : correctedConstraints.maxHeight) -
                footerLayoutExtend -
                headerLayoutExtend -
                topPadding -
                bottomPadding,
          ),
        )?.height ??
        0.0;

    scrollController._extent.componentSizes = scrollController.componentSizes.copyWith(
      topHeader: topLayoutExtend,
      content: contentLayoutExtend,
      footer: footerLayoutExtend,
    );

    final sheetChildrenSize = headerLayoutExtend + contentLayoutExtend + footerLayoutExtend;

    final isFirstFrame = scrollController._extent.availablePixels == 0;
    final isPreformingResize = scrollController._isPreformingResize;
    final isContentSizeUpdated =
        avaliableHeight - sheetChildrenSize - viewBottomPadding != scrollController._extent.minHeight;

    if (isFirstFrame || isPreformingResize || isContentSizeUpdated) {
      draggedSheetOffset = scrollController._updateHeightBoundings(
            avaliableHeight - sheetChildrenSize - viewBottomPadding + bottomPadding,
            avaliableHeight,
          ) ??
          draggedSheetOffset;
    }

    if (isFirstFrame && (scrollController._isStartsClosed)) {
      draggedSheetOffset = avaliableHeight;
      scrollController._extent._offset = avaliableHeight;
    }

    draggedSheetOffset = clampDouble(
      draggedSheetOffset,
      scrollController._extent.minHeight + topPadding,
      scrollController._extent.maxHeight - bottomPadding + viewBottomPadding,
    );

    final footerOffsetPositionAbsolute = math.min(
      sheetHeightExtent - headerLayoutExtend + viewBottomPadding,
      footerLayoutExtend + viewBottomPadding,
    );

    /// Setup children's offsets
    _positionChild(
      content,
      correctedConstraints,
      draggedSheetOffset + headerLayoutExtend,
      padding: leftPadding,
    );
    _positionChild(
      topHeader,
      correctedConstraints,
      math.max(kStartOfTheViewport, draggedSheetOffset - topLayoutExtend - topOffset),
      padding: leftPadding,
    );
    _positionChild(
      header,
      correctedConstraints,
      draggedSheetOffset,
      padding: leftPadding,
    );
    _positionChild(
      footer,
      correctedConstraints,
      avaliableHeight - footerOffsetPositionAbsolute + viewBottomPadding,
      padding: leftPadding,
    );

    /// Layout outside widget
    if (outsideOpacity > 0) {
      final _ = _layoutChild(outside, constraints,
          height: draggedSheetOffset - (offsetOutsideWidgetByTopheader ? topLayoutExtend : kStartOfTheViewport));
      _positionChild(outside, constraints, kStartOfTheViewport);
    }
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! BoxParentData) {
      child.parentData = BoxParentData();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    scrollController._isPreformingResize = false;

    if (!scrollController.isEnabled) {
      super.paint(context, offset);
      return;
    }

    final bottomPadding = innerPadding?.bottom ?? 0.0;
    final leftPadding = innerPadding?.left ?? 0.0;
    final rightPadding = innerPadding?.right ?? 0.0;
    final horizontalPadding = innerPadding?.horizontal ?? 0.0;

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

    final Path path = shaperBorderDelegate?.getValue(scrollController)?.getOuterPath(
              Rect.fromLTWH(
                kStartOfTheViewport + leftPadding,
                draggedSheetOffset,
                constraints.maxWidth - horizontalPadding,
                sheetHeightExtent - bottomPadding + viewBottomPadding,
              ),
            ) ??
        (Path()
          ..addRRect(
            RRect.fromRectAndCorners(
              Rect.fromLTWH(
                kStartOfTheViewport + leftPadding,
                draggedSheetOffset,
                constraints.maxWidth - horizontalPadding,
                sheetHeightExtent - bottomPadding + viewBottomPadding,
              ),
              topLeft: const Radius.circular(kDefaultRadius),
              topRight: const Radius.circular(kDefaultRadius),
            ),
          ));

    void paintSheet(PaintingContext context, Offset offset) {
      /// Paint sheet's background
      context.canvas.drawPath(path.shift(offset), painter);
      doPaint(content, context, offset);
      doPaint(header, context, offset);
      doPaint(footer, context, offset);

      /// Paint safe area
      final hasSafeArea = safeAreaColor != null;
      if (hasSafeArea) {
        painter.color = safeAreaColor!;
        context.canvas.drawRect(
          Rect.fromLTWH(
            offset.dx + leftPadding,
            constraints.maxHeight + offset.dy,
            constraints.maxWidth - rightPadding,
            viewBottomPadding,
          ),
          painter,
        );
      }
    }

    /// Paint the outside widget behind the background fill color.
    final paintOutside = outsideOpacity > 0;
    if (drawOutsideWidgetBehindBackgroundFill && paintOutside) {
      doPaint(outside, context, offset);
    }

    /// Draw barrier color from the color delegate.
    final barrierColor = barrierColorDelegate?.getValue(scrollController);
    if (barrierColor != null) {
      final barrierPainter = Paint()..color = barrierColor;
      context.canvas.drawPaint(barrierPainter);
    }

    /// Paint the outside widget above the background fill color.
    if (!drawOutsideWidgetBehindBackgroundFill && paintOutside) {
      doPaint(outside, context, offset);
    }

    /// Paint the top header widget above the background fill color.
    doPaint(topHeader, context, offset);

    /// Paint the sheet as the clip path to the current layer.
    if (draggedSheetOffset < constraints.maxHeight) {
      layer = context.pushClipPath(
        needsCompositing,
        offset,
        Rect.fromLTWH(
          offset.dx + leftPadding,
          draggedSheetOffset,
          constraints.maxWidth - rightPadding,
          sheetHeightExtent + viewBottomPadding,
        ),
        path,
        paintSheet,
        oldLayer: layer as ClipPathLayer?,
      );
    }
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
      final isHit = child.hitTest(result, position: position - parentData.offset);
      if (isHit) {
        return isHit;
      }
    }
    return false;
  }

  Size? _layoutChild(RenderBox? child, BoxConstraints constraints, {double? height}) {
    if (child == null) {
      return null;
    }
    child.layout(constraints.copyWith(minHeight: 0, maxHeight: height ?? constraints.maxHeight), parentUsesSize: true);
    return child.size;
  }

  void _positionChild(RenderBox? child, BoxConstraints constraints, double offset, {double padding = 0.0}) {
    if (child == null) {
      return;
    }

    final leftPadding = (constraints.maxWidth - child.size.width) / 2 + padding;
    (child.parentData as BoxParentData?)?.offset = Offset(leftPadding, offset);
  }
}
