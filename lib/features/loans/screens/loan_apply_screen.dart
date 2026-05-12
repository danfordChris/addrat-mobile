import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/features/loans/providers/loan_provider.dart';
import 'package:pesa_lending/shared/enums/loan_status_enum.dart';
import 'package:pesa_lending/shared/enums/schedule_status_enum.dart';
import 'package:pesa_lending/shared/shared.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// ── Loan Apply Screen ─────────────────────────────────────────

class LoanApplyScreen extends StatefulWidget {
  final Map<String, dynamic> calculation;

  const LoanApplyScreen({super.key, required this.calculation});

  @override
  State<LoanApplyScreen> createState() => _ApplyState();
}

class _ApplyState extends State<LoanApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeCtrl = TextEditingController();

  @override
  void dispose() {
    _purposeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final loan = await context.stateRead<LoanProvider>().applyLoan({
        'productId': widget.calculation['productId'],
        'amount': widget.calculation['amount'],
        'termDays': widget.calculation['termDays'],
        'purpose': _purposeCtrl.text.trim(),
      });
      if (!mounted) return;
      final loanStatus = LoanStatus.fromString(loan['status'] as String?);
      if (loanStatus == LoanStatus.approved) {
        _showApprovalSheet(loan);
      } else if (loanStatus == LoanStatus.rejected) {
        AppSnackbar.error(loan['rejectionReason'] ?? 'Ombi limekataliwa.');
      } else {
        AppSnackbar.success('Ombi limewasilishwa.');
        context.go(AppRoute.home.path);
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(e.toString());
    }
  }

  void _showApprovalSheet(Map<String, dynamic> loan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ApprovalSheet(
        loan: loan,
        onAccept: () {
          context.pop();
          context.push(AppRoute.loanDetail.replaceParam('id', '${loan['id']}'));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.stateWatch<LoanProvider>();
    final calc = widget.calculation;
    final productName = calc['productName'] as String? ?? 'Mkopo';
    final disbursed = (calc['disbursedAmount'] as num?)?.toDouble() ?? 0;
    final total = (calc['totalRepayable'] as num?)?.toDouble() ?? 0;
    final termDays = calc['termDays'];
    final apr = calc['effectiveAprPct'];

    final cs = context.colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text('Omba Mkopo',
            style: context.titleLarge.copyWith(color: cs.onSurface)),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loan summary hero card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0D2456),
                          const Color(0xFF1141A8),
                          cs.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          Text(productName,
                              style: context.bodySmall.medium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.65))),
                          const SizedBox(height: 8),
                          Text(disbursed.tzs,
                              style: context.displaySmall.extraBold.copyWith(
                                  color: Colors.white, letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          Text('utakachopata kwenye simu',
                              style: context.bodySmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.6))),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _SummaryChip(
                                    icon: HugeIcons.strokeRoundedMoneySend01,
                                    label: 'Kulipa',
                                    value: total.tzs),
                                _VLine(),
                                _SummaryChip(
                                    icon: HugeIcons.strokeRoundedTime01,
                                    label: 'Muda',
                                    value: '$termDays siku'),
                                _VLine(),
                                _SummaryChip(
                                    icon: HugeIcons.strokeRoundedPercentCircle,
                                    label: 'APR',
                                    value: '$apr%'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  Text('Taarifa za Ombi',
                          style:
                              context.titleSmall.copyWith(color: cs.onSurface))
                      .animate(delay: 100.ms)
                      .fadeIn(),
                  const SizedBox(height: 12),

                  AppTextField(
                    label: 'Sababu ya Mkopo',
                    hint: 'Mfano: Biashara, Elimu, Afya...',
                    controller: _purposeCtrl,
                    maxLines: 2,
                    prefixIcon: HugeIcon(
                        icon: HugeIcons.strokeRoundedEdit01,
                        color: cs.onSurfaceVariant,
                        size: 20),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Taja sababu ya mkopo' : null,
                  ).animate(delay: 150.ms).fadeIn(),

                  const SizedBox(height: 20),

                  // Terms notice
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border:
                          Border.all(color: cs.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          HugeIcon(
                              icon: HugeIcons.strokeRoundedInformationCircle,
                              color: cs.primary,
                              size: 16),
                          const SizedBox(width: 8),
                          Text('Masharti ya Mkopo',
                              style: context.labelMedium
                                  .copyWith(color: cs.primary)),
                        ]),
                        const SizedBox(height: 10),
                        ...[
                          'Fedha zitatumwa ndani ya akaunti yako ya M-Pesa',
                          'Lazima ulipie kabla ya tarehe ya mwisho',
                          'Kutolipa kwa wakati kutasababisha adhabu ya 5%',
                        ].map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    margin:
                                        const EdgeInsets.only(top: 6, right: 8),
                                    decoration: BoxDecoration(
                                        color: cs.primary,
                                        shape: BoxShape.circle),
                                  ),
                                  Expanded(
                                    child: Text(t,
                                        style: context.bodySmall.copyWith(
                                            color: cs.onSurfaceVariant)),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(),
                ],
              ),
            ),
          ),

          // Bottom CTA
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(top: BorderSide(color: cs.outlineVariant)),
              ),
              child: AppPrimaryButton(
                label: state.isSubmitting ? 'Inatuma...' : 'Wasilisha Ombi',
                isLoading: state.isSubmitting,
                leadingIcon: HugeIcons.strokeRoundedSent,
                onPressed: state.isSubmitting ? null : _submit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const _SummaryChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
              icon: icon,
              color: Colors.white.withValues(alpha: 0.65),
              size: 16),
          const SizedBox(height: 4),
          Text(label,
              style: context.labelSmall.medium
                  .copyWith(color: Colors.white.withValues(alpha: 0.6))),
          const SizedBox(height: 2),
          Text(value,
              style: context.bodySmall.bold.copyWith(color: Colors.white)),
        ],
      );
}

class _VLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1, height: 38, color: Colors.white.withValues(alpha: 0.2));
}

// ── Approval Bottom Sheet ─────────────────────────────────────

class _ApprovalSheet extends StatelessWidget {
  final Map<String, dynamic> loan;
  final VoidCallback onAccept;

  const _ApprovalSheet({required this.loan, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.secondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                color: cs.secondary,
                size: 40),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text('Mkopo Umeidhinishwa!',
              style: context.titleLarge.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
              'Mkopo wako wa ${(loan['principalAmount'] as num).tzs} umeidhinishwa!',
              style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: 'Pokea na Kubali Mkopo',
            leadingIcon: HugeIcons.strokeRoundedDownload04,
            onPressed: onAccept,
          ),
        ],
      ),
    );
  }
}

// ── Loan Detail Screen ────────────────────────────────────────

class LoanDetailScreen extends StatefulWidget {
  final String loanId;

  const LoanDetailScreen({super.key, required this.loanId});

  @override
  State<LoanDetailScreen> createState() => _DetailState();
}

class _DetailState extends State<LoanDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        context.stateRead<LoanProvider>().startLoanTracking(widget.loanId));
  }

  @override
  void dispose() {
    context.stateRead<LoanProvider>().stopLoanTracking();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.stateWatch<LoanProvider>();

    final cs = context.colorScheme;

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    final loan = state.currentLoan;
    if (loan == null) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
            backgroundColor: cs.surface,
            title: Text('Maelezo ya Mkopo',
                style: context.titleLarge.copyWith(color: cs.onSurface))),
        body: Center(
          child: Text('Mkopo haukupatikana',
              style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant)),
        ),
      );
    }

    final loanStatus = LoanStatus.fromString(loan['status'] as String?);
    final isActive = loanStatus.isLive;
    final isApproved = loanStatus == LoanStatus.approved;
    final isDisbursementPending = loanStatus == LoanStatus.disbursementPending;
    final isDisbursementFailed = loanStatus == LoanStatus.disbursementFailed;
    final outstanding = (loan['outstandingPrincipal'] as num?)?.toDouble() ?? 0;
    final totalRepaid = (loan['totalRepaid'] as num?)?.toDouble() ?? 0;
    final principal = (loan['principalAmount'] as num).toDouble();
    final progress = (1 - (outstanding / principal)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          // Header
          _LoanDetailHeader(
            loan: loan,
            loanStatus: loanStatus,
            outstanding: outstanding,
            totalRepaid: totalRepaid,
            progress: progress,
            isActive: isActive,
          ),

          // Tab bar
          Container(
            color: cs.surfaceContainer,
            child: TabBar(
              controller: _tabs,
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorColor: cs.primary,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: cs.outlineVariant,
              tabs: const [
                Tab(text: 'Muhtasari'),
                Tab(text: 'Ratiba'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                // Summary tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DetailGrid(loan: loan),
                      const SizedBox(height: 16),
                      if (isApproved)
                        _AcceptWidget(loanId: loan['id'].toString()),
                      if (isDisbursementPending)
                        const _DisbursementPendingNotice(),
                      if (isDisbursementFailed)
                        const _DisbursementFailedNotice(),
                      if (isActive)
                        _PayNowButton(
                          loanId: loan['id'].toString(),
                          outstanding: outstanding,
                        ),
                    ],
                  ),
                ),

                // Schedule tab
                _ScheduleTab(schedule: loan['schedule'] as List? ?? []),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loan Detail Header ────────────────────────────────────────

class _LoanDetailHeader extends StatelessWidget {
  final Map<String, dynamic> loan;
  final LoanStatus loanStatus;
  final double outstanding, totalRepaid, progress;
  final bool isActive;

  const _LoanDetailHeader({
    required this.loan,
    required this.loanStatus,
    required this.outstanding,
    required this.totalRepaid,
    required this.progress,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final isOverdue = loanStatus == LoanStatus.overdue;
    final progressColor = isOverdue ? cs.error : cs.secondary;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D2456),
            const Color(0xFF1141A8),
            cs.primary
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            children: [
              // Back + title
              Row(children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      color: Colors.white,
                      size: 22),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text('Maelezo ya Mkopo',
                      style: context.titleMedium.bold
                          .copyWith(color: Colors.white)),
                ),
                _StatusPill(status: loanStatus.value),
              ]),
              const SizedBox(height: 16),

              // Amount
              Text(loan['productName'] ?? '',
                  style: context.bodySmall
                      .copyWith(color: Colors.white.withValues(alpha: 0.65))),
              const SizedBox(height: 4),
              Text((loan['principalAmount'] as num).tzs,
                  style: context.displaySmall.extraBold
                      .copyWith(color: Colors.white, letterSpacing: -0.5)),

              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  Expanded(
                      child: _HeroStat(
                    label: 'Kilichobaki',
                    value: outstanding.tzs,
                    color: isOverdue ? cs.error : Colors.white,
                  )),
                  Container(
                      width: 1,
                      height: 32,
                      color: Colors.white.withValues(alpha: 0.2)),
                  Expanded(
                      child: _HeroStat(
                    label: 'Imelipwa',
                    value: totalRepaid.tzs,
                    color: cs.secondary,
                  )),
                  if (isActive) ...[
                    Container(
                        width: 1,
                        height: 32,
                        color: Colors.white.withValues(alpha: 0.2)),
                    Expanded(
                        child: _HeroStat(
                      label: 'DPD',
                      value: '${loan['daysPastDue'] ?? 0} siku',
                      color: isOverdue ? cs.error : Colors.white,
                    )),
                  ],
                ],
              ),

              if (isActive) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    color: progressColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(progress * 100).toStringAsFixed(0)}% imelipwa',
                        style: context.labelSmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.65))),
                    if (isOverdue)
                      Text('⚠ Imechelewa',
                          style: context.labelSmall.semiBold
                              .copyWith(color: cs.error)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label, value;
  final Color color;

  const _HeroStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label,
              style: context.labelSmall
                  .copyWith(color: Colors.white.withValues(alpha: 0.6))),
          const SizedBox(height: 3),
          Text(value, style: context.bodySmall.bold.copyWith(color: color)),
        ],
      );
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final (label, color) = switch (LoanStatus.fromString(status)) {
      LoanStatus.active => ('Inaendelea', cs.secondary),
      LoanStatus.overdue => ('Imechelewa', cs.error),
      LoanStatus.approved => ('Imeidhinishwa', cs.primary),
      LoanStatus.disbursementPending => ('Inatuma fedha', cs.tertiary),
      LoanStatus.disbursementFailed => ('Utumaji umeshindikana', cs.error),
      LoanStatus.rejected => ('Ilikataliwa', cs.error),
      LoanStatus.completed => ('Imekamilika', cs.secondary),
      LoanStatus.closed => ('Imefungwa', cs.onSurfaceVariant),
      LoanStatus.pending => ('Inasubiri', cs.tertiary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: context.labelSmall.bold.copyWith(color: color)),
    );
  }
}

// ── Detail Grid ───────────────────────────────────────────────

class _DetailGrid extends StatelessWidget {
  final Map<String, dynamic> loan;

  const _DetailGrid({required this.loan});

  @override
  Widget build(BuildContext context) {
    final rows = <_DetailRow>[
      _DetailRow(
          icon: HugeIcons.strokeRoundedInvoice01,
          label: 'Nambari ya Mkopo',
          value: loan['loanNumber'] ?? '—'),
      _DetailRow(
          icon: HugeIcons.strokeRoundedPercentCircle,
          label: 'Riba kwa Mwezi',
          value:
              '${((loan['monthlyRate'] as num? ?? 0) * 100).toStringAsFixed(1)}%'),
      _DetailRow(
          icon: HugeIcons.strokeRoundedTime01,
          label: 'Muda',
          value: '${loan['termDays'] ?? 0} siku'),
      _DetailRow(
          icon: HugeIcons.strokeRoundedCalendar03,
          label: 'Tarehe ya Mwisho',
          value: loan['dueDate']?.toString() ?? 'N/A'),
      _DetailRow(
          icon: HugeIcons.strokeRoundedEdit01,
          label: 'Sababu',
          value: loan['purpose'] ?? 'N/A'),
      if (loan['rejectionReason'] != null)
        _DetailRow(
            icon: HugeIcons.strokeRoundedAlert02,
            label: 'Sababu ya Kukataliwa',
            value: loan['rejectionReason'],
            isError: true),
    ];

    final cs = context.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows.length,
        separatorBuilder: (_, __) =>
            Divider(color: cs.outlineVariant, height: 1),
        itemBuilder: (_, i) => _DetailRowWidget(row: rows[i]),
      ),
    );
  }
}

class _DetailRow {
  final IconData icon;
  final String label, value;
  final bool isError;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isError = false,
  });
}

class _DetailRowWidget extends StatelessWidget {
  final _DetailRow row;

  const _DetailRowWidget({required this.row});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: HugeIcon(icon: row.icon, color: cs.primary, size: 15),
          ),
          const SizedBox(width: 12),
          Text(row.label,
              style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant)),
          const Spacer(),
          Flexible(
            child: Text(row.value,
                style: context.labelMedium
                    .copyWith(color: row.isError ? cs.error : cs.onSurface),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}

// ── Schedule Tab ──────────────────────────────────────────────

class _ScheduleTab extends StatelessWidget {
  final List schedule;

  const _ScheduleTab({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    if (schedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
                icon: HugeIcons.strokeRoundedCalendar03,
                color: cs.onSurfaceVariant,
                size: 40),
            const SizedBox(height: 12),
            Text('Ratiba haipatikani bado',
                style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: schedule.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final s = schedule[i] as Map<String, dynamic>;
        final scheduleStatus =
            ScheduleStatus.fromString(s['status'] as String?);
        final isPaid = scheduleStatus == ScheduleStatus.paid;
        final isOverdue = scheduleStatus == ScheduleStatus.overdue;
        final color = isPaid
            ? cs.secondary
            : isOverdue
                ? cs.error
                : cs.primary;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: isPaid
                    ? HugeIcon(
                        icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                        color: color,
                        size: 18)
                    : Center(
                        child: Text('${s['installmentNo']}',
                            style:
                                context.bodySmall.bold.copyWith(color: color)),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['dueDate']?.toString() ?? '',
                        style: context.bodySmall
                            .copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text((s['totalDue'] as num).tzs,
                        style:
                            context.titleSmall.copyWith(color: cs.onSurface)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                    isPaid
                        ? 'Imelipwa'
                        : isOverdue
                            ? 'Imechelewa'
                            : 'Inasubiri',
                    style: context.labelSmall.bold.copyWith(color: color)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Pay Now Button ────────────────────────────────────────────

class _PayNowButton extends StatelessWidget {
  final String loanId;
  final double outstanding;

  const _PayNowButton({required this.loanId, required this.outstanding});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return GestureDetector(
      onTap: () => context.push(
          AppRoute.repayment.replaceParam('loanId', loanId),
          extra: {'outstanding': outstanding.toStringAsFixed(2)}),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [cs.secondary, const Color(0xFF0DB870)]),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
                color: cs.secondary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
                icon: HugeIcons.strokeRoundedMoneyReceive01,
                color: Colors.white,
                size: 20),
            const SizedBox(width: 10),
            Text('Lipa Mkopo Sasa',
                style: context.labelLarge.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ── Accept Widget ─────────────────────────────────────────────

class _AcceptWidget extends StatefulWidget {
  final String loanId;

  const _AcceptWidget({required this.loanId});

  @override
  State<_AcceptWidget> createState() => _AcceptState();
}

class _AcceptState extends State<_AcceptWidget> {
  String _pin = '';

  Future<void> _accept() async {
    if (_pin.length < 6) {
      AppSnackbar.error('Weka PIN kamili ya tarakimu 6');
      return;
    }
    try {
      await context.stateRead<LoanProvider>().acceptLoan(widget.loanId, _pin);
      if (mounted) {
        AppSnackbar.success('Mkopo umekubaliwa. Utumaji wa fedha unaendelea.');
        context.go(AppRoute.home.path);
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.stateWatch<LoanProvider>().isSubmitting;

    final cs = context.colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(children: [
            HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                color: cs.secondary,
                size: 22),
            const SizedBox(width: 10),
            Text('Kubali Mkopo',
                style: context.titleSmall.copyWith(color: cs.onSurface)),
          ]),
          const SizedBox(height: 8),
          Text(
              'Weka PIN yako ya miamala kukubali na kupokea fedha kwenye simu yako.',
              style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),
          PinCodeTextField(
            appContext: context,
            length: 6,
            obscureText: true,
            keyboardType: TextInputType.number,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(8),
              fieldHeight: 46,
              fieldWidth: 40,
              activeFillColor: cs.surfaceContainer,
              inactiveFillColor: cs.surfaceContainer,
              selectedFillColor: cs.surfaceContainerHighest,
              activeColor: cs.primary,
              selectedColor: cs.primary,
              inactiveColor: cs.outlineVariant,
            ),
            enableActiveFill: true,
            onChanged: (v) => setState(() => _pin = v),
            onCompleted: (_) {},
          ),
          const SizedBox(height: 12),
          AppPrimaryButton(
            label: 'Kubali & Pokea Fedha',
            leadingIcon: HugeIcons.strokeRoundedDownload04,
            onPressed: _pin.length == 6 ? _accept : null,
            isLoading: loading,
          ),
        ],
      ),
    );
  }
}

class _DisbursementPendingNotice extends StatelessWidget {
  const _DisbursementPendingNotice();

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          HugeIcon(
              icon: HugeIcons.strokeRoundedTime01,
              color: cs.tertiary,
              size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Utumaji wa fedha unaendelea. Tafadhali subiri uthibitisho kwenye akaunti yako.',
              style: context.bodySmall.copyWith(color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisbursementFailedNotice extends StatelessWidget {
  const _DisbursementFailedNotice();

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          HugeIcon(
              icon: HugeIcons.strokeRoundedAlert02, color: cs.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Utumaji wa fedha umeshindikana. Wasiliana na msaada au subiri mrejesho wa mkopo wako.',
              style: context.bodySmall.copyWith(color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
