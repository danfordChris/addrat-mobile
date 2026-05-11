import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/features/kyc/component/review_section.dart';
import 'package:pesa_lending/features/kyc/component/submission_sheet.dart';
import 'package:pesa_lending/features/kyc/providers/kyc_provider.dart';
import 'package:pesa_lending/services/database_manager.dart';
import 'package:pesa_lending/shared/shared.dart';

class KycReviewStep extends StatefulWidget {
  const KycReviewStep({super.key});

  @override
  State<KycReviewStep> createState() => _KycReviewStepState();
}

class _KycReviewStepState extends State<KycReviewStep> {
  Map<String, dynamic> _personal = {};
  Map<String, dynamic> _employment = {};
  Map<String, dynamic> _financial = {};

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  void _loadDraft() {
    final draft = DatabaseManager.instance.kycDraft.loadDraft();
    if (draft != null) {
      setState(() {
        if (draft.personalInfoJson != null) {
          _personal = jsonDecode(draft.personalInfoJson!) as Map<String, dynamic>;
        }
        if (draft.employmentInfoJson != null) {
          _employment = jsonDecode(draft.employmentInfoJson!) as Map<String, dynamic>;
        }
        if (draft.financialDetailsJson != null) {
          _financial = jsonDecode(draft.financialDetailsJson!) as Map<String, dynamic>;
        }
      });
    }
  }

  Future<void> _submit(BuildContext context) async {
    bool? confirmed = await ConfirmationSheet.show(
      context,
      title: 'Submit KYC Application',
      message: 'Once submitted, your information will be reviewed. This may take 1-2 business days.',
      confirmLabel: 'Submit',
      cancelLabel: 'Review Again',
    );

    if (confirmed != true || !mounted) return;

    _showSuccessSheet();
  }

  void _showSuccessSheet() {
    showAppBottomSheet<void>(
      context,
      isDismissible: false,
      child: SubmissionSuccessSheet(
        onDone: () {
          context.pop();
          context.go(AppRoute.home.path);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          'Review & Submit',
          style: context.headlineMedium.copyWith(color: context.colorScheme.onSurface),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Please review your details before submitting.',
          style: context.bodyMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: AppSpacing.lg),
        ReviewSection(
          title: 'Taarifa za Kibinafsi',
          icon: HugeIcons.strokeRoundedUser02,
          onEdit: () => context.go(AppRoute.kycPersonal.path),
          tiles: [
            _tile('First Name', _personal['firstName']),
            if (_personal['middleName'] != null) _tile('Middle Name', _personal['middleName']),
            _tile('Last Name', _personal['lastName']),
            _tile('Gender', _personal['gender']),
            _tile('Date of Birth', _personal['dateOfBirth']),
            _tile('Marital Status', _personal['maritalStatus']),
            _tile('NIDA Number', _personal['nidaNumber']),
            _tile('Address', _personal['physicalAddress']),
          ].whereType<Widget>().toList(),
        ).animate().slideY(begin: 0.1, duration: 300.ms, delay: 200.ms),
        const SizedBox(height: AppSpacing.md),
        ReviewSection(
          title: 'Taarifa za Ajira',
          icon: HugeIcons.strokeRoundedOfficeChair,
          onEdit: () => context.go(AppRoute.kycEmployment.path),
          tiles: [
            _tile('Status', _employment['employmentStatus']),
            if (_employment['employerName'] != null) _tile('Employer', _employment['employerName']),
            if (_employment['businessName'] != null) _tile('Business', _employment['businessName']),
            _tile('Dependants', '${_employment['numberOfDependants'] ?? 0}'),
          ].whereType<Widget>().toList(),
        ).animate().slideY(begin: 0.1, duration: 300.ms, delay: 280.ms),
        const SizedBox(height: AppSpacing.md),
        ReviewSection(
          title: 'Taarifa za Fedha',
          icon: HugeIcons.strokeRoundedBank,
          onEdit: () => context.go(AppRoute.kycFinancial.path),
          tiles: [
            _tile('Account Number', _financial['accountNumber']),
            _tile('Source of Income', _financial['sourceOfIncome']),
            _tile('Income Range', _financial['incomeRange']),
          ].whereType<Widget>().toList(),
        ).animate().slideY(begin: 0.1, duration: 300.ms, delay: 360.ms),
        const SizedBox(height: AppSpacing.xl),
        AppPrimaryButton(
          label: 'Submit KYC',
          onPressed: () => _submit(context),
          isLoading: context.stateWatch<KycProvider>().isSubmitting,
        ).animate().slideY(begin: 0.2, duration: 300.ms, delay: 440.ms),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  InfoTile? _tile(String label, dynamic value) {
    if (value == null) return null;
    return InfoTile(label: label, value: value.toString());
  }
}
