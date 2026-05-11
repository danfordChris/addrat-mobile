import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D7A6B), Color(0xFF0A5C52)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: 90,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 50,
            bottom: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Text content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 130, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mikopo ya\nKuaminiwa.',
                  style: context.titleLarge.bold.copyWith(color: Colors.white, height: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  'Masharti Wazi',
                  style: context.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),

          // Icon illustration
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 120,
              decoration: const BoxDecoration(
                color: Color(0xFF063D36),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppRadius.xl),
                  bottomRight: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedMoney01,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 40,
                  ),
                  const SizedBox(height: 6),
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedCoins01,
                    color: Color(0xFF0D7A6B),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
