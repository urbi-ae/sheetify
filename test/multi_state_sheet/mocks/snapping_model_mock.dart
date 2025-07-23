import 'dart:collection';

import 'package:sheetify/sheetify.dart';

class MockSnappingModel extends SnappingModel {
  final SplayTreeSet<double> _mockOffsets;

  MockSnappingModel(this._mockOffsets);

  @override
  SplayTreeSet<double> getOffsets<T>(MultiStateSheetExtent<T> extent) => _mockOffsets;
}
