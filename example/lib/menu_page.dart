import 'package:example/routes.dart';
import 'package:flutter/material.dart';

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
          children: Routes.routeNames.entries
              .map(
                (routeName) => ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, routeName.key);
                  },
                  child: Text(routeName.value),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
