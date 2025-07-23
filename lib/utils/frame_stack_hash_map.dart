import 'dart:collection';

/// A hashmap that is cleared every time [frame] is updated.
class FrameStackHashMap<K, V> {
  /// A hashmap that is cleared every time [frame] is updated.
  FrameStackHashMap();

  /// Unique ID of the current frame of the map entries.
  double? frame;

  /// Current state of entries for this [frame]
  HashMap<K, V> state = HashMap<K, V>();

  /// If frame doens't change, look up the value of [key],
  /// or add a new entry if it isn't there.
  /// In other way removes all entries from the map.
  ///
  /// Returns the value associated to [key], if there is one.
  /// Otherwise calls [ifAbsent] to get a new value,
  /// associates [key] to that value,
  /// and then returns the new value.
  V putIfAbsent(double frame, K key, V Function() ifAbsent) {
    if (this.frame != frame) {
      this.frame = frame;
      state.clear();
    }

    final putIfAbsent = state.putIfAbsent(key, ifAbsent);
    return putIfAbsent;
  }

  /// Removes all entries from the map.
  ///
  /// After this, the map is empty.
  void clear() {
    frame = null;
    state.clear();
  }
}
