import 'package:flutter/cupertino.dart';
import 'package:pesa_lending/features/kyc/enums/kyc_enums.dart';
import 'package:pesa_lending/features/kyc/screens/employment_info_step.dart';
import 'package:pesa_lending/features/kyc/screens/financial_details_step.dart';
import 'package:pesa_lending/features/kyc/screens/kyc_review_step.dart';
import 'package:pesa_lending/features/kyc/screens/personal_info_step.dart';
import 'package:pesa_lending/models/kyc_models.dart';
import 'package:pesa_lending/repositories/kyc_repository.dart';
import 'package:pesa_lending/services/database_manager.dart';
import 'package:pesa_lending/services/session_manager.dart';
import 'package:pesa_lending/shared/enums/kyc_status_enum.dart';
import 'package:pesa_lending/shared/providers/base_provider.dart';

enum KycStep { notStarted, inProgress, complete, rejected }

class KycProvider extends BaseProvider {
  KycStep _step = KycStep.notStarted;

  KycStep get step => _step;

  KycStepScreens _currentStep = KycStepScreens.personalInfo;

  KycStepScreens get currentStep => _currentStep;

  bool get isComplete => _step == KycStep.complete;

  bool get isInProgress => _step == KycStep.inProgress;

  bool? _isLoading;

  bool get isLoading => _isLoading ?? false;

  bool? _isSubmitting;

  bool get isSubmitting => _isSubmitting ?? false;

  Widget get widget => _getCurrentStepWidget;

  Future<void> initiateKyc() async {
    _setLoading(true);
    try {
      final draft = DatabaseManager.instance.kycDraft.loadDraft();
      setInProgress(KycStepScreens.fromStep(draft?.step) ?? KycStepScreens.financialInfo);
    } catch (e) {
      SessionManager.handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> savePersonalInfo(PersonalInfoDto personalInfo) async {
    _setLoading(true);
    try {
      await KycRepository.instance.savePersonalInfo(personalInfo);
      setInProgress(KycStepScreens.employmentInfo);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveEmploymentInfo(EmploymentInfoDto employmentData) async {
    _setLoading(true);
    try {
      await KycRepository.instance.saveEmploymentInfo(employmentData);
      setInProgress(KycStepScreens.financialInfo);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveFinancialInfo(FinancialDetailsDto financialData) async {
    _setLoading(true);
    try {
      await KycRepository.instance.saveFinancialDetails(financialData);
      setInProgress(KycStepScreens.kycReview);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeKyc() async {
    _setIsSubmitting(true);
    try {
      await KycRepository.instance.submit();
      setInProgress(KycStepScreens.kycReview);
    } catch (e) {
      rethrow;
    } finally {
      _setIsSubmitting(false);
    }
  }

  Widget get _getCurrentStepWidget {
    switch (_currentStep) {
      case KycStepScreens.personalInfo:
        return const PersonalInfoStep();
      case KycStepScreens.employmentInfo:
        return const EmploymentInfoStep();
      case KycStepScreens.financialInfo:
        return const FinancialDetailsStep();
      case KycStepScreens.kycReview:
        return const KycReviewStep();
    }
  }

  void _setIsSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setNotStarted() {
    _step = KycStep.notStarted;
    notifyListeners();
  }

  void setInProgress(KycStepScreens step) {
    // _step = KycStep.inProgress;
    _currentStep = step;
    notifyListeners();
  }

  void setComplete() {
    _step = KycStep.complete;
    notifyListeners();
  }

  void setRejected() {
    _step = KycStep.rejected;
    notifyListeners();
  }

  void initFromStatus(String? status) {
    _step = switch (KycStatus.fromString(status)) {
      KycStatus.approved => KycStep.complete,
      KycStatus.rejected => KycStep.rejected,
      KycStatus.pending => KycStep.inProgress,
      KycStatus.notStarted => KycStep.notStarted,
    };
    notifyListeners();
  }
}
