part of 'package:sheetify/toggle_sheet/toggle_sheet.dart';

typedef ToggleSheetOnCloseCallback = void Function(ToggleSheetController controller);

/// A class that represents the extent (size) of a toggle sheet.
///
/// This class is typically used to define and manage the minimum, maximum,
/// and current extents of a toggleable sheet component.
class ToggleSheetExtent {
  /// Diclarates how fast the sheet snapping to the next position will be.
  final double durationMultiplier;

  /// A multiplier that determines the force applied to velocity in snapping position calculations.
  final double forceMultiplier;

  final Duration? snapAnimationDuration;

  final VoidCallback? onOffsetChanged;

  final bool clipByHeader;

  VoidCallback? _cancelActivity;
  bool isClosed = true;
  double _offset = 0.0;
  double availablePixels;
  ToggleSheetHeightModel? heightModel;
  SheetWidgetSizes componentSizes;

  double? get fixedHeightOffset {
    final model = heightModel;
    if (model != null) {
      return math.max(0.0, model.getHeight(availablePixels));
    }

    return null;
  }

  ToggleSheetExtent({
    required this.availablePixels,
    required this.clipByHeader,
    required this.durationMultiplier,
    required this.forceMultiplier,
    this.heightModel,
    this.onOffsetChanged,
  })  : snapAnimationDuration = kDefaultSheetScrollDuration,
        componentSizes = const SheetWidgetSizes.zero();

  /// Height in pixels from the top of the bounding box at which the sheet starts to draw.
  double _minHeight = 0.0;

  /// Height in pixels from the top of the bounding box at which the sheet starts to draw.
  double get minHeight => math.min(fixedHeightOffset ?? _minHeight, availablePixels);

  /// Height in pixels from the top of the bounding box at which the sheet starts to draw.
  set minHeight(double value) {
    if (heightModel == null) {
      _minHeight = value;
    }
  }

  /// Height in pixels from the top of the bounding box at which the sheet ends to draw.
  double get maxHeight => availablePixels - (clipByHeader ? (componentSizes.header) : 0.0);

  /// Current height offset for sheet visible view.
  ///
  /// Then the this = `0` - sheet is fully visible.
  /// Then the this = [availablePixels] - sheet is fully hidden
  double get offset => _offset;

  bool get isAtMin => maxHeight.roundDecimal() <= offset.roundDecimal();
  bool get isAtMax => minHeight.roundDecimal() >= offset.roundDecimal();

  void startActivity({required VoidCallback onCanceled}) {
    _cancelActivity?.call();
    _cancelActivity = onCanceled;
  }

  void addPixelDelta(double delta) => updateSize(offset + delta);

  void updateSize(double newHeight, {bool isAnimating = false, bool notify = true}) {
    _cancelActivity?.call();
    _cancelActivity = null;

    if (availablePixels == kStartOfTheViewport) {
      return;
    }
    final double clampedHeight =
        isAnimating ? math.max(minHeight, newHeight) : clampDouble(newHeight, minHeight, maxHeight);

    if (_offset == clampedHeight) {
      return;
    }

    _offset = clampedHeight;

    if (clampedHeight <= maxHeight) {
      isClosed = clampedHeight >= maxHeight;
    }

    if (notify) {
      onOffsetChanged?.call();
    }
  }
}

/// A controller for managing the state of a toggle sheet.
///
/// This controller provides functionality for:
/// - Opening, closing, and snapping the sheet.
/// - Animating transitions between open and closed states.
/// - Adjusting for user interactions and gestures.
/// - Supporting the [ToggleSheetHeightModel].
///
/// ### Key Features:
/// - **Interactive Control**: Allows gestures to modify the sheet's height and state.
/// - **Snapping and Animation**: Smooth animations for transitioning between states.
/// - **Customization**: Supports duration multipliers, [ToggleSheetHeightModel], and external callbacks.
class ToggleSheetController extends ScrollController {
  /// Adjusts the speed of snapping animations.
  ///
  /// - A value greater than `1.0` speeds up animations.
  /// - A value less than `1.0` slows down animations.
  final double durationMultiplier;

  /// Adjusts the force applied to velocity in snapping position calculations.
  ///
  /// - A value greater than `1.0` makes the sheet more anchored to the next position.
  /// - A value less than `1.0` makes the sheet less anchored to the next position
  /// and more anchored to the previous position.
  final double forceMultiplier;

  /// Callback invoked when the sheet is fully closed.
  ///
  /// This is triggered when the sheet height reaches `0.0` or when the [close] method completes.
  final ToggleSheetOnCloseCallback? onClose;

  /// Defines if the content scroll should reset then sheet state is hidden.
  final bool resetContentScrollOnClosed;

  /// Defines if the sheet should be clipped by the header in the closed state.
  bool get clipByHeader => _extent.clipByHeader;

  /// Indicates whether the sheet can be closed interactively by dragging.
  ///
  /// When set to `false`, gestures will not affect the sheet's height.
  bool get isInteractive => _isInteractive;
  set isInteractive(bool value) {
    _isInteractive = value;
    if (positions.isNotEmpty) {
      position.isInteractive = value;
    }
  }

  bool _isInteractive = true;

  /// Defines the sheet's state, including offsets and available space.
  late final ToggleSheetExtent _extent;

  /// Constructs a `ToggleSheetController`.
  ///
  /// - [durationMultiplier]: Adjusts the animation speed (default is `1.0`).
  /// - [onClose]: A callback invoked when the sheet is fully closed.
  /// - [heightModel]: A custom height model for defining the fixed offset (optional).
  /// - [isInteractive]: Whether the sheet responds to gestures (default is `true`).
  ///
  /// ### Example:
  /// ```dart
  /// ToggleSheetController(
  ///   durationMultiplier: 1.5,
  ///   onClose: (controller) => print('Sheet is closed'),
  ///   heightModel: ToggleSheetHeightModel.fixed(double 600),
  ///   isInteractive: true,
  /// );
  /// ```
  ToggleSheetController({
    this.durationMultiplier = 1.0,
    this.forceMultiplier = 1.25,
    this.onClose,
    this.resetContentScrollOnClosed = false,
    bool clipByHeader = false,
    ToggleSheetHeightModel? heightModel,
    bool isInteractive = true,
  }) {
    _extent = ToggleSheetExtent(
      availablePixels: kStartOfTheViewport,
      durationMultiplier: durationMultiplier,
      onOffsetChanged: _notifyHeightChanged,
      heightModel: heightModel,
      clipByHeader: clipByHeader,
      forceMultiplier: forceMultiplier,
    );
    this.isInteractive = isInteractive;
  }

  //--------------------------------------------------------------------------------------//
  //                            Public Properties and Methods                             //
  //--------------------------------------------------------------------------------------//

  /// The height of the sheet's visible area.
  ///
  /// Calculated based on the difference between the total available pixels
  /// and the current offset.
  double get sheetHeight {
    final offsetFromTop = _isAnimatingOpen || _extent.maxHeight <= _extent.minHeight
        ? _extent.offset
        : clampDouble(
            _extent.offset,
            _extent.minHeight,
            _extent.maxHeight,
          );

    return _isEnabled ? _extent.availablePixels - offsetFromTop : 0.0;
  }

  /// The total viewport height available to the sheet.
  double get viewportHeight => _extent.availablePixels;

  /// Aspect ratio of the sheet's visible height to its posible maximum height.
  double get fraction => math.max(0, sheetHeight / (_extent.maxHeight));

  /// Returns the current interpolation value, typically representing
  /// the progress between two states (e.g., expanded and collapsed)
  /// as a double between 0.0 and 1.0.
  ///
  /// This value can be used for animations or to determine the visual
  /// state of the toggle sheet.
  double get interpolation {
    if (_extent.minHeight >= _extent.maxHeight) {
      return 1.0;
    }

    return lerpBetween(
      clampDouble(_extent.offset, _extent.minHeight, _extent.maxHeight),
      0.0,
      1.0,
      _extent.minHeight,
      _extent.maxHeight,
    );
  }

  /// Indicates whether the sheet is currently open and visible.
  bool get isEnabled => _isEnabled;

  /// Indicates whether the sheet is closed and fully hidden.
  bool get isClosed => _extent.isClosed;

  /// Returns model that represent a sheet component sizes.
  SheetWidgetSizes get componentSizes => _extent.componentSizes;

  @override
  _ToggleSheetScrollPosition get position => super.position as _ToggleSheetScrollPosition;

  //--------------------------------------------------------------------------------------//
  //                                  Public API Methods                                  //
  //--------------------------------------------------------------------------------------//

  /// Resets the controller to its initial state, preparing it for reuse.
  void reset() {
    if (_isEnabled) {
      _heightAnimationController?.reset();
      _extent
        .._offset = 0.0
        ..availablePixels = 0.0
        ..isClosed = true;
      _isEnabled = false;

      _isAnimatingOpen = false;
      notifyListeners();
    }
  }

  /// Animates the sheet to a fully closed state.
  ///
  /// - [duration]: Optional duration for the closing animation.
  void close({Duration? duration}) {
    if (isEnabled) {
      final newPosition = viewportHeight;
      final _duration = duration?.inMilliseconds ?? math.max((_extent.offset - newPosition).abs().round(), 150).toInt();
      _startAnimation(_extent.offset, newPosition, Curves.easeOutExpo, _duration);
    }
  }

  /// Animates the sheet to a fully open state.
  ///
  /// - [duration]: Optional duration for the opening animation.
  void open({Duration? duration}) {
    if (isClosed) {
      _animateOpen(duration: duration);
    }
  }

  /// Updates the current height model of the toggle sheet.
  ///
  /// This method sets the height model to the provided [model]. If [model] is `null`,
  /// it may reset or clear the current height configuration, depending on the implementation.
  ///
  /// [model] - The new [ToggleSheetHeightModel] to apply, or `null` to reset.
  void updateHeightModel(ToggleSheetHeightModel? model) {
    _extent.heightModel = model;

    _isChangingHeightModel = true;
    Future(notifyListeners);
  }

  @override
  void attach(ScrollPosition position) {
    if (position.hasPixels &&
        position is _ToggleSheetScrollPosition &&
        position._extent.availablePixels > 0 &&
        position._extent.offset >= 0) {
      _isEnabled = true;
    }

    if (positions.isNotEmpty) {
      super.detach(positions.first);
    }

    super.attach(position);
  }

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics, ScrollContext context, ScrollPosition? oldPosition) =>
      _ToggleSheetScrollPosition(
        physics: physics,
        context: context,
        oldPosition: oldPosition,
        getExtent: () => _extent,
        isInteractive: isInteractive,
        onClose: () {
          if (_extent.isClosed) {
            if (resetContentScrollOnClosed) {
              _resetScrollPosition();
            }
            onClose?.call(this);
          }
        },
      );

  @override
  void detach(ScrollPosition position) {
    _isEnabled = false;

    if (positions.contains(position)) {
      super.detach(position);
    }
  }

  @override
  void dispose() {
    _heightAnimationController?.stop();
    _heightAnimationController?.removeListener(_onHeightChanged);
    _heightAnimationController?.dispose();
    _heightAnimationController = null;

    super.dispose();
  }

  //--------------------------------------------------------------------------------------//
  //                              Private Fields and Methods                              //
  //--------------------------------------------------------------------------------------//

  bool _isEnabled = false;
  bool _isPreformingResize = false;
  bool _isAnimatingOpen = false;
  bool _isStartsClosed = false;
  bool _isChangingHeightModel = false;
  bool _isDragging = false;

  double? _lastPosition;
  double? _appliedDelta;

  AnimationController? _heightAnimationController;
  double get _heightAnimationPosition => _heightAnimationController!.value;

  double? _updateHeightBoundings(double min, double max) {
    bool correctPosition = false;
    double? instantOffset;

    if (_extent.availablePixels != max) {
      _extent.availablePixels = max;

      correctPosition = isEnabled && !_isAnimatingOpen && (!isClosed);
    }

    if (_extent.minHeight != min && _extent.heightModel == null) {
      _extent.minHeight = min;

      final isAnimating =
          (_heightAnimationController?.isAnimating ?? false) || position._ballisticControllers.isNotEmpty;

      final isDragging = _isDragging || position.isDragging;

      if (isEnabled && !isAnimating && !isDragging && (!isClosed || clipByHeader)) {
        _extent._offset = isClosed ? _extent.maxHeight : _extent.minHeight;
        correctPosition = true;

        instantOffset = _extent._offset;
      }
    }

    if (correctPosition) {
      _startAnimation(_extent._offset, isClosed ? _extent.maxHeight : _extent.minHeight, Curves.linear, 1);
    }

    return instantOffset;
  }

  /// Calculates the initial position of the sheet and sets its enabled state.
  ///
  /// This method is internally used by render object to set the initial position of the sheet.
  double? _calculateInitialPositionAndSetEnabled() {
    final newPosition =
        _isStartsClosed ? _extent.availablePixels : _extent.heightModel?.getHeight(_extent.availablePixels);

    _isEnabled = true;
    _isPreformingResize = false;

    if (newPosition != null) {
      _extent.updateSize(newPosition, notify: false);
    }

    Future(notifyListeners);

    return newPosition;
  }

  /// Handles the start of a drag gesture on the sheet.
  ///
  /// This method is typically called when a drag gesture is detected,
  /// allowing the controller to initialize any necessary state or
  /// perform setup actions before the drag progresses.
  void _dragStart(DragStartDetails details, BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (positions.isNotEmpty) {
        ScrollStartNotification(
          context: context,
          metrics: position,
          dragDetails: details,
        ).dispatch(context);
      }
    });
    _isDragging = true;
    _lastPosition = details.localPosition.dy;
    _appliedDelta = 0.0;
  }

  /// Method to update size of the sheet viewport then user is dragging by holding a header component.
  void _dragUpdate(DragUpdateDetails details, BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (positions.isNotEmpty) {
        ScrollUpdateNotification(context: context, metrics: position, dragDetails: details).dispatch(context);
      }
    });

    if (!isInteractive) {
      return;
    }

    if (details.localPosition.dy > 0.0) {
      final delta = (details.localPosition.dy - (_lastPosition ?? 0.0)) - (_appliedDelta ?? 0.0);
      _appliedDelta = (_appliedDelta ?? 0) + delta;

      /// Check for scrolling direction based on the delta from start to current drag position
      /// that it is can be dragged to the same direction as the current applied delta.
      final isScrollingDown = delta > 0 && (_appliedDelta ?? 0.0) >= 0;
      final isScrollingUp = delta < 0 && (_appliedDelta ?? 0.0) <= 0;

      final isOpen = _extent.offset == _extent.minHeight;
      if ((isScrollingDown || isScrollingUp) && isOpen || !isOpen) {
        _extent.addPixelDelta(delta);
      }
    }
  }

  /// Forcing to change the height of the sheet based on the velocity of the drag.
  ///
  /// New position will be applied with the animation.
  void _dragEnd(DragEndDetails details, BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (positions.isNotEmpty) {
        ScrollEndNotification(
          context: context,
          metrics: position,
          dragDetails: details,
        ).dispatch(context);
      }
    });

    if (!isInteractive) {
      return;
    }

    _isDragging = false;

    final simulation = SnappingSimulation(
      position: _extent.offset,
      initialVelocity: details.velocity.pixelsPerSecond.dy / kVelocityCorrectionFactor,
      durationMultiplier: _extent.durationMultiplier,
      pixelSnapPositions: [_extent.minHeight, _extent.maxHeight],
      snapAnimationDuration: _extent.snapAnimationDuration ?? kDefaultSheetScrollDuration,
      tolerance: position.physics.toleranceFor(position),
      forceMultiplier: _extent.forceMultiplier,
    );

    position._stopBallisticAnimation();

    _heightAnimationController?.stop();
    _heightAnimationController?.value = _extent.offset;
    _heightAnimationController?.animateWith(simulation).whenComplete(() {
      _isAnimatingOpen = false;
      if (_extent.offset == _extent.maxHeight) {
        _extent.isClosed = true;
        if (resetContentScrollOnClosed) {
          _resetScrollPosition();
        }

        onClose?.call(this);
      }
    });
  }

  /// Method used to animating sheet from not visable state to initial state position.
  void _animateOpen({Duration? duration}) {
    /// Set new position to 0.0 instead of minHeight to ensure that the sheet is fully open if content size changed.
    const newPosition = 0.0;
    _isEnabled = true;
    _extent._offset = _extent.availablePixels;

    final _duration = duration?.inMilliseconds ??
        math.max(kDefaultSheetScrollDuration.inMilliseconds, (_extent.offset - newPosition).abs().round()) +
            _extent.minHeight.round();
    _isAnimatingOpen = true;

    _startAnimation(
      _extent.offset,
      newPosition,
      Curves.easeOutExpo,
      _duration,
    );
  }

  void _initAnimation(TickerProvider vsync) {
    _heightAnimationController = AnimationController.unbounded(vsync: vsync);
    _heightAnimationController?.addListener(_onHeightChanged);
  }

  void _startAnimation(double startPosition, double position, Curve curve, int duration) {
    this.position._stopBallisticAnimation();
    _heightAnimationController?.stop();
    _heightAnimationController?.value = startPosition;
    _heightAnimationController
        ?.animateTo(
      math.min(position, _extent.maxHeight),
      curve: curve,
      duration: Duration(milliseconds: (duration * durationMultiplier).toInt()),
    )
        .whenCompleteOrCancel(() {
      _isAnimatingOpen = false;

      if (_extent.offset == _extent.maxHeight && isEnabled) {
        _extent.isClosed = true;
        if (resetContentScrollOnClosed) {
          _resetScrollPosition();
        }

        onClose?.call(this);
      }
    });
  }

  /// Resets the scroll position when the sheet is hidden.
  void _resetScrollPosition() {
    jumpTo(0);
  }

  void _onHeightChanged() {
    final oldOffset = _extent.offset;
    if (oldOffset != _heightAnimationPosition && _heightAnimationPosition.isFinite) {
      _extent.updateSize(_heightAnimationPosition, isAnimating: _isAnimatingOpen);
    }
  }

  void _notifyHeightChanged() {
    if (_isEnabled && !_isPreformingResize) {
      notifyListeners();
    }
  }
}

class _ToggleSheetScrollPosition extends ScrollPositionWithSingleContext {
  final ToggleSheetExtent Function() getExtent;
  final Set<AnimationController> _ballisticControllers = <AnimationController>{};
  late final ToggleSheetExtent _extent = getExtent();

  bool isInteractive;
  bool isDragging = false;

  VoidCallback? _dragCancelCallback;

  VoidCallback? onClose;

  _ToggleSheetScrollPosition({
    required super.physics,
    required super.context,
    required this.getExtent,
    required this.isInteractive,
    this.onClose,
    super.oldPosition,
  });

  bool get listShouldScroll => pixels > 0.0;

  @override
  void absorb(ScrollPosition other) {
    super.absorb(other);

    if (other is! _ToggleSheetScrollPosition) {
      return;
    }

    if (other._dragCancelCallback != null) {
      _dragCancelCallback = other._dragCancelCallback;
      other._dragCancelCallback = null;
    }
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    if (newActivity is DragScrollActivity) {
      isDragging = true;
    }
    _stopBallisticAnimation();
    super.beginActivity(newActivity);
  }

  @override
  void applyUserOffset(double delta) {
    /// Check if the scroll position of the content list is within the bounds to control sheet height by scrolling.
    final isSheetAtMaxAndScrollsUp = !_extent.isAtMin && _extent.isAtMax && delta < 0;
    final canContentScrollDown = !_extent.isAtMin && pixels > 0 && delta > 0;
    if (isSheetAtMaxAndScrollsUp || canContentScrollDown) {
      super.applyUserOffset(delta);
    } else {
      if (isInteractive) {
        _extent.addPixelDelta(delta);
      }
    }
  }

  @override
  void dispose() {
    for (final AnimationController ballisticController in _ballisticControllers) {
      ballisticController.dispose();
    }

    _ballisticControllers.clear();

    super.dispose();
  }

  @override
  void goBallistic(double velocity) {
    final isShouldScrollContentDown = velocity > 0.0 && _extent.isAtMax && listShouldScroll;
    final isShouldScrollContentUp = velocity < 0.0 && !(_extent.isAtMin && _extent.isAtMax) && listShouldScroll;
    if (!isInteractive || isShouldScrollContentDown || isShouldScrollContentUp || !isScrollingNotifier.value) {
      super.goBallistic(velocity);
      return;
    }

    _dragCancelCallback?.call();
    _dragCancelCallback = null;
    isDragging = false;

    final simulation = SnappingSimulation(
      position: _extent.offset,
      initialVelocity: -velocity,
      durationMultiplier: _extent.durationMultiplier,
      pixelSnapPositions: [_extent.minHeight, _extent.maxHeight],
      snapAnimationDuration: _extent.snapAnimationDuration ?? kDefaultSheetScrollDuration,
      forceMultiplier: _extent.forceMultiplier,
      tolerance: physics.toleranceFor(this),
    );

    final AnimationController ballisticController = AnimationController.unbounded(
      debugLabel: objectRuntimeType(this, '_ToggleSheetScrollPosition'),
      vsync: context.vsync,
    );

    _ballisticControllers.add(ballisticController);

    void tick() {
      _extent.updateSize(ballisticController.value);

      if ((velocity > 0 && _extent.isAtMax) || (velocity < 0 && _extent.isAtMin)) {
        final physicsVelocity = ballisticController.velocity + (physics.toleranceFor(this).velocity);
        super.goBallistic(-physicsVelocity);

        if (ballisticController.isDismissed) {
          ballisticController.stop();
        }
      } else if (ballisticController.isCompleted) {
        super.goBallistic(0);
      }
    }

    ballisticController
      ..addListener(tick)
      ..animateWith(simulation).whenCompleteOrCancel(
        () {
          if (_ballisticControllers.contains(ballisticController)) {
            _ballisticControllers.remove(ballisticController);
            ballisticController.dispose();
          }
          if (_extent.availablePixels - _extent.offset <= 0.0) {
            onClose?.call();
          }
        },
      );
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    _dragCancelCallback = dragCancelCallback;
    return super.drag(details, dragCancelCallback);
  }

  void _stopBallisticAnimation() {
    for (final AnimationController ballisticController in _ballisticControllers) {
      if (ballisticController.isDismissed) {
        ballisticController
          ..stop()
          ..dispose();
      }
    }
    _ballisticControllers.clear();
  }
}
