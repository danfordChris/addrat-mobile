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
}
