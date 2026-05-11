import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/features/auth/providers/auth_provider.dart';
import 'package:pesa_lending/features/loans/providers/loan_provider.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/shared/components/feedback/app_snackbar.dart';
import 'package:pesa_lending/shared/enums/kyc_status_enum.dart';
import 'package:pesa_lending/shared/enums/loan_status_enum.dart';
import 'package:pesa_lending/shared/widgets/shared_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.stateRead<AuthProvider>().refreshFromServer();
    if (mounted) context.stateRead<LoanProvider>().loadMyLoans();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Habari za Asubuhi';
    if (h < 17) return 'Habari za Mchana';
    return 'Habari za Jioni';
  }

  Future<void> _onLipaMkopo() async {
    final loan = await context.stateRead<LoanProvider>().loadActiveLoan();
    if (!mounted) return;
    if (loan != null) {
      final id = loan['id'] as String?;
      final outstanding = loan['outstandingPrincipal']?.toString() ?? '0';
      if (id != null) {
        context.push(AppRoute.repayment.replaceParam('loanId', id), extra: {'outstanding': outstanding});
        return;
      }
    }
    AppSnackbar.error( 'Huna mkopo unaoendelea kwa sasa');
  }

  @override
  Widget build(BuildContext context) {
    final cs    = context.colorScheme;
    final auth  = context.stateWatch<AuthProvider>();
    final loans = context.stateWatch<LoanProvider>();
    final name  = auth.fullName ?? '';
    final limit = auth.creditLimit ?? '0';
    final kyc   = auth.kycStatus ?? 'NOT_STARTED';
    final firstName = name.isNotEmpty ? name.split(' ').first : 'Mtumiaji';
    final initial   = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        color: cs.primary,
        backgroundColor: cs.surfaceContainerHighest,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _DashboardHeader(
                greeting: _greeting(),
                firstName: firstName,
                initial: initial,
                limitFormatted: _fmtTzs(limit),
                kyc: kyc,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (KycStatus.fromString(kyc) != KycStatus.approved) ...[
                    const SizedBox(height: 16),
                    _KycBanner(status: kyc)
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.15),
                  ],

                  const SizedBox(height: 28),

                  _SectionLabel('Vitendo vya Haraka'),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: _QuickAction(
                        icon: HugeIcons.strokeRoundedCreditCard,
                        label: 'Omba\nMkopo',
                        color: cs.primary,
                        onTap: () => context.push(AppRoute.loansProducts.path),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: HugeIcons.strokeRoundedMoneySend01,
                        label: 'Lipa\nMkopo',
                        color: const Color(0xFF0D9488),
                        onTap: _onLipaMkopo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: HugeIcons.strokeRoundedCalculator,
                        label: 'Hesabu\nMkopo',
                        color: cs.tertiary,
                        onTap: () => context.push(AppRoute.loansCalculator.path),
                      ),
                    ),
                  ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionLabel('Mikopo Yangu'),
                      TextButton(
                        onPressed: () => context.push(AppRoute.loansProducts.path),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: cs.primary,
                        ),
                        child: Text('Ona Yote',
                            style: context.labelMedium.copyWith(color: cs.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (loans.isLoading)
                    ...[
                      _LoanShimmer(),
                      const SizedBox(height: 10),
                      _LoanShimmer(),
                    ]
                  else if (loans.myLoans.isEmpty)
                    _EmptyLoans()
                  else
                    ...loans.myLoans.take(3).map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LoanCard(loan: l),
                        )),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTzs(String v) {
    final n = double.tryParse(v) ?? 0;
    return 'TZS ${NumberFormat('#,##0').format(n)}';
  }
}

// ── Dashboard Header ──────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final String greeting, firstName, initial, limitFormatted, kyc;
  const _DashboardHeader({
    required this.greeting,
    required this.firstName,
    required this.initial,
    required this.limitFormatted,
    required this.kyc,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1141A8), cs.primary, const Color(0xFF4F8EFF)],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(greeting,
                        style: context.labelSmall.medium.copyWith(
                            color: Colors.white.withValues(alpha: 0.65),
                            letterSpacing: 0.2)),
                    const SizedBox(height: 2),
                    Text(firstName,
                        style: context.titleLarge.extraBold.copyWith(
                            color: Colors.white, letterSpacing: -0.3)),
                  ]),
                  Row(children: [
                    _HeaderIconBtn(
                      icon: HugeIcons.strokeRoundedNotification01,
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      child: Text(initial,
                          style: context.titleMedium.bold.copyWith(
                              color: Colors.white)),
                    ),
                  ]),
                ],
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15), width: 1),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Kikomo cha Mkopo',
                          style: context.labelSmall.medium.copyWith(
                              color: Colors.white.withValues(alpha: 0.65))),
                      const SizedBox(height: 6),
                      Text(limitFormatted,
                          style: context.titleLarge.extraBold.copyWith(
                              color: Colors.white, letterSpacing: -0.3)),
                    ]),
                  ),
                  _KycStatusChip(kyc: kyc),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: HugeIcon(icon: icon, color: Colors.white, size: 20),
        ),
      );
}

class _KycStatusChip extends StatelessWidget {
  final String kyc;
  const _KycStatusChip({required this.kyc});
  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final (label, color) = switch (KycStatus.fromString(kyc)) {
      KycStatus.approved   => ('✓ Imethibitishwa', cs.secondary),
      KycStatus.pending    => ('⏳ Inapitiwa', cs.tertiary),
      KycStatus.rejected   => ('✗ Ilikataliwa', cs.error),
      KycStatus.notStarted => ('KYC Pending', Colors.white60),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          style: context.labelSmall.bold.copyWith(
              color: color, letterSpacing: 0.2)),
    );
  }
}

// ── KYC Banner ────────────────────────────────────────────────

class _KycBanner extends StatelessWidget {
  final String status;
  const _KycBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return switch (KycStatus.fromString(status)) {
      KycStatus.pending => _banner(
          context,
          icon: HugeIcons.strokeRoundedClock01,
          iconColor: cs.tertiary,
          borderColor: cs.tertiary,
          title: 'KYC Inapitiwa',
          subtitle: 'Timu yetu inaangalia maombi yako. Subiri taarifa.',
          tappable: false,
        ),
      KycStatus.rejected => _banner(
          context,
          icon: HugeIcons.strokeRoundedAlert02,
          iconColor: cs.error,
          borderColor: cs.error,
          title: 'KYC Ilikataliwa',
          subtitle: 'Ombi lako lilikataliwa. Bonyeza hapa kujaribu tena.',
          tappable: true,
          onTap: () => context.push(AppRoute.kyc.path),
        ),
      KycStatus.approved || KycStatus.notStarted => _banner(
          context,
          icon: HugeIcons.strokeRoundedUserCheck01,
          iconColor: cs.primary,
          borderColor: cs.primary,
          title: 'Thibitisha Utambulisho Wako',
          subtitle: 'Kamilisha KYC kupata kikomo cha mkopo.',
          tappable: true,
          onTap: () => context.push(AppRoute.kyc.path),
        ),
    };
  }

  Widget _banner(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required String title,
    required String subtitle,
    required bool tappable,
    VoidCallback? onTap,
  }) =>
      GestureDetector(
        onTap: tappable ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: borderColor.withValues(alpha: 0.35), width: 1),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: HugeIcon(icon: icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: context.labelMedium.bold.copyWith(color: iconColor)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: context.bodySmall.copyWith(
                        color: iconColor.withValues(alpha: 0.75), height: 1.4)),
              ]),
            ),
            if (tappable)
              HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: iconColor,
                  size: 16),
          ]),
        ),
      );
}

// ── Section Label ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: context.titleSmall.bold.copyWith(
          color: context.colorScheme.onSurface, letterSpacing: -0.1));
}

// ── Quick Action ──────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.labelSmall.bold.copyWith(color: color, height: 1.35),
          ),
        ]),
      ),
    );
  }
}

// ── Loan Card ─────────────────────────────────────────────────

class _LoanCard extends StatelessWidget {
  final Map<String, dynamic> loan;
  const _LoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final cs          = context.colorScheme;
    final outstanding = (loan['outstandingPrincipal'] as num?)?.toDouble() ?? 0;
    final total       = (loan['principalAmount'] as num?)?.toDouble() ?? 1;
    final progress    = (1 - (outstanding / total)).clamp(0.0, 1.0);
    final loanStatus  = LoanStatus.fromString(loan['status'] as String?);
    final isOverdue   = loanStatus == LoanStatus.overdue;
    final isActive    = loanStatus.isLive;

    return GestureDetector(
      onTap: () => context.push(AppRoute.loanDetail.replaceParam('id', '${loan['id']}')),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  loan['productName'] ?? 'Mkopo',
                  style: context.titleSmall.bold.copyWith(color: cs.onSurface),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: loan['status'] ?? 'PENDING'),
            ],
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: _LoanStat(
                label: 'Kiasi cha Awali',
                value: (loan['principalAmount'] as num).tzs,
              ),
            ),
            Container(width: 1, height: 36, color: cs.outlineVariant),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _LoanStat(
                  label: 'Kilichobaki',
                  value: outstanding.tzs,
                  valueColor: isOverdue ? cs.error : cs.primary,
                ),
              ),
            ),
          ]),
          if (isActive) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: cs.surface,
                color: isOverdue ? cs.error : cs.secondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progress * 100).toStringAsFixed(0)}% imelipwa',
                    style: context.labelSmall.medium.copyWith(
                        color: cs.onSurfaceVariant)),
                if (isOverdue)
                  Text('Imechelewa!',
                      style: context.labelSmall.semiBold.copyWith(
                          color: cs.error)),
              ],
            ),
          ],
        ]),
      ),
    );
  }
}

class _LoanStat extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _LoanStat({required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: context.labelSmall.medium.copyWith(color: cs.onSurfaceVariant)),
      const SizedBox(height: 3),
      Text(value,
          style: context.titleSmall.bold.copyWith(
              color: valueColor ?? cs.onSurface)),
    ]);
  }
}

// ── Empty State ───────────────────────────────────────────────

class _EmptyLoans extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: HugeIcon(
              icon: HugeIcons.strokeRoundedWallet01,
              color: cs.primary,
              size: 34),
        ),
        const SizedBox(height: 16),
        Text('Huna Mkopo Bado',
            style: context.titleSmall.bold.copyWith(color: cs.onSurface)),
        const SizedBox(height: 6),
        Text(
          'Bonyeza "Omba Mkopo" kupata mkopo wako wa kwanza.',
          textAlign: TextAlign.center,
          style: context.bodySmall.copyWith(color: cs.onSurfaceVariant, height: 1.5),
        ),
      ]),
    );
  }
}

// ── Loan Shimmer ──────────────────────────────────────────────

class _LoanShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const ShimmerBox(height: 110, borderRadius: AppRadius.lg);
}
