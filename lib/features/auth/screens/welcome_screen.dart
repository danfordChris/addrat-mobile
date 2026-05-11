import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/resources/images.dart';
import 'package:pesa_lending/core/resources/logo.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/features/auth/widgets/feature_pill.dart';
import 'package:pesa_lending/shared/components/buttons/app_primary_button.dart';

import '../../../core/router/router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Images.onboardingImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: cs.primary.withValues(alpha: 0.15),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.15),
                                Colors.black.withValues(alpha: 0.35),
                                Colors.black.withValues(alpha: 0.75),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Row(children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Center(
                                  child: Image.asset(Logo.appLogo),
                                ),
                              ),
                              const SizedBox(width: 12),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'ADDRAT',
                                      style: context.bodyLarge.extraBold.copyWith(
                                        color: cs.surface,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '\nMicrofinance',
                                      style: context.bodyLarge.extraBold
                                          .copyWith(
                                            color: cs.error,
                                          )
                                          .semiBold,
                                    ),
                                  ],
                                ),
                              )
                            ]),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mkopo wako\nharaka iwezekanavyo.',
                                  style: context.headlineLarge.extraBold.copyWith(color: Colors.white, height: 1.15, letterSpacing: -0.5),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Omba mkopo ndani ya dakika 5.\nBila ofisi, bila msongo.',
                                  style: context.bodyLarge.copyWith(color: Colors.white.withValues(alpha: 0.72), height: 1.55),
                                ),
                                const SizedBox(height: 32),
                                const Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    FeaturePill(icon: Icons.flash_on_rounded, label: 'Haraka'),
                                    FeaturePill(icon: Icons.shield_rounded, label: 'Salama'),
                                    FeaturePill(icon: Icons.phone_iphone_rounded, label: 'Rahisi'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(AppRadius.lg),
                                topRight: Radius.circular(AppRadius.lg),
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                            child: SafeArea(
                              top: false,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AppPrimaryButton(
                                    label: 'Anza Sasa',
                                    onPressed: () => context.push(AppRoute.authPhone.path),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: () => context.push(AppRoute.authPhone.path),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 48),
                                    ),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Nina akaunti tayari? ',
                                            style: context.bodyMedium.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Ingia',
                                            style: context.bodyMedium.bold.copyWith(
                                              color: cs.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
