import 'dart:collection';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:sheetify/sheetify.dart';
import 'package:sheetify/utils/constants.dart';
import 'package:sheetify/utils/frame_stack_hash_map.dart';
import 'package:sheetify/utils/math_helper.dart';
import 'package:sheetify/utils/round_double.dart';
import 'package:sheetify/utils/snapping_simulation.dart';

part 'render_multi_state_sheet.dart';
part 'multi_state_sheet_controller.dart';
part 'state_snapping/behaviors/snapping_behavior.dart';

/// A customizable and animated multi snap-state sheet widget.
///
/// The `MultiStateSheet` allows you to create a sheet with support
/// for snapping behavior, layering of widgets and interactive content.
///
/// ### Key Features:
/// - Configurable snapping and scrolling behavior.
/// - Customizable header, footer, and content.
/// - Animations for opening and transitioning between states.
/// - Integration with a controller for external state management.
class MultiStateSheet<StateType> extends StatefulWidget {
  /// Custom [ScrollController] used to controll state of sheet widget
  /// and get the information of the current state of it.
  ///
  /// It's also used to control the behavior of the scroll viewport inside the sheet.
  final MultiStateSheetController<StateType> scrollController;

  /// How the widgets should respond to user input.
  ///
  /// For example, determines how the widget continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions via the physics provided from
  /// the ambient [ScrollConfiguration].
  ///
  /// If an explicit [ScrollBehavior] is provided to
  /// [Scrollable.scrollBehavior], the [ScrollPhysics] provided by that behavior
  /// will take precedence after [Scrollable.physics].
  ///
  /// The physics can be changed dynamically, but new physics will only take
  /// effect if the _class_ of the provided object changes. Merely constructing
  /// a new instance with a different configuration is insufficient to cause the
  /// physics to be reapplied. (This is because the final object used is
  /// generated dynamically, which can be relatively expensive, and it would be
  /// inefficient to speculatively create this object each frame to see if the
  /// physics should be updated.)
  ///
  /// See also:
  ///
  ///  * [AlwaysScrollableScrollPhysics], which can be used to indicate that the
  ///    scrollable should react to scroll requests (and possible overscroll)
  ///    even if the scrollable's contents fit without scrolling being necessary.
  ///
  /// Please note that this physics is used only for the scrollable content inside the sheet.
  final ScrollPhysics? physics;

  /// Determines how hit testing is handled for the top header, header, and footer widgets.
  ///
  /// If set to `null`, the default hit testing behavior is applied. This property specifically
  /// affects how these widgets respond to pointer events, such as taps and gestures.
  ///
  /// For available values and their effects, see [HitTestBehavior].
  final HitTestBehavior? hitTestBehavior;

  /// Defines if the bottom sheet should be animated to the initial state
  final bool animateOpening;

  /// The shape to be used for the sheet's border.
  ///
  /// This defines the border's appearance, such as its corners and edges.
  /// It can be customized to achieve various visual effects.
  final ShapeBorder? shaper;

  /// Offsets top header relative to the height of the sheet.
  ///
  /// Positive values create spacing above the header, while negative values move it underneath the sheet.
  final StatefulSheetDelegate<double>? topHeaderOffset;

  /// Widget that will be displayed on top of the sheet header.
  ///
  /// It is drawn at the layer of the sheet widgets
  /// and is obscured by any other widget as the sheet fully opens.
  final Widget? topHeader;

  /// An optional widget that serves as the drag handle for the sheet.
  ///
  /// If provided, this widget will be displayed in the header to indicate that the sheet
  /// can be dragged or toggled by the user.
  final Widget? dragger;

  /// Unscrollable widget fixed at the top of the sheet content.
  ///
  /// It is drawn at the the top of every other widget.
  /// This header remains visible regardless of the scroll.
  final Widget? header;

  /// Sliver widget that will be placed before [SliverList] with a [content] widgets.
  ///
  /// ```dart
  /// Viewport(
  ///   slivers: [
  ///     sliver,
  ///     SliverList(children: content),
  ///   ],
  /// ),
  /// ```
  final Widget? sliver;

  /// List of widgets that represent the main content (body) of the sheet,
  /// and would be displayed inside [SliverList].
  final List<Widget>? content;

  /// The amount of padding to apply to the [content] sliver list.
  final EdgeInsets? contentPadding;

  /// Defines if the content should be kept behind the footer and not cut by it.
  final bool keepContentBehindFooter;

  /// Widget that could be a part of the header or drawn at the end of the sheet, obscuring content.
  ///
  /// Placement can be adjusted using [footerInsideHeaderLayer].
  final Widget? footer;

  /// Determine if the footer should be placed inside the header layer or the original footer layer.
  ///
  /// If `true` places the footer at the end of the header layer.
  /// Defaults to `false`
  final bool footerInsideHeaderLayer;

  /// Widget that is shown at the top of the sheet
  /// and can expand to take all available space outside the sheet.
  ///
  /// This widget shrinks as the sheet height increases and is drawn behind other widgets.
  ///
  /// ### Example:
  /// ```dart
  /// outside: const MapControls()
  /// ```
  final Widget? outside;

  /// Color that safe area or bottom padding before sheet be filled with.
  ///
  /// If you are using [SafeArea] and [TextField]s inside [MultiStateSheet] and keyboard may appear in.
  /// Make sure that you set `maintainBottomViewPadding: true` inside [SafeArea] widget.
  final Color? safeAreaColor;

  /// Color that will be bottom sheet filled with.
  final Color? backgroundColor;

  /// Delegate to calculate the barrier color behind the sheet page.
  ///
  /// Return `null` then the color is not needed.
  final StatefulSheetDelegate<Color?>? barrierColorDelegate;

  /// Delegate to calculate the opacity of the [outside] widget based on the current state of the sheet.
  final StatefulSheetDelegate<double>? outsideOpacityDelegate;

  /// Defines if [outside] widget should be drawn behind or on top of the barrier color,
  /// which is described by [barrierColorDelegate]
  final bool drawOutsideWidgetBehindBarrier;

  /// Defines if [outside] widget should be layout within the available space outside the sheet and [topHeader].
  ///
  /// if 'true' will take less space base on the size [topHeader] widget.
  ///
  /// if 'false' will ignore [topHeader] on the layout stage.
  final bool offsetOutsideWidgetByTopheader;

  /// If `true` the sheet content should size itself to avoid the onscreen keyboard
  /// whose height is defined by the ambient [MediaQuery]'s [MediaQueryData.viewInsets] property.
  ///
  /// This will affect viewport constraints and pixel offsets for all sheet states.
  final bool resizeToAvoidViewPadding;

  /// Determines whether the widget should respect the safe area insets (such as notches, status bars, and navigation bars).
  ///
  /// When set to `true`, the widget's content will avoid system UI intrusions by applying appropriate padding.
  /// When set to `false`, the content may extend into areas covered by system UI elements.
  final bool useSafeArea;

  /// Creates a [MultiStateSheet] widget, which displays a sheet that supports
  /// advanced state management and smooth transitioning between multiple states.
  ///
  /// **Note:**
  /// It is recommended **not** to use [MultiStateSheet] inside a [SafeArea] widget,
  /// as it manages its own padding and will remove any inherited paddings to ensure proper layout.
  /// Instead, you can use the [useSafeArea] property to control whether the sheet respects safe area insets.
  const MultiStateSheet({
    required this.scrollController,
    this.physics,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.animateOpening = true,
    this.shaper,
    this.outside,
    this.topHeaderOffset,
    this.topHeader,
    this.dragger = const DraggerContainer(),
    this.header,
    this.sliver,
    this.content,
    this.contentPadding,
    this.keepContentBehindFooter = false,
    this.footer,
    this.footerInsideHeaderLayer = false,
    this.safeAreaColor,
    this.backgroundColor,
    this.barrierColorDelegate,
    this.outsideOpacityDelegate,
    this.drawOutsideWidgetBehindBarrier = false,
    this.offsetOutsideWidgetByTopheader = true,
    this.resizeToAvoidViewPadding = false,
    this.useSafeArea = true,
    super.key,
  });

  @override
  State<MultiStateSheet<StateType>> createState() => _MultiStateSheetState<StateType>();
}

class _MultiStateSheetState<StateType> extends State<MultiStateSheet<StateType>> with TickerProviderStateMixin {
  late final MultiStateSheetController<StateType> controller;

  @override
  void initState() {
    super.initState();
    controller = widget.scrollController;
    controller
      .._extent.isAnimatingOpen = widget.animateOpening
      .._initAnimation(this);

    if (widget.animateOpening) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        controller.open();
      });
    }
  }

  @override
  void dispose() {
    controller._heightAnimationController?.dispose();
    controller._heightAnimationController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shaperBorder = widget.shaper;
    final dragger = widget.dragger;
    final sliverContent = widget.sliver;
    final widgetHeader = widget.header;
    final widgetContent = widget.content;
    final widgetFooter = widget.footer;

    final topHeader = widget.topHeader != null
        ? GestureDetector(
            onVerticalDragStart: (details) => controller._dragStart(details, context),
            onVerticalDragUpdate: (details) => controller._dragUpdate(details, context),
            onVerticalDragEnd: (details) => controller._dragEnd(details, context),
            behavior: widget.hitTestBehavior,
            child: widget.topHeader)
        : null;

    final header = GestureDetector(
        onVerticalDragStart: (details) => controller._dragStart(details, context),
        onVerticalDragUpdate: (details) => controller._dragUpdate(details, context),
        onVerticalDragEnd: (details) => controller._dragEnd(details, context),
        behavior: widget.hitTestBehavior,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dragger != null) dragger,
            if (widgetHeader != null) widgetHeader,
            if (widget.footerInsideHeaderLayer && widgetFooter != null) widgetFooter
          ],
        ));

    final content = Scrollable(
      controller: controller,
      physics: widget.physics,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
          overscroll: false,
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          scrollbars: false,
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown
          }),
      viewportBuilder: (context, offset) => Viewport(
        offset: offset,
        slivers: [
          if (sliverContent != null) sliverContent,
          if (widgetContent != null)
            SliverPadding(
              padding: widget.contentPadding ?? EdgeInsets.zero,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => widgetContent[index],
                  childCount: widgetContent.length,
                ),
              ),
            ),
        ],
      ),
    );

    final footer = widget.footerInsideHeaderLayer || widgetFooter == null
        ? null
        : GestureDetector(
            onVerticalDragStart: (details) => controller._dragStart(details, context),
            onVerticalDragUpdate: (details) => controller._dragUpdate(details, context),
            onVerticalDragEnd: (details) => controller._dragEnd(details, context),
            behavior: widget.hitTestBehavior,
            child: widgetFooter,
          );

    return Material(
      type: MaterialType.transparency,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => Future(() {
          if (!didPop && controller._extent.stateMapper.shouldPopOn(controller)) {
            Navigator.of(context).pop();
          }
        }),
        child: _MultiStateSheetNotifierContainer<StateType>(
          controller: controller,
          child: Builder(builder: (context) {
            final viewBottomPadding = switch (widget.resizeToAvoidViewPadding) {
              true => MediaQuery.viewInsetsOf(context).bottom,
              _ => 0.0,
            };

            final multiStateSheetWidget = _MultiStateSheetWidget<StateType>(
              key: ValueKey(controller.hashCode),
              scrollController: controller,
              viewBottomPadding: viewBottomPadding,
              safeAreaColor: widget.safeAreaColor,
              topHeaderOffset: widget.topHeaderOffset,
              drawOutsideWidgetBehindBackgroundFill: widget.drawOutsideWidgetBehindBarrier,
              offsetOutsideWidgetByTopheader: widget.offsetOutsideWidgetByTopheader,
              outsideOpacityDelegate: widget.outsideOpacityDelegate,
              backgroundColor:
                  widget.backgroundColor ?? Theme.of(context).bottomSheetTheme.backgroundColor ?? Colors.transparent,
              barrierColorDelegate: widget.barrierColorDelegate,
              keepContentBehindFooter: widget.keepContentBehindFooter,
              shaper: shaperBorder,
              outside: widget.outside,
              topHeader: topHeader,
              footer: footer,
              header: header,
              content: content,
            );
            if (widget.useSafeArea) {
              return SafeArea(child: multiStateSheetWidget);
            }

            return multiStateSheetWidget;
          }),
        ),
      ),
    );
  }
}

class _MultiStateSheetNotifierContainer<StateType> extends StatefulWidget {
  final MultiStateSheetController<StateType> controller;
  final Widget child;

  const _MultiStateSheetNotifierContainer({required this.controller, required this.child});

  @override
  State<_MultiStateSheetNotifierContainer<StateType>> createState() =>
      _MultiStateSheetNotifierContainerState<StateType>();
}

class _MultiStateSheetNotifierContainerState<StateType> extends State<_MultiStateSheetNotifierContainer<StateType>> {
  late final StateType initialState;

  @override
  Widget build(BuildContext context) => MultiStateSheetNotifier<StateType>(
        state: widget.controller.isEnabled ? widget.controller.state : initialState,
        stateInterpolation: widget.controller.interpolation,
        child: widget.child,
      );

  @override
  void didUpdateWidget(covariant _MultiStateSheetNotifierContainer<StateType> oldWidget) {
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(updateState);
      widget.controller.addListener(updateState);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(updateState);
    initialState = widget.controller._extent.stateMapper.state(widget.controller._extent.initialState);
  }

  void updateState() {
    if (mounted && !(context as ComponentElement).dirty) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(updateState);
    super.dispose();
  }
}
