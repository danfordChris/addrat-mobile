import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.backgroundColor,
  });

  final String initials;
  final double size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: backgroundColor != null
            ? null
            : LinearGradient(
                colors: [cs.primary, cs.primary.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: backgroundColor,
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: context.labelLarge.bold.copyWith(
            color: cs.onPrimary,
            fontSize: size * 0.36,
          ),
        ),
      ),
    );
  }
}
