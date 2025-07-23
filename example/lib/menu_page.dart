import 'package:auto_route/auto_route.dart';
import 'package:example/routes.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Main menu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: AppRouter.pagesNames.entries
              .map(
                (routeName) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final page = AppRouter.pages[routeName.key];
                      if (page != null) {
                        context.router.push(page);
                      }
                    },
                    child: Text(routeName.value),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
