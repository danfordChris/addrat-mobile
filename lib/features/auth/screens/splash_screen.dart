import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/extensions/build_context_extensions.dart';
import 'package:pesa_lending/core/resources/logo.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/features/auth/providers/auth_provider.dart';
import 'package:pesa_lending/features/onboarding/providers/preferences_provider.dart';
import 'package:pesa_lending/shared/widgets/loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final auth = context.stateRead<AuthProvider>();
    final prefs = context.stateRead<PreferencesProvider>();

    await Future.wait([
      auth.checkAuth(),
      prefs.load(),
    ]);

    if (!mounted) return;
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    if (auth.isAuthenticated) {
      context.go(AppRoute.home.path);
    } else if (!prefs.hasSeenOnboarding) {
      context.go(AppRoute.onboardingLanguage.path);
    } else {
      context.go(AppRoute.onboardingLanguage.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: context.width * 0.5,
              height: context.width * 0.5,
              child: Image.asset(Logo.appLogo),
            ).animate().scale(duration: 1200.ms, curve: Curves.easeOut),
            // RichText(
            //   text: TextSpan(
            //     children: [
            //       TextSpan(
            //         text: 'ADDRAT',
            //         style: context.bodyLarge.extraBold.copyWith(
            //           color: cs.primary,
            //         ),
            //       ),
            //       TextSpan(
            //         text: '\nMicrofinance',
            //         style: context.bodyLarge.extraBold
            //             .copyWith(
            //               color: cs.error,
            //             )
            //             .semiBold,
            //       ),
            //     ],
            //   ),
            // ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            // const SizedBox(height: 8),
            LoadingIndicator().animate().fadeIn(delay: 500.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
