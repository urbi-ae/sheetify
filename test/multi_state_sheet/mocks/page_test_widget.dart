import 'package:flutter/material.dart';

class PageTestWidget extends StatefulWidget {
  final Widget child;
  final double sheetHeight;

  const PageTestWidget({
    required this.child,
    this.sheetHeight = 900,
    super.key,
  });

  @override
  State<PageTestWidget> createState() => _PageTestWidgetState();
}

class _PageTestWidgetState extends State<PageTestWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.sheetHeight,
      width: 400,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget.child,
      ),
    );
  }
}
