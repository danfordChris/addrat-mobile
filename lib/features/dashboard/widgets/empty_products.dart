import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

class EmptyProducts extends StatelessWidget {
  const EmptyProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: HugeIcons.strokeRoundedWallet01, color: cs.primary, size: 38),
          ),
          const SizedBox(height: 16),
          Text('Hakuna Bidhaa', style: context.titleSmall.copyWith(color: cs.onSurface)),
          const SizedBox(height: 6),
          Text(
            'Bidhaa za mkopo hazipo kwa sasa. Jaribu baadaye.',
            style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
