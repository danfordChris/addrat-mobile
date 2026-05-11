import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Stack(
      children: [
        child,
        if (isLoading)
          ColoredBox(
            color: cs.scrim.withValues(alpha: 0.53),
            child: Center(
              child: CircularProgressIndicator(
                color: cs.primary,
                strokeWidth: 3,
              ),
            ),
          ),
      ],
    );
  }
}
