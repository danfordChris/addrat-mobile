import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:pesa_lending/core/utils/nid_extractor.dart';
import 'package:pesa_lending/shared/components/buttons/app_primary_button.dart';
import 'package:pesa_lending/shared/components/buttons/app_secondary_button.dart';
import 'package:pesa_lending/shared/components/feedback/app_snackbar.dart';

class NidScanSheet extends StatefulWidget {
  const NidScanSheet({
    super.key,
    required this.controller,
    this.onScanned,
  });

  final CameraController controller;
  final ValueChanged<NidData>? onScanned;

  @override
  State<NidScanSheet> createState() => _NidScanSheetState();
}

class _NidScanSheetState extends State<NidScanSheet> {
  bool _isScanning = false;

  void _cancelScan() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _processCapture() async {
    setState(() => _isScanning = true);

    try {
      final image = await widget.controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await recognizer.processImage(inputImage);
      await recognizer.close();

      final lines = result.blocks
          .expand((b) => b.lines.map((l) => l.text))
          .toList();

      final data = NidExtractor.extract(lines);
      if (!mounted) return;
      if (data != null) {
        widget.onScanned?.call(data);
        AppSnackbar.success('ID scanned successfully');
        Navigator.of(context).pop(data);
      } else {
        AppSnackbar.error('Could not read ID — please fill manually');
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error('Scan failed — please fill manually');
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Position your ID card in the frame',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: CameraPreview(widget.controller),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: AppSecondaryButton(
                    label: 'Cancel',
                    onPressed:_cancelScan,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppPrimaryButton(
                    label: 'Capture',
                    onPressed: _isScanning ? null : _processCapture,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
