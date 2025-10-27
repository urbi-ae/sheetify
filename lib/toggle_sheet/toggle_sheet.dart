import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:sheetify/sheetify.dart';
import 'package:sheetify/utils/constants.dart';
import 'package:sheetify/utils/math_helper.dart';
import 'package:sheetify/utils/round_double.dart';
import 'package:sheetify/utils/snapping_simulation.dart';

part 'render_toggle_sheet.dart';
part 'toggle_sheet_controller.dart';

/// Describes the behavior of the sheet appearance for the initial state.
enum ToggleSheetStart {
  /// Sheet will smoothly appear from the bottom of the screen
  animate,

  /// Sheet will be fully drawn in the first frame.
  instant,

  /// Sheet will be appear to be closed or not visible
  ///
  /// Outside widget will be covering all available space
  closed,
}

class ToggleSheet extends StatefulWidget {
  /// Custom [ScrollController] used to controll state of this sheet instaince
  /// and get the information of the current state of it.
  ///
  /// It's also used to control the behavior of the scroll viewport inside the sheet.
  final ToggleSheetController scrollController;

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
  ///  Please note that this physics is used only for the scrollable content inside the sheet.
  final ScrollPhysics? physics;

  /// Determines how hit testing is handled for the top header, header, and footer widgets.
  ///
  /// If set to `null`, the default hit testing behavior is applied. This property specifically
  /// affects how these widgets respond to pointer events, such as taps and gestures.
  ///
  /// For available values and their effects, see [HitTestBehavior].
  final HitTestBehavior? hitTestBehavior;

  /// Describes the behavior of the sheet appearance for the initial state.
  final ToggleSheetStart startConfig;

  /// Delegate to dynamically calculate the border shape and it's radius.
  ///
  /// If `null` then the [RRect] shape will be used with radius of 16 px.
  final ToggleSheetDelegate<ShapeBorder?>? shapeBorderDelegate;

  /// Offsets top header relative to the height of the sheet.
  ///
  /// Positive values create spacing above the header, while negative values move it underneath the sheet.
  final double? topHeaderOffset;

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

  /// The amount of padding to apply to the [content] list.
  final EdgeInsets? contentPadding;

  /// Widget that could be a part of the header or drawn at the end of the sheet, abscuring content
  ///
  /// See also [footerInsideHeaderLayer] parameter.
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
  final Color? safeAreaColor;

  /// Color that will be sheet filled with.
  final Color? backgroundColor;

  /// Delegate to calculate the barrier color behind the sheet page.
  ///
  /// Return `null` then the barrier is not needed.
  final ToggleSheetDelegate<Color?>? barrierColorDelegate;

  /// Delegate to calculate the opacity of the [outside] widget based on the current state of the sheet.
  final ToggleSheetDelegate<double>? outsideOpacityDelegate;

  /// Defines if [outside] widget should be drawn behind or on top of background fill color,
  /// which is described by [barrierColorDelegate]
  final bool drawOutsideWidgetBehindBackground;

  /// Defines if [outside] widget should be layout within the available space outside the sheet and [topHeader].
  ///
  /// if 'true' will take less space base on the size [topHeader] widget.
  ///
  /// if 'false' will ignore [topHeader] on the layout stage.
  final bool offsetOutsideWidgetByTopheader;

  /// Delegate to calculate the inner padding for the sheet.
  ///
  /// The padding will be applied to the sheet inself.
  final ToggleSheetDelegate<EdgeInsets?>? paddingDelegate;

  final bool Function(ToggleSheetController)? shouldPop;

  /// If `true` the sheet content should size itself to avoid the onscreen keyboard
  /// whose height is defined by the ambient [MediaQuery]'s [MediaQueryData.viewInsets] property.
  ///
  /// This will affect viewport constraints and pixel offsets for all sheet states.
  ///
  /// If you are using [SafeArea] and [TextField]s inside [ToggleSheet] and keyboard may appear in.
  /// Make sure that you set `maintainBottomViewPadding: false` inside [SafeArea] widget
  /// to prevent safe area appear at top of keyboard.
  ///
  /// Otherwise, set `maintainBottomViewPadding: true`.
  final bool resizeToAvoidBottomPadding;

  /// Determines whether the widget should respect the safe area insets
  /// (such as notches, status bars, and navigation bars).
  ///
  /// When set to `true`, the widget’s content avoids system UI intrusions
  /// by applying appropriate padding based on the current safe area.
  ///
  /// ---
  ///
  /// ### Keyboard Insets Integration
  /// When combined with the [`keyboard_insets`](https://pub.dev/packages/keyboard_insets) package,
  /// this flag ensures that the bottom padding remains **stable during keyboard animations**,
  /// preventing visual jumps when the keyboard appears or hides.
  ///
  /// If this flag sets to `true` make sure to handle its lifecycle properly:
  ///
  /// ```dart
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   PersistentSafeAreaBottom.startObservingSafeArea();
  /// }
  ///
  /// @override
  /// void dispose() {
  ///   PersistentSafeAreaBottom.stopObservingSafeArea();
  ///   super.dispose();
  /// }
  /// ```
  final bool useSafeArea;

  /// Creates a [ToggleSheet] widget.
  ///
  /// The [ToggleSheet] widget provides a customizable sheet that can be toggled
  /// open or closed. Use this constructor to configure its appearance and behavior.
  ///
  /// **Note:**
  /// It is recommended **not** to use [ToggleSheet] inside a [SafeArea] widget,
  /// as it manages its own padding and will remove any inherited paddings to ensure proper layout.
  /// Instead, you can use the [useSafeArea] property to control whether the sheet respects safe area insets.
  const ToggleSheet({
    required this.scrollController,
    this.physics,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.startConfig = ToggleSheetStart.animate,
    this.shapeBorderDelegate,
    this.paddingDelegate,
    this.shouldPop,
    this.outside,
    this.topHeaderOffset,
    this.topHeader,
    this.dragger = const DraggerContainer(),
    this.header,
    this.sliver,
    this.content,
    this.contentPadding,
    this.footer,
    this.footerInsideHeaderLayer = false,
    this.safeAreaColor,
    this.backgroundColor,
    this.barrierColorDelegate,
    this.outsideOpacityDelegate,
    this.drawOutsideWidgetBehindBackground = false,
    this.offsetOutsideWidgetByTopheader = true,
    this.resizeToAvoidBottomPadding = true,
    this.useSafeArea = true,
    super.key,
  });

  @override
  State<ToggleSheet> createState() => _StatelessSheetState();
}

class _StatelessSheetState extends State<ToggleSheet>
    with TickerProviderStateMixin {
  late final ToggleSheetController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.scrollController;
    controller
      .._extent.isClosed = widget.startConfig != ToggleSheetStart.instant
      .._isAnimatingOpen = widget.startConfig == ToggleSheetStart.animate
      .._isStartsClosed = widget.startConfig == ToggleSheetStart.closed
      .._initAnimation(this);

    if (widget.startConfig == ToggleSheetStart.animate) {
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
    final dragger = widget.dragger;
    final widgetHeader = widget.header;
    final sliverContent = widget.sliver;
    final widgetContent = widget.content;
    final widgetFooter = widget.footer;

    final topHeader = widget.topHeader != null
        ? GestureDetector(
            behavior: widget.hitTestBehavior,
            onVerticalDragStart: (details) =>
                controller._dragStart(details, context),
            onVerticalDragUpdate: (details) =>
                controller._dragUpdate(details, context),
            onVerticalDragEnd: (details) =>
                controller._dragEnd(details, context),
            child: widget.topHeader)
        : null;

    final header = GestureDetector(
        behavior: widget.hitTestBehavior,
        onVerticalDragStart: (details) =>
            controller._dragStart(details, context),
        onVerticalDragUpdate: (details) =>
            controller._dragUpdate(details, context),
        onVerticalDragEnd: (details) => controller._dragEnd(details, context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dragger != null) dragger,
            if (widgetHeader != null) widgetHeader,
            if (widget.footerInsideHeaderLayer && widgetFooter != null)
              widgetFooter
          ],
        ));

    final content = Scrollable(
        key: ValueKey(controller.hashCode),
        controller: controller,
        physics: widget.physics,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
            overscroll: false,
            physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics()),
            scrollbars: false,
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown
            }),
        viewportBuilder: (context, offset) {
          return ShrinkWrappingViewport(
            key: ValueKey(controller.hashCode),
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
          );
        });

    final footer = widget.footerInsideHeaderLayer || widgetFooter == null
        ? null
        : GestureDetector(
            behavior: widget.hitTestBehavior,
            onVerticalDragStart: (details) =>
                controller._dragStart(details, context),
            onVerticalDragUpdate: (details) =>
                controller._dragUpdate(details, context),
            onVerticalDragEnd: (details) =>
                controller._dragEnd(details, context),
            child: widgetFooter,
          );

    return Material(
      type: MaterialType.transparency,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => Future(() {
          if (!didPop && shouldPop()) {
            controller.reset();
            Navigator.of(context).pop();
          }
        }),
        child: ValueListenableBuilder(
            valueListenable:
                PersistentSafeAreaBottom.notifier ?? ValueNotifier(0.0),
            builder: (context, safeAreaBottom, child) {
              final toggleSheetWidget = _ToggleSheetWidget(
                key: ValueKey(controller.hashCode),
                scrollController: controller,
                topHeaderOffset: widget.topHeaderOffset,
                safeAreaColor: widget.safeAreaColor,
                offsetOutsideWidgetByTopheader:
                    widget.offsetOutsideWidgetByTopheader,
                outsideOpacityDelegate: widget.outsideOpacityDelegate,
                barrierColorDelegate: widget.barrierColorDelegate,
                backgroundColor: widget.backgroundColor ??
                    Theme.of(context).bottomSheetTheme.backgroundColor ??
                    Colors.transparent,
                shapeBorderDelegate: widget.shapeBorderDelegate,
                paddingDelegate: widget.paddingDelegate,
                safeAreaBottomPadding: safeAreaBottom,
                resizeToAvoidBottomPadding: widget.resizeToAvoidBottomPadding,
                drawOutsideWidgetBehindBackgroundFill:
                    widget.drawOutsideWidgetBehindBackground,
                topHeader: topHeader,
                outside: widget.outside,
                footer: footer,
                header: header,
                content: content,
              );
              if (widget.useSafeArea) {
                return PersistentSafeArea(child: toggleSheetWidget);
              }

              return toggleSheetWidget;
            }),
      ),
    );
  }

  bool shouldPop() => widget.shouldPop?.call(controller) ?? true;
}
