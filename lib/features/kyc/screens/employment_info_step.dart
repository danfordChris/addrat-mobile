import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/features/kyc/enums/kyc_enums.dart';
import 'package:pesa_lending/features/kyc/providers/kyc_provider.dart';
import 'package:pesa_lending/models/kyc_models.dart';
import 'package:pesa_lending/repositories/kyc_repository.dart';
import 'package:pesa_lending/services/session_manager.dart';
import 'package:pesa_lending/shared/shared.dart';

class EmploymentInfoStep extends StatefulWidget {
  const EmploymentInfoStep({super.key});

  @override
  State<EmploymentInfoStep> createState() => _EmploymentInfoStepState();
}

class _EmploymentInfoStepState extends State<EmploymentInfoStep> {
  final _formKey = GlobalKey<FormState>();

  final _employerNameCtrl = TextEditingController();
  final _employerAddressCtrl = TextEditingController();
  final _tinCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _businessTinCtrl = TextEditingController();
  final _businessRegCtrl = TextEditingController();

  EmploymentStatus _employmentStatus = EmploymentStatus.employed;
  int _dependants = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _employerNameCtrl.dispose();
    _employerAddressCtrl.dispose();
    _tinCtrl.dispose();
    _businessNameCtrl.dispose();
    _businessTinCtrl.dispose();
    _businessRegCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    try {
      final result = await KycRepository.instance.getStatus();
      result.fold(
        (status) {
          if (mounted && status.completedSteps.contains(1)) {
            _loadEmploymentInfo();
          }
        },
        (_, __) {},
      );
    } catch (_) {}
  }

  Future<void> _loadEmploymentInfo() async {
    try {
      final result = await KycRepository.instance.getProfile();
      result.fold(
        (profile) {
          if (mounted) {
            setState(() {
              if (profile['employmentStatus'] != null) {
                _employmentStatus = EmploymentStatus.fromString(profile['employmentStatus']) ?? EmploymentStatus.employed;
              }
              if (profile['employerName'] != null) {
                _employerNameCtrl.text = profile['employerName'].toString();
              }
              if (profile['employerAddress'] != null) {
                _employerAddressCtrl.text = profile['employerAddress'].toString();
              }
              if (profile['tinNumber'] != null) {
                _tinCtrl.text = profile['tinNumber'].toString();
              }
              if (profile['businessName'] != null) {
                _businessNameCtrl.text = profile['businessName'].toString();
              }
              if (profile['businessTinNumber'] != null) {
                _businessTinCtrl.text = profile['businessTinNumber'].toString();
              }
              if (profile['businessRegistrationNumber'] != null) {
                _businessRegCtrl.text = profile['businessRegistrationNumber'].toString();
              }
              if (profile['numberOfDependents'] != null) {
                _dependants = (profile['numberOfDependents'] is int)
                    ? profile['numberOfDependents'] as int
                    : int.tryParse(profile['numberOfDependents'].toString()) ?? 0;
              }
            });
          }
        },
        (_, __) {},
      );
    } catch (_) {}
  }

  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final isEmployed = _employmentStatus == EmploymentStatus.employed;
      final isSelfEmployed = _employmentStatus == EmploymentStatus.selfEmployed;

      String? nonEmpty(String v) => v.trim().isEmpty ? null : v.trim();

      final dto = EmploymentInfoDto(
        employmentStatus: _employmentStatus.value,
        employerName: isEmployed ? nonEmpty(_employerNameCtrl.text) : null,
        employerAddress: isEmployed ? nonEmpty(_employerAddressCtrl.text) : null,
        tinNumber: isEmployed ? nonEmpty(_tinCtrl.text) : null,
        businessName: isSelfEmployed ? nonEmpty(_businessNameCtrl.text) : null,
        businessTinNumber: isSelfEmployed ? nonEmpty(_businessTinCtrl.text) : null,
        businessRegistrationNumber: isSelfEmployed ? nonEmpty(_businessRegCtrl.text) : null,
        numberOfDependants: _dependants,
      );

      await context.stateRead<KycProvider>().saveEmploymentInfo(dto);
      if (mounted) context.go(AppRoute.kycFinancial.path);
    } catch (e, s) {
      AppUtility.log('Error saving employment info stackTrace: $s');
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
            'Employment Details',
            style: context.headlineMedium.copyWith(color: context.colorScheme.onSurface),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tell us about your employment status.',
            style: context.bodyMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: AppSpacing.lg),
          SegmentedControl<EmploymentStatus>(
            options: EmploymentStatus.values.map((s) => SegmentOption(value: s, label: s.label)).toList(),
            selected: _employmentStatus,
            onChanged: (v) => setState(() => _employmentStatus = v),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: AppSpacing.lg),
          if (_employmentStatus == EmploymentStatus.employed) ...[
            AppTextField(
              label: 'Employer Name',
              controller: _employerNameCtrl,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Employer Address',
              controller: _employerAddressCtrl,
              maxLines: 2,
            ).animate().fadeIn(delay: 280.ms),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'TIN Number (optional)',
              controller: _tinCtrl,
              keyboardType: TextInputType.number,
            ).animate().fadeIn(delay: 310.ms),
          ] else if (_employmentStatus == EmploymentStatus.selfEmployed) ...[
            AppTextField(
              label: 'Business Name',
              controller: _businessNameCtrl,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Business TIN Number (optional)',
              controller: _businessTinCtrl,
              keyboardType: TextInputType.number,
            ).animate().fadeIn(delay: 280.ms),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Business Registration Number (optional)',
              controller: _businessRegCtrl,
            ).animate().fadeIn(delay: 310.ms),
          ] else ...[
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedInformationCircle, color: context.colorScheme.tertiary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'You can still apply for a loan based on other income sources.',
                      style: context.bodySmall.copyWith(color: context.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 250.ms),
          ],
          const SizedBox(height: AppSpacing.lg),
          _DependantsCounter(
            value: _dependants,
            onChanged: (v) => setState(() => _dependants = v),
          ).animate().fadeIn(delay: 350.ms),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            label: 'Next',
            onPressed: _onNext,
            isLoading: context.stateWatch<KycProvider>().isLoading,
          ).animate().slideY(begin: 0.2, duration: 300.ms, delay: 400.ms),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _DependantsCounter extends StatelessWidget {
  const _DependantsCounter({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Number of Dependants', style: context.bodyMedium.copyWith(color: context.colorScheme.onSurface)),
          Row(
            children: [
              AppIconButton(
                icon: HugeIcons.strokeRoundedMinusSign,
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
                size: 36,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  '$value',
                  style: context.titleLarge.copyWith(color: context.colorScheme.onSurface),
                ),
              ),
              AppIconButton(
                icon: HugeIcons.strokeRoundedPlusSign,
                onPressed: value < 20 ? () => onChanged(value + 1) : null,
                size: 36,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
