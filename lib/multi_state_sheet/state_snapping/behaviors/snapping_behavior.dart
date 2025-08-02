part of 'package:sheetify/multi_state_sheet/multi_state_sheet.dart';

/// Defines the snapping behavior for a sheet during scrolling and dragging.
///
/// The snapping behavior determines how the sheet transitions between
/// different states based on user interactions and animations. It provides
/// snapping offsets, state calculations, and interpolation between states.
abstract base class SnappingBehavior {
  /// Determines whether the header should clip max offset of the sheet.
  ///
  /// When set to `true`, max offset should be clipped by the header height to always show header.
  ///
  /// When set to `false`, max offset will be set to available viewport height,
  /// potentially make a header to disappear if it not clipped by the provided offset from model.
  final bool clipByHeader;

  /// Caches the closest offsets to optimize repeated calculations for a single frame.
  final FrameStackHashMap<double, (double, double)> cachedClosestOffsets =
      FrameStackHashMap();

  /// Caches the state associated with a specific offset for optimized state retrieval.
  final FrameStackHashMap<double, int> cachedState = FrameStackHashMap();

  /// Caches the mapping of offsets to their corresponding states.
  final HashMap<double, int> cachedStateFromOffset = HashMap();

  /// Stores the snapping offsets of the sheet in pixels.
  ///
  /// These offsets represent predefined positions to which the sheet can snap.
  SplayTreeSet<double>? snappingOffsets;

  /// Available height for the sheet to occupy, in pixels.
  double _avaliableSpace = 0;

  /// Flag to determine if the sheet has valid sizes set.
  bool _hasSizes = false;

  /// The height of the header that is used to shift the max offset.
  double headerShiftHeight = 0.0;

  /// The minimum height offset of the sheet from the top boundary.
  double minOffset = 0.0;

  /// The maximum height offset of the sheet and padding from the top boundary.
  double maxOffset = 0.0;

  /// Gets the last maximum height offset of the sheet and padding from the top boundary.
  double lastMaxOffset = 0.0;

  /// Base constructor for a [SnappingBehavior] class.
  ///
  /// The [clipByHeader] parameter determines whether the max offset should be clipped by the header.
  ///
  /// * [clipByHeader]: If true, should clip max offset to always show header. Defaults to true.
  SnappingBehavior({this.clipByHeader = true});

  //--------------------------------------------------------------------------------------//
  //                             Properties and Accessors                                 //
  //--------------------------------------------------------------------------------------//

  /// Sets the available height for the sheet and updates the size flag.
  ///
  /// - [value]: The available height in pixels. Must be greater than `0`.
  set avaliableSpace(double value) {
    if (value > 0) {
      _avaliableSpace = value;
      _hasSizes = true;
    }
  }

  /// Gets the available height for the sheet in pixels.
  double get avaliableSpace => _avaliableSpace;

  /// Indicates if the sheet has been initialized with valid sizes.
  bool get hasSizes => _hasSizes;

  /// Indicates if the snapping behavior requires setup or reinitialization.
  ///
  /// This is `true` when snapping offsets are not defined, empty, or sizes are missing.
  bool get needsSetup =>
      snappingOffsets == null ||
      (snappingOffsets?.isEmpty ?? true) ||
      !hasSizes;

  /// Gets the snapping offsets as a list of pixel values.
  ///
  /// This is used in ballistic simulations to determine snapping positions.
  List<double> get snappingPixelOffsets =>
      snappingOffsets?.map((o) {
        if (o > safeMaxOffset) {
          return safeMaxOffset;
        }

        return o;
      }).toList() ??
      [];

  List<double> get snappingPixelOffsetsClamped =>
      snappingOffsets?.map((o) {
        if (o > safeMaxOffset) {
          return safeMaxOffset;
        }

        return o;
      }).toList() ??
      [];

  double get safeMaxOffset => isMaxOffsetFinalized ? maxOffset : avaliableSpace;

  /// Checks if the maximum offset has been finalized.
  ///
  /// Returns `true` if the `lastMaxOffset` is equal to the `maxOffset`,
  /// indicating that the maximum offset has been set and is not subject to change.
  bool get isMaxOffsetFinalized => lastMaxOffset == maxOffset;

  //--------------------------------------------------------------------------------------//
  //                        Overridable Properties and Methods                            //
  //--------------------------------------------------------------------------------------//

  /// Determines if the sheet should snap to the snapping positions.
  ///
  /// Defaults to `true`. Override this to disable snapping behavior.
  bool get shouldSnap => true;

  /// Sets up the snapping behavior for the sheet.
  ///
  /// This method is responsible for configuring the snapping points for the
  /// sheet based on the provided [extent]. The snapping points are
  /// returned as a [SplayTreeSet] of doubles, which represent the positions
  /// where the sheet can snap to.
  ///
  /// The generic type [T] represents the type of the extent.
  ///
  /// Returns a [SplayTreeSet] of doubles representing the snapping points,
  /// or `null` if the setup could not be performed.
  ///
  /// - Parameter extent: The extent of the sheet, which determines
  ///   the snapping points.
  SplayTreeSet<double>? performSetup<T>(MultiStateSheetExtent<T> extent);

  /// Resets the cached values and state of the snapping behavior.
  ///
  /// This method is called when the sheet is disposed or reinitialized.
  @mustCallSuper
  void reset() {
    cachedClosestOffsets.clear();
    cachedState.clear();
    cachedStateFromOffset.clear();
    _avaliableSpace = 0;
    _hasSizes = false;
    snappingOffsets = null;
  }

  //--------------------------------------------------------------------------------------//
  //                        Default Behavior and Calculations                             //
  //--------------------------------------------------------------------------------------//

  /// Configures the snapping behavior using the provided extent.
  ///
  /// - [extent]: The current state and configuration of the sheet.
  ///
  /// Subclasses should not override [setup] directly. Instead, they should
  /// override [performSetup] method.
  ///
  /// Clears cached values to ensure consistent calculations.
  @mustCallSuper
  void setup<T>(MultiStateSheetExtent<T> extent) {
    cachedClosestOffsets.clear();
    cachedState.clear();
    cachedStateFromOffset.clear();

    headerShiftHeight = clipByHeader &&
            (extent.currentState == 0 && extent.stateInterpolation == 0.0)
        ? extent.componentSizes.header
        : 0.0;

    // Set the available space for the sheet.
    avaliableSpace = extent.availablePixels;
    final clippedMaxOffset = avaliableSpace - headerShiftHeight;

    // Initialize minimum and maximum offsets.
    minOffset = 0.0;
    maxOffset = clippedMaxOffset;

    // Combine snapping offsets from all models.
    snappingOffsets = performSetup(extent);

    // Update minimum and maximum offsets based on the calculated snapping offsets.
    minOffset = snappingPixelOffsets.firstOrNull ?? 0.0;

    maxOffset = math.min(
        clippedMaxOffset, snappingPixelOffsets.lastOrNull ?? clippedMaxOffset);
  }

  /// Determines the anchored state for the current extent offset.
  ///
  /// - [extent]: The current extent of the sheet.
  /// - Returns: The index of the anchored state.
  int anchoredState<T>(MultiStateSheetExtent<T> extent) =>
      getStateFromOffset(getFirstOffsetAfter(extent.offset), extent);

  /// Calculates the interpolation value between two snapping states.
  ///
  /// - [extent]: The current extent of the sheet.
  /// - [offset]: The current offset of the sheet.
  /// - Returns: A value between `0` (start of the state) and `1` (end of the state).
  double getInterpolation<T>(
      {required MultiStateSheetExtent<T> extent, required double offset}) {
    final (firstOffset, lastOffset) = getClosestOffsets(offset, extent);

    return firstOffset != lastOffset
        ? lerpBetween(
            offset,
            0.0,
            1.0,
            firstOffset,
            lastOffset,
          )
        : 0.0;
  }

  /// Gets the state associated with the specified offset.
  ///
  /// - [extent]: The current extent of the sheet.
  /// - [offset]: The offset value to evaluate.
  /// - Returns: The state index corresponding to the offset.
  int getState<T>(
          {required MultiStateSheetExtent<T> extent, required double offset}) =>
      cachedState.putIfAbsent(extent.offset, offset, () {
        final (firstOffset, lastOffset) = getClosestOffsets(offset, extent);

        if ((offset - lastOffset).abs() >= (offset - firstOffset).abs()) {
          return getStateFromOffset(firstOffset, extent);
        }

        return getStateFromOffset(lastOffset, extent);
      });

  /// Checks if the current offset is at a snapping position.
  ///
  /// - [extent]: The current extent of the sheet.
  /// - [toleranceDistance]: The allowed tolerance for the offset to be considered at a snapping position.
  /// - Returns: `true` if the offset is close to a snapping position, `false` otherwise.
  bool isAtSnapOffset<T>({
    required MultiStateSheetExtent<T> extent,
    required double toleranceDistance,
  }) =>
      snappingPixelOffsets.any((snapOffset) =>
          (extent.offset - snapOffset).abs() <= toleranceDistance) ||
      extent.offset >= extent.maxOffset;

  /// Gets the snapping offset for the specified state.
  ///
  /// - [state]: The index of the state.
  /// - Returns: The offset in pixels corresponding to the state.
  double offsetFromState(int state) =>
      snappingPixelOffsets.elementAtOrNull(stateToIndex(state)) ?? 0.0;

  /// Converts a state index to an offset index.
  ///
  /// - [state]: The index of the state.
  /// - Returns: The corresponding index in the snapping offsets list.
  /// - Throws: AssertionError if the state index is out of range.
  int stateToIndex(int state) {
    assert(
      state >= 0 && state < snappingPixelOffsets.length ||
          snappingPixelOffsets.isEmpty,
      'Provided state index is out of range for snapping positions. '
      'Please ensure unique offsets and valid states.\n'
      'State index: $state, Snapping offsets length: ${snappingPixelOffsets.length}\n'
      'State offsets: $snappingPixelOffsets\n'
      'Min and max offsets: $minOffset : $maxOffset',
    );

    if (snappingPixelOffsets.isEmpty) {
      return 0;
    }

    return snappingPixelOffsets.length - 1 - state;
  }

  /// Gets the state index for a given offset.
  ///
  /// - [offset]: The offset value to evaluate.
  /// - Returns: The index of the state corresponding to the offset.
  int stateOfOffset(double offset) =>
      stateToIndex(snappingPixelOffsets.indexOf(getFirstOffsetAfter(offset)));

  /// Gets the clamped position of the sheet for a given state.
  ///
  /// - [extent]: The current extent of the sheet.
  /// - [state]: The state index to evaluate.
  /// - Returns: The position of the state clamped between `minOffset` and `maxOffset`.
  double statePosition<T>({
    required MultiStateSheetExtent<T> extent,
    required int state,
  }) =>
      clampDouble(
          offsetFromState(state), extent.minOffset, extent.safeMaxOffset);

  /// Finds the two closest snapping offsets to the given offset.
  ///
  /// - [offset]: The current offset of the sheet.
  /// - [extent]: The current extent of the sheet.
  /// - Returns: A record of the closest offsets before and after the given offset.
  (double first, double last) getClosestOffsets<StateType>(
    double offset,
    MultiStateSheetExtent<StateType> extent,
  ) =>
      cachedClosestOffsets.putIfAbsent(extent.offset, offset, () {
        final double firstOffset = getFirstOffsetAfter(offset);
        final double lastOffset = getLastOffsetBefore(offset);

        return (
          clampDouble(firstOffset, extent.minOffset, extent.maxOffset),
          clampDouble(lastOffset, extent.minOffset, extent.maxOffset),
        );
      });

  /// Finds the first snapping offset greater than or equal to the given offset.
  ///
  /// - [offset]: The current offset of the sheet.
  /// - Returns: The closest snapping offset above or equal to the given offset.
  double getFirstOffsetAfter<T>(double offset) =>
      snappingPixelOffsets.firstWhere(
        (snapOffset) => snapOffset.roundDecimal() >= offset.roundDecimal(),
        orElse: () => snappingPixelOffsets.lastOrNull ?? 0.0,
      );

  /// Finds the last snapping offset less than or equal to the given offset.
  ///
  /// - [offset]: The current offset of the sheet.
  /// - Returns: The closest snapping offset below or equal to the given offset.
  double getLastOffsetBefore<T>(double offset) =>
      snappingPixelOffsets.lastWhere(
        (snapOffset) => snapOffset.roundDecimal() <= offset.roundDecimal(),
        orElse: () => snappingPixelOffsets.firstOrNull ?? 0.0,
      );

  /// Maps the given offset to its corresponding state index.
  ///
  /// - [offset]: The current offset of the sheet.
  /// - [extent]: The current extent of the sheet.
  /// - Returns: The state index corresponding to the given offset.
  int getStateFromOffset<T>(double offset, MultiStateSheetExtent<T> extent) =>
      cachedStateFromOffset.putIfAbsent(offset, () {
        final stateIndex = stateOfOffset(offset);

        if (stateIndex == -1) {
          final minPosition = extent.minOffset;
          final maxPosition = extent.safeMaxOffset;

          final firstPosition = getFirstOffsetAfter(offset);
          final lastPosition = getLastOffsetBefore(offset);

          if ((offset - clampDouble(lastPosition, minPosition, maxPosition))
                  .abs() >
              (offset - clampDouble(firstPosition, minPosition, maxPosition))
                  .abs()) {
            return stateOfOffset(firstPosition);
          }
          return stateOfOffset(lastPosition);
        }
        return stateIndex;
      });
}
