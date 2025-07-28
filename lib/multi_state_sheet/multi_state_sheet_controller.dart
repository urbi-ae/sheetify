// ignore_for_file: avoid_setters_without_getters

part of 'package:sheetify/multi_state_sheet/multi_state_sheet.dart';

/// A class that represents the extent (size) of a multi state sheet.
///
/// This class is typically used to define and manage the minimum, maximum,
/// and current extents of a multi state sheet component.
class MultiStateSheetExtent<StateType> {
  /// Diclarates how fast the sheet snapping to the next position will be.
  final double durationMultiplier;
  final double forceMultiplier;

  final SnappingBehavior behavior;
  final SheetStateMapper<StateType> stateMapper;

  final Duration? snapAnimationDuration;
  final int initialState;

  final VoidCallback? onStateChanged;
  final VoidCallback? onOffsetChanged;
  VoidCallback? _cancelActivity;

  /// Tracks whether the layout needs to be updated.
  ///
  /// 'true' if controller has already notified listeners about height change at this frame.
  /// And only needs to notify external listeners for the component's height change.
  ///
  /// Resets inside [_RenderMultiStateSheet.onSheetOffsetChanges] method.
  bool _doNotMarkNeedsLayout = false;

  late double _offset = behavior.statePosition(
    extent: this,
    state: initialState,
  );
  int _state;
  double _interpolation;

  SheetWidgetSizes initialComponentSizes;
  SheetWidgetSizes componentSizes;
  double availablePixels;

  bool isEnabled = false;
  bool isPreformingResize = false;
  bool isAnimatingOpen = false;

  MultiStateSheetExtent({
    required this.behavior,
    required this.stateMapper,
    required this.initialState,
    required this.availablePixels,
    required this.durationMultiplier,
    this.forceMultiplier = 1.0,
    this.onStateChanged,
    this.onOffsetChanged,
  })  : snapAnimationDuration = kDefaultSheetScrollDuration,
        _state = initialState,
        _interpolation = kZeroHeight,
        initialComponentSizes = const SheetWidgetSizes.zero(),
        componentSizes = const SheetWidgetSizes.zero();

  /// Height in pixels from the top of the bounding box at which the sheet starts to draw.
  double get minOffset => behavior.minOffset;

  /// Height in pixels from the top of the bounding box at which the sheet ends to draw.
  double get maxOffset {
    final maxOffset = behavior.maxOffset;
    return maxOffset > minOffset ? maxOffset : availablePixels;
  }

  double get safeMaxOffset => isAnimatingOpen ? maxOffset : behavior.safeMaxOffset;

  /// Current height offset for sheet visible view.
  ///
  /// Then the this = `0` - sheet is fully visible.
  /// Then the this = [availablePixels] - sheet is fully hidden
  double get offset => _offset;

  /// Interpolation value between states.
  ///
  /// Value of `0` indicates the start of the state position
  ///
  /// And value of `1` indicates the end of the state position
  double get stateInterpolation => _interpolation;

  /// Current state of the sheet layout.
  ///
  /// It's not snapped to the actual state position of the viewport,
  /// rather, it changes based on the scroll height when it enters the region of the closest state to anchor.
  int get currentState => _state;

  /// The actual state of states to snap on, on which is [stateInterpolation] value relied on and at which it takes the starting point.
  int get anchoredState => behavior.needsSetup ? initialState : behavior.anchoredState(this);

  bool get isAtMin =>
      (behavior.isMaxOffsetFinalized ? behavior.maxOffset : availablePixels).roundDecimal() <= offset.roundDecimal();

  bool get isAtMax => minOffset.roundDecimal() >= offset.roundDecimal();

  void startActivity({required VoidCallback onCanceled}) {
    _cancelActivity?.call();
    _cancelActivity = onCanceled;
  }

  void addPixelDelta(double delta) => updateSize(offset + delta);

  void updateState() {
    /// Sets new state based on the height;
    _setState(behavior.getState(extent: this, offset: _offset));
    _interpolation = behavior.getInterpolation(extent: this, offset: _offset);
  }

  void updateSize(double newOffset, {bool isAnimating = false, bool notify = true}) {
    _cancelActivity?.call();
    _cancelActivity = null;

    if (availablePixels == kStartOfTheViewport) {
      return;
    }
    final double clampedOffset = isAnimating ? newOffset : clampDouble(newOffset, minOffset, safeMaxOffset);

    if (_offset == clampedOffset) {
      return;
    }

    _offset = clampedOffset;

    updateState();

    if (notify) {
      onOffsetChanged?.call();
    }
  }

  /// Method to update size of the sheet's components.
  double? updateComponents(
    double topHeaderHeight,
    double headerHeight,
    double contentHeight,
    double footerHeight,
  ) {
    if (componentSizes.topHeader != topHeaderHeight ||
        componentSizes.header != headerHeight ||
        componentSizes.content != contentHeight ||
        componentSizes.footer != footerHeight) {
      final needsResetupClipping =
          behavior.clipByHeader && behavior.headerShiftHeight != headerHeight && _state == 0 && _interpolation == 0.0;

      componentSizes = SheetWidgetSizes(
        topHeader: topHeaderHeight,
        header: headerHeight,
        content: contentHeight,
        footer: footerHeight,
      );

      /// Reset up behavior if the components are changed their sizes in the initial state
      ///
      /// This is needed to recalculate the snapping positions based on the new component sizes.
      ///
      /// It's could happen then components are changed their sizes on their own without the sheet height update.
      /// For example, then the component was waiting for the data to be loaded and change it's size then the data is loaded.
      final isComponentsUpdatedAtTheInitialState =
          anchoredState == initialState && stateInterpolation == 0 && initialComponentSizes != componentSizes;
      if (initialComponentSizes.isZero || isComponentsUpdatedAtTheInitialState) {
        initialComponentSizes = componentSizes;
        behavior.setup(this);
        _offset = behavior.statePosition(extent: this, state: initialState);
        updateState();
        _doNotMarkNeedsLayout = true;
        Future(() => onOffsetChanged?.call());
        return _offset;
      } else if (needsResetupClipping) {
        behavior.setup(this);

        _offset = behavior.statePosition(extent: this, state: _state).clamp(minOffset, maxOffset);
        updateState();
        _doNotMarkNeedsLayout = true;
        Future(() => onOffsetChanged?.call());
        return _offset;
      }
    }
    return null;
  }

  void _setState(int newState) {
    if (currentState != newState) {
      _state = newState;
      onStateChanged?.call();
    }
  }
}

/// Controller for managing the state and behavior of a [MultiStateSheet].
///
/// The [MultiStateSheetController] enables external interaction with the
/// sheet's snapping behavior, scrolling, animations, and component sizes.
///
/// ### Key Features:
/// - External control of snapping and scrolling.
/// - Dynamic component size updates.
/// - Integration with snapping behaviors for smooth transitions between states.
class MultiStateSheetController<StateType> extends ScrollController {
  /// Multiplier that adjusts the duration of animations.
  ///
  /// - A value > 1.0 speeds up animations.
  /// - A value < 1.0 slows down animations.
  final double durationMultiplier;

  /// Adjusts the force applied to velocity in snapping position calculations.
  ///
  /// - A value greater than `1.0` makes the sheet more anchored to the next position.
  /// - A value less than `1.0` makes the sheet less anchored to the next position
  /// and more anchored to the previous position.
  final double forceMultiplier;

  /// The animation curve used to animate the sheet.
  ///
  /// This curve defines the rate of change of the animation over time.
  final Curve mainCurve;

  /// The curve used for the initial opening animation of the sheet.
  ///
  /// This curve defines the animation's progression from the start to the end
  /// of the initial opening of the sheet.
  final Curve initialOpenCurve;

  /// Stores the current state and behavior parameters of the sheet.
  late final MultiStateSheetExtent<StateType> _extent;

  /// Constructs a `MultiStateSheetController` with the specified snapping behavior and state mapper.
  ///
  /// - [behavior]: Defines the snapping behavior for the sheet.
  /// - [stateMapper]: Maps states to their indices and vice versa.
  /// - [initialState]: The initial state to which the sheet will snap on opening.
  /// - [durationMultiplier]: Adjusts the duration of animations `default is 1.0`.
  /// - [mainCurve]: The animation curve used to animate sheet's transition.
  /// - [initialOpenCurve]: The animation curve used to animate the initial opening animation of the sheet.
  /// - [resetContentScrollOnHiddenState]: If `true`, resets scroll position when the sheet is hidden.
  MultiStateSheetController({
    required SnappingBehavior behavior,
    required SheetStateMapper<StateType> stateMapper,

    /// The initial state that will be used to animate the sheet state when it opens.
    StateType? initialState,

    /// Changes the time that in animations will be executed. 1.0 is the default multiplier
    /// Change it to > 1.0 for speeding up the animation and < 1.0 for slowing it down.
    this.durationMultiplier = 1.0,

    /// Adjusts the force applied to velocity in snapping position calculations.
    ///
    /// - A value greater than `1.0` makes the sheet more anchored to the next position.
    /// - A value less than `1.0` makes the sheet less anchored to the next position
    ///  and more anchored to the previous position.
    this.forceMultiplier = 1.25,

    /// The animation curve used for the sheet's transition.
    ///
    /// Defaults to [Curves.decelerate].
    this.mainCurve = Curves.decelerate,

    /// The curve used for the initial opening animation of the sheet.
    ///
    /// Defaults to [Curves.easeOutExpo].
    this.initialOpenCurve = Curves.easeOutExpo,

    /// Defines if the content scroll should reset then sheet state is hidden.
    bool resetContentScrollOnHiddenState = false,
  }) {
    _extent = MultiStateSheetExtent(
        behavior: behavior,
        stateMapper: stateMapper,
        initialState: initialState != null ? stateMapper.index(initialState) : 0,
        availablePixels: kStartOfTheViewport,
        durationMultiplier: durationMultiplier,
        onOffsetChanged: _notifyHeightChanged,
        onStateChanged: resetContentScrollOnHiddenState ? _resetScrollPosition : null,
        forceMultiplier: forceMultiplier);
  }

  // --------------------------------------------------------------------------------------
  //                            Public Properties and Methods
  // --------------------------------------------------------------------------------------

  /// Gets the current state of the sheet on which is [interpolation] value relied on
  /// and at which it takes the starting point.
  ///
  /// Returns the closest anchored state if the sheet is enabled, otherwise the initial state.
  StateType get state {
    if (!isEnabled && !_extent.isAnimatingOpen) {
      return _extent.stateMapper.state(_extent.initialState);
    }

    return _extent.stateMapper.state(_extent.anchoredState);
  }

  /// Gets the closest state based on the current offset.
  ///
  /// It's not snapped to the actual state position of the viewport,
  /// rather, it changes based on the scroll height when it enters the region of the closest state to anchor.
  StateType get closestState => _extent.stateMapper.state(_extent.currentState);

  /// Gets the height of occupied space by the sheet based on its current offset.
  double get sheetHeight {
    final clipper = _extent.behavior.clipByHeader ? _extent.componentSizes.header : 0.0;
    final maxOffset = _extent.availablePixels - clipper;
    final offsetFromTop = _extent.isAnimatingOpen
        ? _extent.offset
        : _extent.minOffset >= maxOffset
            ? _extent.offset
            : clampDouble(_extent.offset, _extent.minOffset, maxOffset);

    return _extent.isEnabled ? _extent.availablePixels - offsetFromTop : 0.0;
  }

  /// Returns the offset from the top of the screen to the top of the sheet.
  ///
  /// This value is calculated at the layout stage and represents the actual offset within cliping bounds.
  double get actualSheetOffset => _actualOffset;

  /// Returns the viewport height available to the sheet.
  double get viewportHeight => _extent.availablePixels;

  /// Fraction of the height of sheet to the size of the viewport.
  double get fraction => sheetHeight / viewportHeight;

  /// Interpolation value between states.
  ///
  /// A value of `0.0` indicates the start of the current state,
  /// while `1.0` indicates the end of the state.
  double get interpolation => _extent.stateInterpolation;

  /// Returns `true` if the sheet is open and enabled.
  bool get isEnabled => _extent.isEnabled;

  /// Returns `true` if the sheet is currently animating to the open state.
  ///
  /// This getter determine if the sheet is in the process of opening with an animation.
  bool get isAnimatingOpen => _extent.isAnimatingOpen;

  /// Returns `true` if the snapping behavior requires reinitialization.
  bool get needsSetupBehavior => _extent.behavior.needsSetup;

  /// Returns `true` if the sheet is currently being dragged.
  bool get isDragging => _isDragging;

  /// Returns model that represent a sheet component sizes.
  SheetWidgetSizes get componentSizes => _extent.componentSizes;

  /// Returns model that represent a sheet component sizes at the initial state.
  SheetWidgetSizes get initialComponentSizes => _extent.initialComponentSizes;

  @override
  _MultiStateSheetScrollPosition<StateType> get position => super.position as _MultiStateSheetScrollPosition<StateType>;

  /// Resets controller for reuse with a new [MultiStateSheet]
  void reset() {
    if (_extent.isEnabled) {
      _heightAnimationController?.reset();
      _extent
        .._offset = 0.0
        ..isEnabled = false
        ..availablePixels = 0.0
        ..isAnimatingOpen = false
        ..initialComponentSizes = const SheetWidgetSizes.zero()
        ..componentSizes = const SheetWidgetSizes.zero()
        ..behavior.reset();
      notifyListeners();
    }
  }

  /// Sets up the snapping offsets based on current state of the controller's extent.
  void setupSnappingOffsets() => _extent.behavior.setup(_extent);

  /// Animates the sheet to the specified state.
  ///
  /// - [newState]: The target state to animate to.
  /// - [duration]: Custom duration for the animation (optional).
  /// - [curve]: Custom curve for the animation (optional).
  ///
  /// Default duration is calculated base on the distance between current and new state.
  void setState(StateType newState, {Duration? duration, Curve? curve}) {
    final stateIndex = _extent.stateMapper.index(newState);
    final newPosition = _extent.behavior.statePosition(extent: _extent, state: stateIndex);
    final distanceDuration =
        duration?.inMilliseconds ?? math.max((_extent.offset - newPosition).abs().round(), 150).toInt();

    _startAnimation(_extent.offset, newPosition, curve ?? mainCurve, distanceDuration);
  }

  @override
  void attach(ScrollPosition position) {
    if (position.hasPixels &&
        position is _MultiStateSheetScrollPosition &&
        position._extent.availablePixels > 0 &&
        position._extent.offset > 0) {
      _extent.isEnabled = true;
    }
    super.attach(position);
  }

  /// Animates the sheet to its initial state.
  void open() => _animateOpen(true);

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics, ScrollContext context, ScrollPosition? oldPosition) =>
      _MultiStateSheetScrollPosition(
        physics: physics,
        context: context,
        oldPosition: oldPosition,
        getExtent: () => _extent,
      );

  @override
  void detach(ScrollPosition position) {
    _extent.isEnabled = false;
    super.detach(position);
  }

  @override
  void dispose() {
    _heightAnimationController?.stop();
    _heightAnimationController?.removeListener(_onHeightChanged);
    _heightAnimationController?.dispose();
    _heightAnimationController = null;
    super.dispose();
  }

  // --------------------------------------------------------------------------------------
  //                            Private Fields and Methods
  // --------------------------------------------------------------------------------------

  double _lastPosition = 0.0;
  double _appliedDelta = 0.0;

  double _actualOffset = 0.0;
  bool _isDragging = false;

  /// Tracks whether the layout needs to be updated.
  ///
  /// 'true' if controller has already notified listeners about height change at this frame.
  /// And only needs to notify external listeners for the component's height change.
  ///
  /// Resets inside [_RenderMultiStateSheet.onSheetOffsetChanges] method.
  bool get _doNotMarkNeedsLayout => _extent._doNotMarkNeedsLayout;
  set _doNotMarkNeedsLayout(bool value) => _extent._doNotMarkNeedsLayout = value;

  /// Animation controller for managing height transitions.
  AnimationController? _heightAnimationController;
  double get _heightAnimationPosition => _heightAnimationController!.value;

  set _maxHeight(double value) {
    if (_extent.availablePixels != value) {
      _extent.availablePixels = value;

      if (!initialComponentSizes.isZero) {
        _extent.behavior.setup(_extent);
      }

      if (!isEnabled) {
        return;
      }

      /// Checks if the sheet is currently animating to the open state.
      /// If it is, calculates the new position based on the current extent and initial state,
      /// and determines the duration for the animation.
      ///
      /// Starts the animation from the current offset to the new position.
      if (_extent.isAnimatingOpen && !_isDragging) {
        final newPosition = _extent.behavior.statePosition(extent: _extent, state: _extent.initialState);
        final duration = (_extent.offset - newPosition).abs().round();

        _startAnimation(_extent.offset, newPosition, mainCurve, duration);
      }

      /// Updates the snap offset to the closest state and
      /// notifies listeners of the height change.
      else if (!_isDragging) {
        final newSnapPosition = _extent.behavior.statePosition(
          extent: _extent,
          state: _extent.stateMapper.index(closestState),
        );
        _extent
          .._offset = newSnapPosition
          ..updateState();
        _heightAnimationController?.stop();
        Future(_notifyHeightChanged);
      }
    }
  }

  /// Calculates the initial position of the sheet and sets its enabled state.
  ///
  /// This method is internally used by render object to set the initial position of the sheet.
  double _calculateInitialPositionAndSetEnabled() {
    final newPosition = _extent.behavior.statePosition(extent: _extent, state: _extent.initialState);

    _extent
      ..isEnabled = true
      ..isPreformingResize = false
      ..updateSize(newPosition, notify: false);

    return newPosition;
  }

  /// Resets the scroll position when the sheet is hidden.
  void _resetScrollPosition() {
    if (_extent.currentState == 0) {
      jumpTo(0);
    }
  }

  /// Updates the component sizes of the sheet.
  ///
  /// - [topHeaderHeight]: Height of the top header.
  /// - [headerHeight]: Height of the header.
  /// - [contentHeight]: Height of the content.
  /// - [footerHeight]: Height of the footer.
  double? _updateComponents({
    required double topHeaderHeight,
    required double headerHeight,
    required double contentHeight,
    required double footerHeight,
  }) {
    /// Notify listeners if the size of the top header is changed without sheet height update.
    ///
    /// This could happen when the the top header widget change its size on its own.
    if (topHeaderHeight != _extent.componentSizes.topHeader) {
      Future(() {
        if (isEnabled) {
          _doNotMarkNeedsLayout = true;
          notifyListeners();
        }
      });
    }

    return _extent.updateComponents(
      topHeaderHeight,
      headerHeight,
      contentHeight,
      footerHeight,
    );
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

    if (_actualOffset != _extent.offset) {
      _extent._offset -= _extent.offset - _actualOffset;
    }

    _lastPosition = details.localPosition.dy;
    _appliedDelta = 0.0;
  }

  /// Method to update offset of the sheet then user is dragging by holding a header component.
  void _dragUpdate(DragUpdateDetails details, BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (positions.isNotEmpty) {
        ScrollUpdateNotification(
          context: context,
          metrics: position,
          dragDetails: details,
        ).dispatch(context);
      }
    });
    _isDragging = true;

    if (details.localPosition.dy > 0.0) {
      final delta = (details.localPosition.dy - _lastPosition) - _appliedDelta;
      _appliedDelta = _appliedDelta + delta;

      /// Check for scrolling direction based on the delta from start to current drag position
      /// that it is can be dragged to the same direction as the current applied delta.
      final isScrollingDown = delta > 0 && _appliedDelta >= 0;
      final isScrollingUp = delta < 0 && _appliedDelta <= 0;

      final isOpen = _extent.offset == _extent.minOffset;
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

    _isDragging = false;
    _extent.isAnimatingOpen = false;

    final Simulation simulation = switch (_extent.behavior.shouldSnap) {
      true => SnappingSimulation(
          position: _extent.offset,
          initialVelocity: details.velocity.pixelsPerSecond.dy / kVelocityCorrectionFactor,
          durationMultiplier: _extent.durationMultiplier,
          pixelSnapPositions: _extent.behavior.snappingPixelOffsetsClamped,
          snapAnimationDuration: _extent.snapAnimationDuration ?? kDefaultSheetScrollDuration,
          tolerance: position.physics.toleranceFor(position),
          forceMultiplier: _extent.forceMultiplier,
        ),
      _ => ClampingScrollSimulation(
          position: _extent.offset,
          velocity: details.velocity.pixelsPerSecond.dy,
          tolerance: position.physics.toleranceFor(position),
        )
    };

    position._stopBallisticAnimation();

    _heightAnimationController?.stop();
    _heightAnimationController?.value = _extent.offset;
    _heightAnimationController?.animateWith(simulation).whenComplete(() {
      _extent.isAnimatingOpen = false;
    });
  }

  /// Initializes the height animation controller.
  void _initAnimation(TickerProvider vsync) {
    _heightAnimationController = AnimationController.unbounded(vsync: vsync);
    _heightAnimationController?.addListener(_onHeightChanged);
  }

  /// Method used to animating sheet from not visable state to initial state position.
  void _animateOpen(bool animate) {
    final newPosition = _extent.behavior.statePosition(extent: _extent, state: _extent.initialState);
    _extent
      ..isEnabled = true
      .._offset = _extent.availablePixels;

    if (!animate) {
      _extent
        ..isAnimatingOpen = false
        ..updateSize(newPosition, isAnimating: _extent.isAnimatingOpen);
      return;
    }

    final duration = math.max(kDefaultSheetScrollDuration.inMilliseconds, (_extent.offset - newPosition).abs().round());
    _extent.isAnimatingOpen = true;

    _startAnimation(_extent.offset, newPosition, initialOpenCurve, duration);
  }

  /// Starts an animation to transition the sheet to a new position.
  void _startAnimation(double startPosition, double position, Curve curve, int duration) {
    this.position._stopBallisticAnimation();

    _heightAnimationController?.stop();
    _heightAnimationController?.value = startPosition;
    _heightAnimationController
        ?.animateTo(
      position,
      curve: curve,
      duration: Duration(milliseconds: (duration * durationMultiplier).toInt()),
    )
        .whenComplete(() {
      _extent.isAnimatingOpen = false;
    });
  }

  /// Notifies listeners when the height changes.
  void _onHeightChanged() {
    final velocity = _heightAnimationController?.velocity ?? 0.0;

    if (_extent.offset != _heightAnimationPosition && _heightAnimationPosition.isFinite) {
      _extent.updateSize(_heightAnimationPosition, isAnimating: _extent.isAnimatingOpen);
    }

    /// Stops the animation if we trying to animate outside of the max safe offset
    if (velocity >= 0.0 &&
        (_extent.safeMaxOffset < _heightAnimationPosition && _extent.offset <= _extent.safeMaxOffset ||
            state == 0 && interpolation == 0.0)) {
      _heightAnimationController?.stop(canceled: false);
    }
  }

  /// Notifies listeners when the height changes.
  void _notifyHeightChanged() {
    if (_extent.isEnabled && !_extent.isPreformingResize) {
      notifyListeners();
    }
  }
}

class _MultiStateSheetScrollPosition<StateType> extends ScrollPositionWithSingleContext {
  final MultiStateSheetExtent<StateType> Function() getExtent;
  final Set<AnimationController> _ballisticControllers = <AnimationController>{};
  late final MultiStateSheetExtent<StateType> _extent = getExtent();

  VoidCallback? _dragCancelCallback;

  _MultiStateSheetScrollPosition({
    required super.physics,
    required super.context,
    required this.getExtent,
    super.oldPosition,
  });

  bool get listShouldScroll => pixels > 0.0;

  bool get isAtSnapSize => _extent.behavior.isAtSnapOffset(
        extent: _extent,
        toleranceDistance: physics.toleranceFor(this).distance,
      );

  bool get shouldSnap => _extent.behavior.shouldSnap && !isAtSnapSize;

  @override
  void absorb(ScrollPosition other) {
    super.absorb(other);

    if (other is! _MultiStateSheetScrollPosition) {
      return;
    }

    if (other._dragCancelCallback != null) {
      _dragCancelCallback = other._dragCancelCallback;
      other._dragCancelCallback = null;
    }
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
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
      _extent.addPixelDelta(delta);
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
    final isDraggedByHeader = velocity == 0.0 && !shouldSnap && !_extent.isAtMax;
    final isShouldScrollContentDown = velocity > 0.0 && _extent.isAtMax && listShouldScroll;
    final isShouldScrollContentUp = velocity < 0.0 && !(_extent.isAtMin && _extent.isAtMax) && listShouldScroll;
    if (isDraggedByHeader || isShouldScrollContentDown || isShouldScrollContentUp || !isScrollingNotifier.value) {
      super.goBallistic(velocity);
      return;
    }
    _dragCancelCallback?.call();
    _dragCancelCallback = null;

    final Simulation simulation = switch (_extent.behavior.shouldSnap) {
      true => SnappingSimulation(
          position: _extent.offset,
          initialVelocity: -velocity / kVelocityCorrectionFactor,
          durationMultiplier: _extent.durationMultiplier,
          pixelSnapPositions: _extent.behavior.snappingPixelOffsets,
          snapAnimationDuration: _extent.snapAnimationDuration ?? kDefaultSheetScrollDuration,
          tolerance: physics.toleranceFor(this),
          forceMultiplier: _extent.forceMultiplier,
        ),
      _ => ClampingScrollSimulation(
          position: _extent.offset,
          velocity: -velocity,
          tolerance: physics.toleranceFor(this),
        )
    };

    final AnimationController ballisticController = AnimationController.unbounded(
      debugLabel: objectRuntimeType(this, '_MultiStateSheetScrollPosition'),
      vsync: context.vsync,
    );

    _ballisticControllers.add(ballisticController);

    void tick() {
      _extent.updateSize(ballisticController.value);
      if ((velocity > 0 && _extent.isAtMax) || (velocity < 0 && _extent.isAtMin)) {
        final physicsVelocity = ballisticController.velocity + (physics.toleranceFor(this).velocity);
        super.goBallistic(-physicsVelocity);
        ballisticController.stop();
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
      ballisticController.stop();
    }
  }
}
