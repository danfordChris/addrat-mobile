import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/shared/components/cards/app_card.dart';
import 'package:pesa_lending/shared/components/misc/app_divider.dart';

class ReviewSection extends StatefulWidget {
  const ReviewSection({
    required this.title,
    required this.icon,
    required this.onEdit,
    required this.tiles,
  });

  final String title;
  final IconData icon;
  final VoidCallback onEdit;
  final List<Widget> tiles;

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  HugeIcon(icon: widget.icon, color: context.colorScheme.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(widget.title, style: context.bodyMedium.copyWith(color: context.colorScheme.onSurface)),
                  ),
                  GestureDetector(
                    onTap: widget.onEdit,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      HugeIcon(icon: HugeIcons.strokeRoundedEdit01, color: context.colorScheme.primary, size: 14),
                      const SizedBox(width: 4),
                      Text('Hariri', style: context.bodySmall.copyWith(color: context.colorScheme.primary)),
                    ]),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  HugeIcon(
                    icon: _expanded ? HugeIcons.strokeRoundedArrowUp01 : HugeIcons.strokeRoundedArrowDown01,
                    color: context.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const AppDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Column(
                children: widget.tiles
                    .map((t) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          child: t,
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
