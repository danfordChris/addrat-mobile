import 'package:flutter/material.dart';

class ActivityWrapper extends StatelessWidget {
  final Widget child;

  const ActivityWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {},
      child: child,
    );
  }
}
