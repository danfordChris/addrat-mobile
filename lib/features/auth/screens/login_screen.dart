import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/utils/formatters.dart';
import 'package:pesa_lending/core/utils/validators.dart';
import 'package:pesa_lending/features/auth/providers/auth_provider.dart';
import 'package:pesa_lending/shared/widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.stateRead<AuthProvider>().login(
          normalizeTzPhoneNumber(_phoneCtrl.text.trim()), _passCtrl.text);
      if (mounted) context.go(AppRoute.home.path);
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
          title: const Text('Ingia'),
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
                    Text('Karibu Tena!',
                        style: context.headlineSmall.bold.copyWith(color: cs.primary)),
                    const SizedBox(height: 6),
                    Text('Ingia kwenye akaunti yako',
                        style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 32),
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
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Weka nywila' : null),
                    const SizedBox(height: 32),
                    PesaButton(
                        label: 'Ingia', onPressed: _submit, isLoading: loading),
                    const SizedBox(height: 20),
                    Center(
                        child: GestureDetector(
                            onTap: () => context.push(AppRoute.authRegister.path),
                            child: Text.rich(TextSpan(children: [
                              TextSpan(text: 'Huna akaunti? ',
                                  style: context.bodyMedium),
                              TextSpan(
                                  text: 'Jisajili',
                                  style: context.bodyMedium.bold.copyWith(color: cs.primary)),
                            ])))),
                  ],
                )),
          )),
    );
  }
}
