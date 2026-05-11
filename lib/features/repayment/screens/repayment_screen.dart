import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:uuid/uuid.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/features/repayment/enums/payment_channel_enum.dart';
import 'package:pesa_lending/features/repayment/service/payment_api_service.dart';
import 'package:pesa_lending/shared/shared.dart';

class RepaymentScreen extends StatefulWidget {
  final String loanId, outstandingAmount;

  const RepaymentScreen({
    super.key,
    required this.loanId,
    required this.outstandingAmount,
  });

  @override
  State<RepaymentScreen> createState() => _RepayState();
}

class _RepayState extends State<RepaymentScreen> {
  final _amountCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _pin = '';
  PaymentChannel _channel = PaymentChannel.mpesa;
  bool _loading = false;
  bool _success = false;
  String? _paymentRef;

  static IconData _channelIcon(PaymentChannel ch) => switch (ch) {
        PaymentChannel.mpesa  => HugeIcons.strokeRoundedSmartPhone01,
        PaymentChannel.airtel => HugeIcons.strokeRoundedSimcard01,
        PaymentChannel.bank   => HugeIcons.strokeRoundedBank,
      };

  @override
  void initState() {
    super.initState();
    _amountCtrl.text = widget.outstandingAmount;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String get _selectedChannelLabel => _channel.label;

  Future<void> _submit() async {
    if (_pin.length < 4) {
      AppSnackbar.error( 'Weka PIN sahihi');
      return;
    }
    if (_phoneCtrl.text.isEmpty) {
      AppSnackbar.error( 'Weka namba ya simu');
      return;
    }
    final amount =
        double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      AppSnackbar.error( 'Weka kiasi sahihi');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await PaymentApiService.makeRepayment({
        'loanId': widget.loanId,
        'amount': amount,
        'channel': _channel.code,
        'phoneNumber': _phoneCtrl.text.trim(),
        'idempotencyKey': const Uuid().v4(),
        'pin': _pin,
      });
      setState(() {
        _success = true;
        _paymentRef = res['paymentRef'] ?? 'N/A';
      });
    } catch (e) {
      if (mounted) AppSnackbar.error( e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return _RepaymentSuccessScreen(
        paymentRef: _paymentRef!,
        amount: double.tryParse(
                _amountCtrl.text.replaceAll(',', '')) ??
            0,
      );
    }

    final outstanding =
        double.tryParse(widget.outstandingAmount) ?? 0;

    final cs = context.colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lipa Mkopo',
                style: context.titleLarge.copyWith(color: cs.onSurface)),
            Text('Kiasi kilichobaki: ${outstanding.tzs}',
                style: context.bodySmall.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: cs.onSurface,
              size: 22),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Outstanding amount banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF052A1E), Color(0xFF063D2A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                        color: cs.secondary.withValues(alpha: 0.25)),
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.secondary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(
                          icon: HugeIcons.strokeRoundedMoneySend01,
                          color: cs.secondary,
                          size: 26),
                    ),
                    const SizedBox(width: 14),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kiasi Kilichobaki',
                              style: context.bodySmall.copyWith(
                                  color: cs.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text(outstanding.tzs,
                              style: context.headlineLarge.copyWith(
                                  color: cs.secondary)),
                        ]),
                  ]),
                ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // Amount to pay
                Text('Kiasi cha Kulipa',
                    style: context.titleSmall.copyWith(color: cs.onSurface))
                    .animate(delay: 60.ms).fadeIn(),
                const SizedBox(height: 10),
                AppTextField(
                  label: 'Kiasi (TZS)',
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: HugeIcon(
                      icon: HugeIcons.strokeRoundedMoney01,
                      color: cs.onSurfaceVariant,
                      size: 20),
                  validator: null,
                ).animate(delay: 80.ms).fadeIn(),

                const SizedBox(height: 24),

                // Payment channel
                Text('Njia ya Malipo',
                    style: context.titleSmall.copyWith(color: cs.onSurface))
                    .animate(delay: 100.ms).fadeIn(),
                const SizedBox(height: 10),
                Row(
                  children: PaymentChannel.values.map((ch) {
                    final sel = _channel == ch;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _channel = ch),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                              right: ch != PaymentChannel.values.last ? 10 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: sel
                                ? ch.color.withValues(alpha: 0.12)
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: sel ? ch.color : cs.outlineVariant,
                              width: sel ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              HugeIcon(
                                  icon: _channelIcon(ch),
                                  color: sel ? ch.color : cs.onSurfaceVariant,
                                  size: 22),
                              const SizedBox(height: 6),
                              Text(ch.label,
                                  style: context.labelSmall
                                      .copyWith(color: sel ? ch.color : cs.onSurfaceVariant)
                                      .bold),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ).animate(delay: 120.ms).fadeIn(),

                const SizedBox(height: 20),

                // Phone number
                AppTextField(
                  label: 'Namba ya $_selectedChannelLabel',
                  hint: '+255712345678',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: HugeIcon(
                      icon: HugeIcons.strokeRoundedSmartPhone01,
                      color: cs.onSurfaceVariant,
                      size: 20),
                ).animate(delay: 140.ms).fadeIn(),

                const SizedBox(height: 24),

                // PIN
                Text('PIN ya Miamala',
                    style: context.titleSmall.copyWith(color: cs.onSurface))
                    .animate(delay: 160.ms).fadeIn(),
                const SizedBox(height: 6),
                Text(
                    'PIN yako ya siri — haitatumwa kwa mtu yeyote',
                    style: context.bodySmall.copyWith(color: cs.onSurfaceVariant))
                    .animate(delay: 175.ms).fadeIn(),
                const SizedBox(height: 12),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 50,
                    fieldWidth: 44,
                    activeFillColor: cs.surfaceContainerHighest,
                    inactiveFillColor: cs.surfaceContainerHighest,
                    selectedFillColor: cs.surfaceContainer,
                    activeColor: cs.primary,
                    selectedColor: cs.primary,
                    inactiveColor: cs.outlineVariant,
                  ),
                  enableActiveFill: true,
                  onChanged: (v) => setState(() => _pin = v),
                  onCompleted: (_) {},
                ).animate(delay: 180.ms).fadeIn(),
              ],
            ),
          ),

          // Bottom CTA
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                    top: BorderSide(color: cs.outlineVariant)),
              ),
              child: AppPrimaryButton(
                label: _loading
                    ? 'Inathibitisha...'
                    : 'Thibitisha Malipo',
                isLoading: _loading,
                leadingIcon: HugeIcons.strokeRoundedLock,
                onPressed: _loading ? null : _submit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RepaymentSuccessScreen extends StatelessWidget {
  final String paymentRef;
  final double amount;

  const _RepaymentSuccessScreen(
      {required this.paymentRef, required this.amount});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                  color: cs.secondary,
                  size: 64,
                ),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: 28),

              Text('Malipo Yamefanikiwa!',
                  style: context.headlineLarge.copyWith(color: cs.secondary),
                  textAlign: TextAlign.center)
                  .animate(delay: 200.ms).fadeIn(),

              const SizedBox(height: 12),

              Text(amount.tzs,
                  style: context.displayLarge.copyWith(color: cs.onSurface),
                  textAlign: TextAlign.center)
                  .animate(delay: 280.ms).fadeIn(),

              const SizedBox(height: 8),

              Text(
                  'Mkopo wako umepunguzwa. Asante kwa kulipa kwa wakati!',
                  textAlign: TextAlign.center,
                  style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant))
                  .animate(delay: 320.ms).fadeIn(),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                        icon: HugeIcons.strokeRoundedInvoice01,
                        color: cs.onSurfaceVariant,
                        size: 16),
                    const SizedBox(width: 8),
                    Text('Kumbukumbu: $paymentRef',
                        style: context.labelMedium.copyWith(color: cs.onSurface)),
                  ],
                ),
              ).animate(delay: 380.ms).fadeIn(),

              const SizedBox(height: 40),

              AppPrimaryButton(
                label: 'Rudi Nyumbani',
                leadingIcon: HugeIcons.strokeRoundedHome01,
                onPressed: () => context.go(AppRoute.home.path),
              ).animate(delay: 440.ms).slideY(begin: 0.2, duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}
