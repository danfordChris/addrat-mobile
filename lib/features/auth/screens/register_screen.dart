import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/utils/formatters.dart';
import 'package:pesa_lending/core/utils/validators.dart';
import 'package:pesa_lending/features/auth/enums/otp_purpose_enum.dart';
import 'package:pesa_lending/features/auth/providers/auth_provider.dart';
import 'package:pesa_lending/shared/widgets/shared_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final normalizedPhone = normalizeTzPhoneNumber(_phoneCtrl.text.trim());
    try {
      await context.stateRead<AuthProvider>()
          .register(normalizedPhone, _nameCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        context.push(AppRoute.authOtp.path,
            extra: {'phone': normalizedPhone, 'purpose': OtpPurpose.registration.value});
      }
    } catch (e) {
      if (mounted) showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final loading = context.stateWatch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Jisajili'),
          backgroundColor: Colors.transparent,
          foregroundColor: cs.primary,
          elevation: 0),
      body: LoadingOverlay(
        isLoading: loading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Karibu!\nTuambie kuhusu wewe.',
                      style: context.headlineSmall.bold.copyWith(
                          color: cs.primary, height: 1.3)),
                  const SizedBox(height: 28),
                  PesaTextField(
                      label: 'Jina Lako Kamili',
                      controller: _nameCtrl,
                      hint: 'Mfano: Amina Hassan',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (v) => v == null || v.length < 3
                          ? 'Jina lazima liwe na herufi 3+'
                          : null),
                  const SizedBox(height: 16),
                  PesaTextField(
                      label: 'Namba ya Simu',
                      controller: _phoneCtrl,
                      hint: '+255712345678',
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined),
                      validator: Validators.phone),
                  const SizedBox(height: 16),
                  PesaTextField(
                      label: 'Nywila',
                      controller: _passCtrl,
                      obscureText: _obscure,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure)),
                      validator: (v) => v == null || v.length < 6
                          ? 'Nywila lazima iwe na herufi 6+'
                          : null),
                  const SizedBox(height: 32),
                  PesaButton(
                      label: 'Endelea',
                      onPressed: _submit,
                      isLoading: loading,
                      icon: Icons.arrow_forward),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Una akaunti tayari? ',
                        style: context.bodyMedium),
                    GestureDetector(
                        onTap: () => context.go(AppRoute.authLogin.path),
                        child: Text('Ingia',
                            style: context.bodyMedium.bold.copyWith(color: cs.primary))),
                  ]),
                ],
              )),
        ),
      ),
    );
  }
}
