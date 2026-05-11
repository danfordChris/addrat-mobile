import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/features/kyc/enums/kyc_enums.dart';
import 'package:pesa_lending/features/kyc/providers/kyc_provider.dart';
import 'package:pesa_lending/models/kyc_models.dart';
import 'package:pesa_lending/models/reference_models.dart';
import 'package:pesa_lending/repositories/kyc_repository.dart';
import 'package:pesa_lending/repositories/reference_repository.dart';
import 'package:pesa_lending/services/database_manager.dart';
import 'package:pesa_lending/services/session_manager.dart';
import 'package:pesa_lending/shared/shared.dart';

class FinancialDetailsStep extends StatefulWidget {
  const FinancialDetailsStep({super.key});

  @override
  State<FinancialDetailsStep> createState() => _FinancialDetailsStepState();
}

class _FinancialDetailsStepState extends State<FinancialDetailsStep> {
  final _formKey = GlobalKey<FormState>();
  final _accountCtrl = TextEditingController();

  List<BankModel> _banks = [];
  List<BranchModel> _branches = [];

  BankModel? _selectedBank;
  BranchModel? _selectedBranch;
  IncomeSource? _sourceOfIncome;
  String? _incomeRange;

  bool _isLoadingBanks = true;
  bool _isLoadingBranches = false;

  static const _incomeRanges = [
    '0 - 500,000',
    '500,001 - 1,000,000',
    '1,000,001 - 3,000,000',
    '3,000,001 - 5,000,000',
    '5,000,001+',
  ];

  @override
  void initState() {
    super.initState();
    _loadBanks();
    _loadSavedData();
  }

  @override
  void dispose() {
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    try {
      final result = await KycRepository.instance.getStatus();
      result.fold(
        (status) {
          if (mounted && status.completedSteps.contains(2)) {
            _loadFinancialDetails();
          }
        },
        (_, __) {},
      );
    } catch (_) {}
  }

  Future<void> _loadFinancialDetails() async {
    try {
      final result = await KycRepository.instance.getProfile();
      result.fold(
        (profile) async {
          if (mounted) {
            setState(() {
              if (profile['accountNumber'] != null) {
                _accountCtrl.text = profile['accountNumber'].toString();
              }
              if (profile['incomeSource'] != null) {
                _sourceOfIncome = IncomeSource.fromString(profile['incomeSource']);
              }
              if (profile['incomeRange'] != null) {
                _incomeRange = profile['incomeRange'].toString();
              }
            });

            if (profile['bankId'] != null) {
              final bankId = (profile['bankId'] is int) ? profile['bankId'] as int : int.tryParse(profile['bankId'].toString()) ?? 0;
              if (bankId > 0) {
                try {
                  _selectedBank = _banks.firstWhere((b) => b.id == bankId);
                  if (_selectedBank != null) {
                    await _loadBranches(_selectedBank!.id);
                    if (mounted && profile['branchId'] != null) {
                      final branchId = (profile['branchId'] is int) ? profile['branchId'] as int : int.tryParse(profile['branchId'].toString()) ?? 0;
                      if (branchId > 0) {
                        try {
                          setState(() {
                            _selectedBranch = _branches.firstWhere((b) => b.id == branchId);
                          });
                        } catch (_) {
                          _selectedBranch = null;
                        }
                      }
                    }
                  }
                } catch (_) {
                  _selectedBank = null;
                }
              }
            }
          }
        },
        (_, __) {},
      );
    } catch (_) {}
  }

  Future<void> _loadBanks() async {
    final cached = DatabaseManager.instance.bankCache.getCachedBanks();
    if (cached != null) {
      setState(() {
        _banks = cached.map((b) => BankModel(id: b.id, name: b.name, code: b.code)).toList();
        _isLoadingBanks = false;
      });
      return;
    }

    final result = await ReferenceRepository.instance.getBanks();
    if (!mounted) return;

    result.fold(
      (banks) async {
        await DatabaseManager.instance.bankCache.saveBanks(banks);
        setState(() {
          _banks = banks;
          _isLoadingBanks = false;
        });
      },
      (msg, _) {
        setState(() => _isLoadingBanks = false);
        AppSnackbar.error(msg);
      },
    );
  }

  Future<void> _loadBranches(int bankId) async {
    setState(() {
      _isLoadingBranches = true;
      _selectedBranch = null;
      _branches = [];
    });
    final result = await ReferenceRepository.instance.getBranches(bankId);
    if (!mounted) return;
    result.fold(
      (branches) => setState(() {
        _branches = branches;
        _isLoadingBranches = false;
      }),
      (msg, _) {
        setState(() => _isLoadingBranches = false);
        AppSnackbar.error(msg);
      },
    );
  }

  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_selectedBank == null) {
        AppSnackbar.error('Please select a bank');
        return;
      }
      if (_selectedBranch == null) {
        AppSnackbar.error('Please select a branch');
        return;
      }
      if (_sourceOfIncome == null) {
        AppSnackbar.error('Please select source of income');
        return;
      }
      if (_incomeRange == null) {
        AppSnackbar.error('Please select income range');
        return;
      }

      final dto = FinancialDetailsDto(
        bankId: _selectedBank!.id,
        branchId: _selectedBranch!.id,
        accountNumber: _accountCtrl.text.trim(),
        sourceOfIncome: _sourceOfIncome!.value,
        incomeRange: _incomeRange!,
      );

      await context.stateRead<KycProvider>().saveFinancialInfo(dto);
      if (mounted) context.go(AppRoute.kycReview.path);
    } catch (e, s) {
      AppUtility.log('Error saving financial info stackTrace: $s');
      if (mounted) SessionManager.showError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            'Financial Details',
            style: context.headlineMedium.copyWith(color: context.colorScheme.onSurface),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your bank account details for disbursement.',
            style: context.bodyMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: AppSpacing.lg),
          if (_isLoadingBanks)
            Center(
              child: CircularProgressIndicator(color: context.colorScheme.primary),
            )
          else ...[
            AppSearchableDropdown<BankModel>(
              label: 'Bank',
              hint: 'Search and select bank',
              value: _selectedBank,
              items: _banks.map((b) => DropdownItem(value: b, label: b.name)).toList(),
              onChanged: (b) {
                setState(() => _selectedBank = b);
                if (b != null) _loadBranches(b.id);
              },
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.md),
            if (_isLoadingBranches)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Center(
                  child: CircularProgressIndicator(color: context.colorScheme.primary),
                ),
              )
            else
              AppDropdownField<BranchModel>(
                label: 'Branch',
                hint: _selectedBank == null ? 'Select a bank first' : 'Select branch',
                value: _selectedBranch,
                enabled: _selectedBank != null && _branches.isNotEmpty,
                items: _branches.map((b) => DropdownItem(value: b, label: b.name)).toList(),
                onChanged: (b) => setState(() => _selectedBranch = b),
              ).animate().fadeIn(delay: 250.ms),
          ],
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Account Number',
            controller: _accountCtrl,
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Income Information',
            style: context.bodyLarge.copyWith(color: context.colorScheme.onSurface),
          ).animate().fadeIn(delay: 330.ms),
          const SizedBox(height: AppSpacing.md),
          ...IncomeSource.values.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: RadioOptionTile<IncomeSource>(
                  value: s,
                  groupValue: _sourceOfIncome,
                  label: s.label,
                  onChanged: (v) => setState(() => _sourceOfIncome = v),
                ),
              )),
          const SizedBox(height: AppSpacing.lg),
          AppDropdownField<String>(
            label: 'Monthly Income Range (TZS)',
            hint: 'Select income range',
            value: _incomeRange,
            items: _incomeRanges.map((r) => DropdownItem(value: r, label: r)).toList(),
            onChanged: (v) => setState(() => _incomeRange = v),
          ).animate().fadeIn(delay: 450.ms),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            label: 'Next',
            onPressed: _onNext,
            isLoading: context.stateWatch<KycProvider>().isLoading,
          ).animate().slideY(begin: 0.2, duration: 300.ms, delay: 500.ms),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
