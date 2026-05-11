import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final int steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: List.generate(steps, (i) {
            final isDone = i < currentStep;
            final isCurrent = i == currentStep - 1;
            return Expanded(
              child: Row(
                children: [
                  _StepCircle(index: i, isDone: isDone, isCurrent: isCurrent),
                  if (i < steps - 1)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: 1.8,
                        color: isDone ? context.colorScheme.primary : context.colorScheme.outlineVariant,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.index,
    required this.isDone,
    required this.isCurrent,
  });

  final int index;
  final bool isDone;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    Widget circle = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone || isCurrent ? cs.primary : Colors.transparent,
        border: Border.all(
          color: isDone || isCurrent ? cs.primary : cs.outlineVariant,
          width: 2,
        ),
      ),
      child: Center(
        child: isDone
            ? Icon(Icons.check, color: cs.onPrimary, size: 14)
            : Text(
                '${index + 1}',
                style: context.labelSmall.semiBold.copyWith(
                  color: isCurrent ? cs.onPrimary : cs.onSurfaceVariant,
                ),
              ),
      ),
    );

    if (isCurrent) {
      circle = circle
          .animate(onPlay: (c) => c.repeat())
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.15, 1.15),
            duration: 800.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1.15, 1.15),
            end: const Offset(1, 1),
            duration: 800.ms,
          );
    }

    return circle;
  }
}
