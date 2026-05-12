import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/features/kyc/component/kyc_header.dart';
import 'package:pesa_lending/features/kyc/enums/kyc_enums.dart';
import 'package:pesa_lending/features/kyc/providers/kyc_provider.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/shared/components/misc/step_progress_bar.dart';


class KycScreen extends StatefulWidget {
  const KycScreen({super.key});
  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.stateRead<KycProvider>().initiateKyc());
  }

  @override
  Widget build(BuildContext context) {
    final kycProvider = context.stateWatch<KycProvider>();

    if (kycProvider.isReadOnly) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              KycHeader(
                onBack: () => context.pop(),
                title: 'KYC Verification',
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Icon(
                        Icons.check_circle,
                        size: 64,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'KYC Verified',
                        style: context.headlineMedium.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Your KYC has been verified and approved. You can now proceed with loan applications.',
                        style: context.bodyMedium.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (kycProvider.approvedKycData != null)
                        _buildApprovedKycView(context, kycProvider.approvedKycData!),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            KycHeader(
              onBack: () => context.pop(),
              title: 'KYC Verification',
            ),
             StepProgressBar(steps: KycStepScreens.values.length, currentStep: kycProvider.currentStep.stepNumber)
                .animate()
                .fadeIn(duration: 300.ms),



Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Material(
                  type: MaterialType.transparency,
                  child: kycProvider.widget,
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _buildApprovedKycView(BuildContext context, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoSection('Personal Information', [
          _infoPair('Full Name', data['fullName']),
          _infoPair('Date of Birth', data['dateOfBirth']),
          _infoPair('Gender', data['gender']),
          _infoPair('Marital Status', data['maritalStatus']),
          _infoPair('NIDA Number', data['idNumber']),
          _infoPair('Address', data['residenceAddress']),
        ]),
        const SizedBox(height: AppSpacing.lg),
        _buildInfoSection('Employment Information', [
          _infoPair('Employment Status', data['employmentStatus']),
          if (data['employerName'] != null) _infoPair('Employer', data['employerName']),
          if (data['businessName'] != null) _infoPair('Business', data['businessName']),
          if (data['numberOfDependents'] != null) _infoPair('Dependents', data['numberOfDependents'].toString()),
        ]),
        const SizedBox(height: AppSpacing.lg),
        _buildInfoSection('Financial Information', [
          _infoPair('Income Source', data['incomeSource']),
          _infoPair('Income Range', data['incomeRange']),
        ]),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...items,
      ],
    );
  }

  Widget _infoPair(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
