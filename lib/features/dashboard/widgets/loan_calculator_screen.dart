import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/features/dashboard/widgets/apply_bitton.dart';
import 'package:pesa_lending/features/dashboard/widgets/calc_result_card.dart';
import 'package:pesa_lending/features/dashboard/widgets/slider_card.dart';
import 'package:pesa_lending/features/loans/providers/loan_provider.dart';

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
            SliderCard(
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
            SliderCard(
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
              CalcResultCard(result: state.calculation!).animate(delay: 100.ms).fadeIn(duration: 350.ms).slideY(begin: 0.08),
              const SizedBox(height: 20),
              ApplyButton(
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
