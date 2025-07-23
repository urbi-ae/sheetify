import 'package:auto_route/auto_route.dart';
import 'package:example/routes.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: MenuRoute.page, initial: true),
        AutoRoute(page: MultiStateSheetDemo.page),
        AutoRoute(page: ToggleSheetDemo.page),
        AutoRoute(page: DynamicPaddingToggleSheetDemo.page),
      ];

  static const String initialRoute = '/';
  static const String multiStateBottomSheetDemo = '/multi_state';
  static const String toggleBottomSheetDemo = '/toggle';
  static const String dynamicPaddingToggleSheetDemo = '/dynamic_padding';

  static Map<String, PageRouteInfo<void>> pages = {
    multiStateBottomSheetDemo: MultiStateSheetDemo(),
    toggleBottomSheetDemo: ToggleSheetDemo(),
    dynamicPaddingToggleSheetDemo: DynamicPaddingToggleSheetDemo(),
  };

  static Map<String, String> pagesNames = {
    multiStateBottomSheetDemo: 'Multi State Sheet Demo',
    toggleBottomSheetDemo: 'Toggle Sheet Demo',
    dynamicPaddingToggleSheetDemo: 'Dynamic Padding Toggle Sheet Demo',
  };
}
