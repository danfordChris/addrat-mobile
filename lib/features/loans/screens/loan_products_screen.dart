import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/features/dashboard/widgets/empty_products.dart';
import 'package:pesa_lending/features/dashboard/widgets/product_radio_card.dart';
import 'package:pesa_lending/features/dashboard/widgets/product_shrimmer.dart';
import 'package:pesa_lending/features/dashboard/widgets/promo_banner.dart';
import 'package:pesa_lending/features/loans/providers/loan_provider.dart';
import 'package:pesa_lending/shared/shared.dart';

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
          ? const ProductsShimmer()
          : loanProvider.products.isEmpty
              ? const EmptyProducts()
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
                child: const PromoBanner().animate().fadeIn(duration: 400.ms),
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
                    return ProductRadioCard(
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
