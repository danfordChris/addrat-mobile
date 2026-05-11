import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pesa_lending/features/auth/providers/auth_provider.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/shared/enums/kyc_status_enum.dart';
import 'package:pesa_lending/shared/widgets/shared_widgets.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber, purpose;
  const OtpScreen({super.key, required this.phoneNumber, required this.purpose});
  @override State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';
  int _secondsLeft = 60;
  bool _canResend = false;

  @override void initState() { super.initState(); _startCountdown(); }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() { if (_secondsLeft > 0) { _secondsLeft--; } else { _canResend = true; } });
      return _secondsLeft > 0;
    });
  }

  Future<void> _verify() async {
    if (_otp.length != 6) return;
    try {
      await context.stateRead<AuthProvider>().verifyOtp(widget.phoneNumber, _otp, widget.purpose);
      if (!mounted) return;
      final kyc = KycStatus.fromString(context.stateRead<AuthProvider>().kycStatus);
      if (kyc != KycStatus.approved) {
        context.go(AppRoute.kyc.path);
      } else {
        context.go(AppRoute.home.path);
      }
    } catch (e) { if (mounted) showError(context, e.toString()); }
  }

  Future<void> _resend() async {
    setState(() { _secondsLeft = 60; _canResend = false; });
    try {
      await context.stateRead<AuthProvider>().sendOtp(widget.phoneNumber, widget.purpose);
      if (mounted) showSuccess(context, 'OTP imetumwa tena');
    } catch (e) { if (mounted) showError(context, e.toString()); }
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final loading = context.stateWatch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Thibitisha OTP'),
          backgroundColor: Colors.transparent,
          foregroundColor: cs.primary,
          elevation: 0),
      body: LoadingOverlay(
        isLoading: loading,
        child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Icon(Icons.sms_outlined, size: 40, color: cs.primary),
              const SizedBox(height: 12),
              Text('Nambari ya Uthibitisho',
                  style: context.titleMedium.bold),
              const SizedBox(height: 6),
              Text('Tumetuma SMS kwenda ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant)),
            ])),
          const SizedBox(height: 36),
          PinCodeTextField(
            appContext: context, length: 6,
            keyboardType: TextInputType.number, animationType: AnimationType.fade,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box, borderRadius: BorderRadius.circular(10),
              fieldHeight: 52, fieldWidth: 44,
              activeColor: cs.primary, selectedColor: cs.primary,
              inactiveColor: cs.outlineVariant,
              activeFillColor: cs.surfaceContainerHighest,
              inactiveFillColor: cs.surfaceContainer,
              selectedFillColor: cs.primaryContainer),
            enableActiveFill: true,
            onChanged: (v) => setState(() => _otp = v),
            onCompleted: (_) => _verify()),
          const SizedBox(height: 24),
          PesaButton(label: 'Thibitisha', onPressed: _otp.length == 6 ? _verify : null, isLoading: loading),
          const SizedBox(height: 20),
          _canResend
              ? TextButton(onPressed: _resend,
                  child: Text('Tuma tena OTP',
                      style: context.bodyMedium.bold.copyWith(color: cs.primary)))
              : Text('Tuma tena baada ya $_secondsLeft sekunde',
                  style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant)),
        ])),
      ),
    );
  }
}

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});
  @override State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  String _pin = '';
  bool _confirmed = false;

  Future<void> _handleComplete(String v) async {
    if (!_confirmed) { setState(() { _pin = v; _confirmed = true; }); return; }
    if (_pin != v) {
      showError(context, 'PIN hazilingani. Jaribu tena.');
      setState(() { _confirmed = false; _pin = ''; });
      return;
    }
    try {
      await context.stateRead<AuthProvider>().setPin(_pin);
      if (mounted) { showSuccess(context, 'PIN imewekwa!'); context.go(AppRoute.home.path); }
    } catch (e) { if (mounted) showError(context, e.toString()); }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final loading = context.stateWatch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Weka PIN'),
          backgroundColor: Colors.transparent,
          foregroundColor: cs.primary,
          elevation: 0),
      body: LoadingOverlay(
        isLoading: loading,
        child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          Icon(Icons.pin_outlined, size: 48, color: cs.primary),
          const SizedBox(height: 16),
          Text(_confirmed ? 'Thibitisha PIN yako' : 'Weka PIN ya miamala',
              style: context.titleLarge.bold),
          const SizedBox(height: 8),
          Text('PIN itumike kuidhinisha malipo yako.',
              style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 36),
          PinCodeTextField(
            appContext: context, length: 6, obscureText: true,
            keyboardType: TextInputType.number,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.circle, fieldHeight: 52, fieldWidth: 44,
              activeColor: cs.primary, selectedColor: cs.primary,
              inactiveColor: cs.outlineVariant),
            onChanged: (v) => setState(() { if (!_confirmed) _pin = v; }),
            onCompleted: _handleComplete),
        ])),
      ),
    );
  }
}
