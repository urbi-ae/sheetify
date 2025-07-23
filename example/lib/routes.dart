import 'package:example/demos/dynamic_padding_toggle_sheet_demo.dart';
import 'package:example/demos/multi_state_sheet_demo.dart';
import 'package:example/demos/toggle_sheet_demo.dart';
import 'package:example/menu_page.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String initialRoute = '/';
  static const String multiStateBottomSheetDemo = '/multi_state';
  static const String toggleBottomSheetDemo = '/toggle';
  static const String dynamicPaddingToggleSheetDemo = '/dynamic_padding';

  static Map<String, WidgetBuilder> routes = {
    initialRoute: (context) => const MenuPage(),
    multiStateBottomSheetDemo: (_) => const MultiStateSheetDemo(),
    toggleBottomSheetDemo: (_) => const ToggleSheetDemo(),
    dynamicPaddingToggleSheetDemo: (_) => const DynamicPaddingToggleSheetDemo(),
  };

  static Map<String, String> routeNames = {
    multiStateBottomSheetDemo: 'Multi State Sheet Demo',
    toggleBottomSheetDemo: 'Toggle Sheet Demo',
    dynamicPaddingToggleSheetDemo: 'Dynamic Padding Toggle Sheet Demo',
  };
}
