import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/router/router.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/core/utils/nid_extractor.dart';
import 'package:pesa_lending/features/kyc/component/nid_scan.dart';
import 'package:pesa_lending/features/kyc/enums/kyc_enums.dart';
import 'package:pesa_lending/features/kyc/providers/kyc_provider.dart';
import 'package:pesa_lending/models/kyc_models.dart';
import 'package:pesa_lending/services/session_manager.dart';
import 'package:pesa_lending/shared/shared.dart';

class PersonalInfoStep extends StatefulWidget {
  const PersonalInfoStep({super.key});

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _middleNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _nidaCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  Gender? _gender;
  String? _dateOfBirth;
  MaritalStatus? _maritalStatus;

  bool _isScanning = false;
  bool _genderLocked = false;
  bool _dobLocked = false;

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _nidaCtrl.dispose();
    _addressCtrl.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _loadCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      // Camera not available — scan button will be disabled
      SessionManager.showError(e);
    }
  }

  Future<void> _startScan() async {
    if (_cameras == null || _cameras!.isEmpty) {
      AppSnackbar.error('Camera not available');
      return;
    }

    try {
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _isScanning = true);

      final data = await showModalBottomSheet<NidData>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => NidScanSheet(controller: _cameraController!),
      );

      if (!mounted || data == null) return;
      setState(() {
        if (data.firstName != null) _firstNameCtrl.text = data.firstName!;
        if (data.middleName != null) _middleNameCtrl.text = data.middleName!;
        if (data.lastName != null) _lastNameCtrl.text = data.lastName!;
        if (data.physicalAddress != null) _addressCtrl.text = data.physicalAddress!;

        final parsedGender = Gender.fromString(data.gender);
        if (parsedGender != null) {
          _gender = parsedGender;
          _genderLocked = true;
        }
        if (data.dateOfBirth != null) {
          _dateOfBirth = data.dateOfBirth;
          _dobLocked = true;
        }
      });
    } catch (_) {
      if (mounted) AppSnackbar.error('Failed to start camera');
    } finally {
      await _cameraController?.dispose();
      _cameraController = null;
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_gender == null) {
        AppSnackbar.error('Please select gender');
        return;
      }
      if (_dateOfBirth == null) {
        AppSnackbar.error('Please select date of birth');
        return;
      }
      if (_maritalStatus == null) {
        AppSnackbar.error('Please select marital status');
        return;
      }

      PersonalInfoDto dto = PersonalInfoDto(
        firstName: _firstNameCtrl.text.trim(),
        middleName: _middleNameCtrl.text.trim().isEmpty ? null : _middleNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        gender: _gender!.value,
        dateOfBirth: _dateOfBirth!,
        maritalStatus: _maritalStatus!.value,
        nidaNumber: _nidaCtrl.text.trim(),
        physicalAddress: _addressCtrl.text.trim(),
      );

      await context.stateRead<KycProvider>().savePersonalInfo(dto);

      if (mounted) context.go(AppRoute.kycEmployment.path);
    } catch (e, s) {
      AppUtility.log('Error saving personal info stackTrace: $s');
      if (mounted) SessionManager.showError(e);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
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
            'Personal Information',
            style: context.headlineMedium.copyWith(color: context.colorScheme.onSurface),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Scan your National ID or fill in manually.',
            style: context.bodyMedium.copyWith(color: context.colorScheme.onSurfaceVariant),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: AppSpacing.lg),
          ScanOverlay(
            isScanning: _isScanning,
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(Icons.credit_card_outlined, size: 48, color: context.colorScheme.primary),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Scan National ID',
                    style: context.bodyMedium.copyWith(color: context.colorScheme.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Auto-fills your details',
                    style: context.bodySmall.copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppSecondaryButton(
                    label: _isScanning ? 'Scanning…' : 'Scan ID Card',
                    onPressed: _isScanning ? null : _startScan,
                  ),
                ],
              ),
            ),
          ).animate().slideY(begin: 0.1, duration: 300.ms, delay: 200.ms),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'First Name',
            controller: _firstNameCtrl,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ).animate().fadeIn(delay: 250.ms),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Middle Name (optional)',
            controller: _middleNameCtrl,
          ).animate().fadeIn(delay: 280.ms),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Last Name',
            controller: _lastNameCtrl,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ).animate().fadeIn(delay: 310.ms),
          const SizedBox(height: AppSpacing.md),
          if (_genderLocked && _gender != null)
            InfoTile(
              label: 'Gender',
              value: _gender!.label,
              isLocked: true,
            ).animate().fadeIn(delay: 330.ms)
          else
            AppDropdownField<Gender>(
              label: 'Gender',
              hint: 'Select gender',
              value: _gender,
              items: Gender.values.map((g) => DropdownItem(value: g, label: g.label)).toList(),
              onChanged: (v) => setState(() => _gender = v),
            ).animate().fadeIn(delay: 330.ms),
          const SizedBox(height: AppSpacing.md),
          if (_dobLocked && _dateOfBirth != null)
            InfoTile(
              label: 'Date of Birth',
              value: _dateOfBirth!,
              isLocked: true,
            ).animate().fadeIn(delay: 350.ms)
          else
            AppTextField(
              label: 'Date of Birth',
              hint: 'YYYY-MM-DD',
              controller: TextEditingController(text: _dateOfBirth ?? ''),
              readOnly: true,
              onTap: _pickDate,
              validator: (_) => _dateOfBirth == null ? 'Required' : null,
            ).animate().fadeIn(delay: 350.ms),
          const SizedBox(height: AppSpacing.md),
          AppDropdownField<MaritalStatus>(
            label: 'Marital Status',
            hint: 'Select status',
            value: _maritalStatus,
            items: MaritalStatus.values.map((s) => DropdownItem(value: s, label: s.label)).toList(),
            onChanged: (v) => setState(() => _maritalStatus = v),
          ).animate().fadeIn(delay: 370.ms),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'NIDA Number',
            controller: _nidaCtrl,
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ).animate().fadeIn(delay: 390.ms),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Physical Address',
            controller: _addressCtrl,
            maxLines: 2,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ).animate().fadeIn(delay: 410.ms),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            label: 'Next',
            onPressed: _onNext,
            isLoading: context.stateWatch<KycProvider>().isLoading,
          ).animate().slideY(begin: 0.2, duration: 300.ms, delay: 430.ms),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
