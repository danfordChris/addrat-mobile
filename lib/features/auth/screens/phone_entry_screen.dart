import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/core/utils/formatters.dart';
import 'package:pesa_lending/core/utils/validators.dart';
import 'package:pesa_lending/features/auth/providers/auth_provider.dart';
import 'package:pesa_lending/features/auth/service/auth_api_service.dart';
import 'package:pesa_lending/shared/shared.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  String? _errorText;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final digits = _phoneController.text.trim();
    final error = Validators.phone(digits);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }
    setState(() {
      _errorText = null;
      _loading = true;
    });

    final phone = normalizeTzPhoneNumber(digits);
    try {
      await AuthApiService.requestOtp(phone, 'LOGIN');
      if (!mounted) return;
      setState(() => _loading = false);
      showAppBottomSheet<void>(
        context,
        title: 'Enter OTP',
        child: _OtpBottomSheet(phoneNumber: phone),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      setState(() => _errorText = e.toString());
      AppSnackbar.error( e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const AppBackButton(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Enter your\nphone number',
                style: context.headlineLarge.copyWith(color: cs.onSurface),
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'We\'ll send you a one-time code to verify.',
                style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: AppSpacing.xl),
              AppPhoneField(
                controller: _phoneController,
                errorText: _errorText,
                onChanged: (_) => setState(() => _errorText = null),
              ).animate().slideY(begin: 0.2, duration: 300.ms, delay: 200.ms),
              const Spacer(),
              AppPrimaryButton(
                label: 'Send Code',
                onPressed: _onSubmit,
                isLoading: _loading,
              ).animate().slideY(begin: 0.3, duration: 400.ms, delay: 300.ms),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: LegalLinksFooter(
                  onTermsTap: () {},
                  onPrivacyTap: () {},
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBottomSheet extends StatefulWidget {
  const _OtpBottomSheet({required this.phoneNumber});
  final String phoneNumber;

  @override
  State<_OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<_OtpBottomSheet> {
  bool _loading = false;
  bool _hasError = false;
  bool _showResend = false;

  Future<void> _onComplete(String otp) async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      await context.stateRead<AuthProvider>().verifyOtp(widget.phoneNumber, otp, 'LOGIN');
      
      if (!mounted) return;
      setState(() => _loading = false);

      context.pop();
      context.push(AppRoute.home.path);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
      AppSnackbar.error( e.toString());
    }
  }

  Future<void> _resend() async {
    setState(() => _showResend = false);
    try {
      await AuthApiService.requestOtp(widget.phoneNumber, 'LOGIN');
      if (mounted) AppSnackbar.success('New code sent');
    } catch (e) {
      if (mounted) AppSnackbar.error( e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Code sent to ${widget.phoneNumber}',
          style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppLoadingOverlay(
          isLoading: _loading,
          child: AppOtpField(
            onCompleted: _onComplete,
            hasError: _hasError,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (!_showResend)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Resend in ',
                  style: context.bodySmall.copyWith(color: cs.onSurfaceVariant)),
              CountdownTimer(
                seconds: 60,
                onFinished: () => setState(() => _showResend = true),
              ),
            ],
          )
        else
          AppTextButton(
            label: 'Resend code',
            onPressed: _resend,
          ),
      ],
    );
  }
}
