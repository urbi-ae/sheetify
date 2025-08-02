// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:example/demos/dynamic_padding_toggle_sheet_demo.dart' as _i1;
import 'package:example/demos/multi_state_sheet_demo.dart' as _i3;
import 'package:example/demos/toggle_sheet_demo.dart' as _i4;
import 'package:example/menu_page.dart' as _i2;

/// generated route for
/// [_i1.DynamicPaddingToggleSheetDemo]
class DynamicPaddingToggleSheetDemo extends _i5.PageRouteInfo<void> {
  const DynamicPaddingToggleSheetDemo({List<_i5.PageRouteInfo>? children})
      : super(DynamicPaddingToggleSheetDemo.name, initialChildren: children);

  static const String name = 'DynamicPaddingToggleSheetDemo';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.DynamicPaddingToggleSheetDemo();
    },
  );
}

/// generated route for
/// [_i2.MenuPage]
class MenuRoute extends _i5.PageRouteInfo<void> {
  const MenuRoute({List<_i5.PageRouteInfo>? children})
      : super(MenuRoute.name, initialChildren: children);

  static const String name = 'MenuRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.MenuPage();
    },
  );
}

/// generated route for
/// [_i3.MultiStateSheetDemo]
class MultiStateSheetDemo extends _i5.PageRouteInfo<void> {
  const MultiStateSheetDemo({List<_i5.PageRouteInfo>? children})
      : super(MultiStateSheetDemo.name, initialChildren: children);

  static const String name = 'MultiStateSheetDemo';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.MultiStateSheetDemo();
    },
  );
}

/// generated route for
/// [_i4.ToggleSheetDemo]
class ToggleSheetDemo extends _i5.PageRouteInfo<void> {
  const ToggleSheetDemo({List<_i5.PageRouteInfo>? children})
      : super(ToggleSheetDemo.name, initialChildren: children);

  static const String name = 'ToggleSheetDemo';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.ToggleSheetDemo();
    },
  );
}
