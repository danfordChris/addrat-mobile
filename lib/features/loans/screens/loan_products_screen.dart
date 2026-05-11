import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/extensions/num_ext.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/features/loans/providers/loan_provider.dart';
import 'package:pesa_lending/shared/shared.dart';
import 'package:shimmer/shimmer.dart';

// ── Loan Products Screen ──────────────────────────────────────

class LoanProductsScreen extends StatefulWidget {
  const LoanProductsScreen({super.key});

  @override
  State<LoanProductsScreen> createState() => _LoanProductsState();
}

class _LoanProductsState extends State<LoanProductsScreen> {
  Map<String, dynamic>? _selected;
  double _amount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.stateRead<LoanProvider>().loadProducts());
  }

  void _selectProduct(Map<String, dynamic> product) {
    final min = (product['minAmount'] as num).toDouble();
    setState(() {
      _selected = product;
      _amount = min;
    });
    _calculate();
  }

  void _calculate() {
    if (_selected == null) return;
    context.stateRead<LoanProvider>().calculate({
      'productId': _selected!['id'],
      'amount': _amount,
      'termDays': (_selected!['maxTermDays'] as num).toInt(),
    });
  }

  void _applyNow() {
    final calc = context.stateRead<LoanProvider>().calculation;
    if (calc == null || _selected == null) return;
    context.push(AppRoute.loansApply.path, extra: {
      ...calc,
      'productId': _selected!['id'],
      'productName': _selected!['name'] ?? 'Mkopo',
      'amount': _amount,
      'termDays': (_selected!['maxTermDays'] as num).toInt(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final loanProvider = context.stateWatch<LoanProvider>();
    final cs = context.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Omba Mkopo', style: context.titleLarge.copyWith(color: cs.onSurface)),
            Text('Chagua na omba mkopo wako', style: context.bodySmall.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: cs.onSurface, size: 22),
        ),
      ),
      body: loanProvider.isLoading && loanProvider.products.isEmpty
          ? const _ProductsShimmer()
          : loanProvider.products.isEmpty
              ? const _EmptyProducts()
              : _buildBody(loanProvider, cs),
    );
  }

  Widget _buildBody(LoanProvider loanProvider, ColorScheme cs) {
    return Stack(
      children: [
        RefreshIndicator(
          color: cs.primary,
          backgroundColor: cs.surfaceContainerHighest,
          onRefresh: () async => context.stateRead<LoanProvider>().loadProducts(),
          child: CustomScrollView(
            slivers: [
              // Promotional banner
              SliverToBoxAdapter(
                child: const _PromoBanner().animate().fadeIn(duration: 400.ms),
              ),

              // Section heading
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                  child: Text(
                    'Chagua bidhaa ya mkopo',
                    style: context.titleMedium.copyWith(color: cs.onSurface),
                  ),
                ).animate(delay: 100.ms).fadeIn(),
              ),

              // Product radio cards — selected card expands inline
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: loanProvider.products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final product = loanProvider.products[i];
                    final isSelected = _selected?['id'] == product['id'];
                    return _ProductRadioCard(
                      product: product,
                      isSelected: isSelected,
                      onTap: () => _selectProduct(product),
                      index: i,
                      amount: isSelected ? _amount : 0,
                      isCalculating: isSelected && loanProvider.isLoading,
                      calculation: isSelected ? loanProvider.calculation : null,
                      onChanged: (v) => setState(() => _amount = v),
                      onChangeEnd: (v) {
                        setState(() => _amount = v);
                        _calculate();
                      },
                    );
                  },
                ),
              ),

              // Bottom spacer for sticky CTA button
              SliverToBoxAdapter(
                child: SizedBox(height: _selected != null ? 96 : 32),
              ),
            ],
          ),
        ),

        // Sticky "Apply Now" button
        if (_selected != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(top: BorderSide(color: cs.outlineVariant)),
              ),
              child: AppPrimaryButton(
                label: loanProvider.isLoading ? 'Inakokotoa...' : 'Omba Sasa',
                isLoading: loanProvider.isLoading,
                leadingIcon: HugeIcons.strokeRoundedCreditCard,
                onPressed: (!loanProvider.isLoading && loanProvider.calculation != null) ? _applyNow : null,
              ),
            ).animate().slideY(begin: 1, duration: 300.ms, curve: Curves.easeOut),
          ),
      ],
    );
  }
}

// ── Promotional Banner ────────────────────────────────────────

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D7A6B), Color(0xFF0A5C52)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: 90,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 50,
            bottom: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Text content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 130, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mikopo ya\nKuaminiwa.',
                  style: context.titleLarge.bold.copyWith(color: Colors.white, height: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  'Masharti Wazi',
                  style: context.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),

          // Icon illustration
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF063D36),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(AppRadius.xl),
                  bottomRight: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedMoney01,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 40,
                  ),
                  const SizedBox(height: 6),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedCoins01,
                    color: const Color(0xFF0D7A6B),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product Radio Card (expandable) ──────────────────────────

class _ProductRadioCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  // Expansion props — only meaningful when isSelected = true
  final double amount;
  final bool isCalculating;
  final Map<String, dynamic>? calculation;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _ProductRadioCard({
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.index,
    required this.amount,
    required this.isCalculating,
    required this.calculation,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final minA = (product['minAmount'] as num).toDouble();
    final maxA = (product['maxAmount'] as num).toDouble();
    final maxDays = (product['maxTermDays'] as num?)?.toInt() ?? 30;
    final minDays = (product['minTermDays'] as num?)?.toInt() ?? 7;

    // Header text colours flip when card is selected (dark bg)
    final titleColor = isSelected ? Colors.white : cs.onSurface;
    final labelColor = isSelected ? Colors.white.withValues(alpha: 0.65) : cs.onSurfaceVariant;
    final valueColor = isSelected ? Colors.white : cs.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF0D2456), Color(0xFF1141A8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: isSelected ? null : Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row (always visible) ─────────────────
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kiasi: Tsh ${_fmt(minA)} - Tsh ${_fmt(maxA)}',
                          style: context.titleSmall.copyWith(color: titleColor),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _InfoStat(
                              label: 'Muda wa mkopo',
                              value: minDays == maxDays ? '$maxDays Siku' : '$minDays–$maxDays Siku',
                              labelColor: labelColor,
                              valueColor: valueColor,
                            ),
                            const SizedBox(width: 24),
                            _InfoStat(
                              label: 'Riba kwa mwezi',
                              value: '${((product['monthlyInterestRate'] as num? ?? 0) * 100).toStringAsFixed(1)}%',
                              labelColor: labelColor,
                              valueColor: valueColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : cs.outlineVariant,
                        width: 2,
                      ),
                      color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                  ),
                ],
              ),
            ),
          ),

          // ── Inline expansion (slides open when selected) ─
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
            child: isSelected
                ? _InlineSlider(
                    product: product,
                    amount: amount,
                    isCalculating: isCalculating,
                    calculation: calculation,
                    onChanged: onChanged,
                    onChangeEnd: onChangeEnd,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 80 * index)).fadeIn(duration: 350.ms).slideY(begin: 0.08);
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _InfoStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

  const _InfoStat({
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.labelSmall.copyWith(color: labelColor ?? cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: context.bodyMedium.bold.copyWith(color: valueColor ?? cs.onSurface)),
      ],
    );
  }
}

// ── Inline Slider (inside expanded card) ─────────────────────

class _InlineSlider extends StatelessWidget {
  final Map<String, dynamic> product;
  final double amount;
  final bool isCalculating;
  final Map<String, dynamic>? calculation;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _InlineSlider({
    required this.product,
    required this.amount,
    required this.isCalculating,
    required this.calculation,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final minA = (product['minAmount'] as num).toDouble();
    final maxA = (product['maxAmount'] as num).toDouble();
    final clamped = amount.clamp(minA, maxA);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 16),

          // Amount label + display
          Align(
            alignment: Alignment.center,
            child: Text(
              'Chagua kiasi cha mkopo (Tsh)',
              style: context.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.center,
            child: Text(
              _fmtAmount(clamped),
              style: context.displaySmall.extraBold.copyWith(color: Colors.white, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 10),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: clamped,
              min: minA,
              max: maxA,
              divisions: ((maxA - minA) / 1000).round().clamp(1, 200),
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tsh ${_compact(minA)}', style: context.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.6))),
              Text('Tsh ${_compact(maxA)}', style: context.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.6))),
            ],
          ),

          // Calculation summary
          if (isCalculating) ...[
            const SizedBox(height: 14),
            const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            ),
          ] else if (calculation != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _CalcChip(
                    label: 'Utapata',
                    value: (calculation!['disbursedAmount'] as num).toTZSCompact(),
                  ),
                  _CalcChip(
                    label: 'Kulipa',
                    value: (calculation!['totalRepayable'] as num).toTZSCompact(),
                  ),
                  _CalcChip(
                    label: 'APR',
                    value: '${calculation!['effectiveAprPct']}%',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmtAmount(double v) {
    if (v >= 1000000) {
      return 'TZS ${(v / 1000000).toStringAsFixed(1)}M';
    }
    if (v >= 1000) {
      return 'TZS ${(v / 1000).toStringAsFixed(0)},000';
    }
    return 'TZS ${v.toStringAsFixed(0)}';
  }

  String _compact(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(0)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

class _CalcChip extends StatelessWidget {
  final String label;
  final String value;

  const _CalcChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(label, style: context.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.65))),
          const SizedBox(height: 3),
          Text(value, style: context.bodySmall.bold.copyWith(color: Colors.white)),
        ],
      );
}

// ── Shimmer Skeleton ──────────────────────────────────────────

class _ProductsShimmer extends StatelessWidget {
  const _ProductsShimmer();

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Banner shimmer
          Shimmer.fromColors(
            baseColor: cs.surfaceContainerHighest,
            highlightColor: cs.surfaceContainer,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Cards shimmer
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Shimmer.fromColors(
                baseColor: cs.surfaceContainerHighest,
                highlightColor: cs.surfaceContainer,
                child: Container(
                  height: 88,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: HugeIcons.strokeRoundedWallet01, color: cs.primary, size: 38),
          ),
          const SizedBox(height: 16),
          Text('Hakuna Bidhaa', style: context.titleSmall.copyWith(color: cs.onSurface)),
          const SizedBox(height: 6),
          Text(
            'Bidhaa za mkopo hazipo kwa sasa. Jaribu baadaye.',
            style: context.bodyMedium.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Loan Calculator Screen ────────────────────────────────────

class LoanCalculatorScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const LoanCalculatorScreen({super.key, this.product});

  @override
  State<LoanCalculatorScreen> createState() => _CalcState();
}

class _CalcState extends State<LoanCalculatorScreen> {
  double _amount = 200000;
  double _term = 30;
  Map<String, dynamic>? _prod;

  @override
  void initState() {
    super.initState();
    _prod = widget.product;
    if (_prod != null) {
      _amount = (_prod!['minAmount'] as num).toDouble();
      _term = (_prod!['minTermDays'] as num).toDouble();
      WidgetsBinding.instance.addPostFrameCallback((_) => _calc());
    } else {
      context.stateRead<LoanProvider>().loadProducts().then((_) {
        if (mounted) {
          final prods = context.stateRead<LoanProvider>().products;
          if (prods.isNotEmpty) {
            setState(() {
              _prod = prods.first;
              _amount = (_prod!['minAmount'] as num).toDouble();
              _term = (_prod!['minTermDays'] as num).toDouble();
            });
            _calc();
          }
        }
      });
    }
  }

  void _calc() {
    if (_prod == null) return;
    context.stateRead<LoanProvider>().calculate({
      'productId': _prod!['id'],
      'amount': _amount,
      'termDays': _term.toInt(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.stateWatch<LoanProvider>();
    final minA = _prod != null ? (_prod!['minAmount'] as num).toDouble() : 50000.0;
    final maxA = _prod != null ? (_prod!['maxAmount'] as num).toDouble() : 5000000.0;
    final minT = _prod != null ? (_prod!['minTermDays'] as num).toDouble() : 7.0;
    final maxT = _prod != null ? (_prod!['maxTermDays'] as num).toDouble() : 180.0;

    final cs = context.colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hesabu Mkopo', style: context.titleLarge.copyWith(color: cs.onSurface)),
            Text('Angalia malipo kabla ya kuomba', style: context.bodySmall.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: cs.onSurface, size: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.products.isNotEmpty && widget.product == null) ...[
              Text('Chagua Bidhaa', style: context.titleSmall.copyWith(color: cs.onSurface)),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final p = state.products[i];
                    final sel = _prod?['id'] == p['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _prod = p;
                          _amount = (p['minAmount'] as num).toDouble();
                          _term = (p['minTermDays'] as num).toDouble();
                        });
                        _calc();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel ? cs.primary : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: sel ? cs.primary : cs.outlineVariant,
                          ),
                        ),
                        child: Text(p['name'] ?? '', style: context.labelMedium.copyWith(color: sel ? Colors.white : cs.onSurfaceVariant)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
            _SliderCard(
              label: 'Kiasi cha Mkopo',
              displayValue: _formatTzs(_amount),
              valueColor: cs.primary,
              icon: HugeIcons.strokeRoundedMoney01,
              min: minA,
              max: maxA,
              value: _amount.clamp(minA, maxA),
              divisions: 50,
              minLabel: _compactTzs(minA),
              maxLabel: _compactTzs(maxA),
              onChanged: (v) {
                setState(() => _amount = (v / 1000).round() * 1000.0);
                _calc();
              },
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08),
            const SizedBox(height: 12),
            _SliderCard(
              label: 'Muda wa Mkopo',
              displayValue: '${_term.toInt()} Siku',
              valueColor: const Color(0xFF0D9488),
              icon: HugeIcons.strokeRoundedTime01,
              min: minT,
              max: maxT,
              value: _term.clamp(minT, maxT),
              divisions: ((maxT - minT) / 7).round().clamp(1, 100),
              minLabel: '${minT.toInt()} siku',
              maxLabel: '${maxT.toInt()} siku',
              onChanged: (v) {
                setState(() => _term = (v / 7).round() * 7.0);
                _calc();
              },
            ).animate(delay: 80.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08),
            const SizedBox(height: 16),
            if (state.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: cs.primary, strokeWidth: 2),
                ),
              )
            else if (state.calculation != null) ...[
              _CalcResultCard(result: state.calculation!).animate(delay: 100.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08),
              const SizedBox(height: 20),
              _ApplyButton(
                calc: state.calculation!,
                product: _prod,
                amount: _amount,
                term: _term,
              ).animate(delay: 150.ms).slideY(begin: 0.15, duration: 300.ms),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTzs(double v) {
    if (v >= 1000000) {
      return 'TZS ${(v / 1000000).toStringAsFixed(1)}M';
    }
    if (v >= 1000) return 'TZS ${(v / 1000).toStringAsFixed(0)}K';
    return 'TZS ${v.toStringAsFixed(0)}';
  }

  String _compactTzs(double v) {
    if (v >= 1000000) {
      return '${(v / 1000000).toStringAsFixed(0)}M';
    }
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Slider Card ───────────────────────────────────────────────

class _SliderCard extends StatelessWidget {
  final String label, displayValue, minLabel, maxLabel;
  final Color valueColor;
  final IconData icon;
  final double min, max, value;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderCard({
    required this.label,
    required this.displayValue,
    required this.valueColor,
    required this.icon,
    required this.min,
    required this.max,
    required this.value,
    required this.divisions,
    required this.minLabel,
    required this.maxLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            HugeIcon(icon: icon, color: valueColor, size: 18),
            const SizedBox(width: 8),
            Text(label, style: context.labelMedium.copyWith(color: cs.onSurfaceVariant)),
          ]),
          const SizedBox(height: 10),
          Center(
            child: Text(displayValue, style: context.displayLarge.copyWith(color: valueColor)),
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: valueColor,
              inactiveTrackColor: cs.surfaceContainer,
              thumbColor: valueColor,
              overlayColor: valueColor.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel, style: context.labelSmall.copyWith(color: cs.onSurfaceVariant)),
              Text(maxLabel, style: context.labelSmall.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Calc Result Card ──────────────────────────────────────────

class _CalcResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const _CalcResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final disbursed = (result['disbursedAmount'] as num).toDouble();
    final interest = (result['totalInterest'] as num).toDouble();
    final fee = (result['processingFee'] as num).toDouble();
    final total = (result['totalRepayable'] as num).toDouble();
    final apr = result['effectiveAprPct'];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1141A8), cs.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            ),
            child: Column(
              children: [
                Text('Utapata', style: context.bodySmall.medium.copyWith(color: Colors.white.withValues(alpha: 0.65))),
                const SizedBox(height: 6),
                Text(disbursed.tzs, style: context.displaySmall.extraBold.copyWith(color: Colors.white, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text('kwenye simu yako', style: context.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ResultRow(icon: HugeIcons.strokeRoundedPercentCircle, label: 'Riba', value: interest.tzs, iconColor: cs.tertiary),
                const SizedBox(height: 10),
                _ResultRow(icon: HugeIcons.strokeRoundedMoneyBag01, label: 'Ada ya Usindikaji', value: fee.tzs, iconColor: cs.onSurfaceVariant),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: cs.outlineVariant, height: 1),
                ),
                _ResultRow(
                    icon: HugeIcons.strokeRoundedMoneySend01, label: 'Jumla ya Kulipa', value: total.tzs, iconColor: cs.secondary, isBold: true),
                const SizedBox(height: 10),
                _ResultRow(icon: HugeIcons.strokeRoundedPercentSquare, label: 'APR (mwaka)', value: '$apr%', iconColor: cs.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color iconColor;
  final bool isBold;

  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          child: HugeIcon(icon: icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: context.bodyMedium.copyWith(color: isBold ? cs.onSurface : cs.onSurfaceVariant)),
        ),
        Text(value, style: isBold ? context.titleSmall.copyWith(color: cs.onSurface) : context.labelMedium.copyWith(color: cs.onSurface)),
      ],
    );
  }
}

// ── Apply Button ──────────────────────────────────────────────

class _ApplyButton extends StatelessWidget {
  final Map<String, dynamic> calc;
  final Map<String, dynamic>? product;
  final double amount, term;

  const _ApplyButton({
    required this.calc,
    required this.product,
    required this.amount,
    required this.term,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return GestureDetector(
      onTap: () => context.push(AppRoute.loansApply.path, extra: {
        ...calc,
        'productId': product?['id'],
        'productName': product?['name'] ?? 'Mkopo',
        'amount': amount,
        'termDays': term.toInt(),
      }),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary, const Color(0xFF4F8EFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: AppShadows.button,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(icon: HugeIcons.strokeRoundedCreditCard, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text('Omba Mkopo Huu', style: context.labelLarge.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
