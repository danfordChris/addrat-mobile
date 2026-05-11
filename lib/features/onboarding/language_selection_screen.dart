import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/features/onboarding/providers/preferences_provider.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/shared/shared.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends State<LanguageSelectionScreen> {
  String _selected = 'en';
  bool _loading = false;

  Future<void> _onContinue() async {
    setState(() => _loading = true);
    final preferencesProvider = context.stateRead<PreferencesProvider>();
    await preferencesProvider.setLanguage(_selected);
    await preferencesProvider.setHasSeenOnboarding(true);
    if (!mounted) return;
    context.go(AppRoute.authWelcome.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Choose Language',
                style: context.headlineLarge,
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Select your preferred language\nChagua lugha unayopendelea',
                style: context.bodyMedium.copyWith(color: context.colorScheme.outline)  ,
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.xl),
              LanguageCard(
                languageCode: 'en',
                languageName: 'English',
                nativeName: 'English',
                isSelected: _selected == 'en',
                onTap: () => setState(() => _selected = 'en'),
              ).animate().slideX(begin: -0.1, duration: 300.ms, delay: 200.ms),
              const SizedBox(height: AppSpacing.md),
              LanguageCard(
                languageCode: 'sw',
                languageName: 'Swahili',
                nativeName: 'Kiswahili',
                isSelected: _selected == 'sw',
                onTap: () => setState(() => _selected = 'sw'),
              ).animate().slideX(begin: -0.1, duration: 300.ms, delay: 300.ms),
              const Spacer(),
              AppPrimaryButton(
                label: 'Continue',
                onPressed: _onContinue,
                isLoading: _loading,
              ).animate().slideY(begin: 0.3, duration: 400.ms, delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
