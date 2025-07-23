import 'package:flutter/material.dart';

class PlaceholderContainer extends StatelessWidget {
  final String? text;
  final Color? color;

  const PlaceholderContainer({super.key, this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
        ),
        child: Center(
          child: Text(text ?? ' '),
        ),
      ),
    );
  }
}
