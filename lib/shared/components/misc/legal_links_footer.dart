import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

class LegalLinksFooter extends StatelessWidget {
  const LegalLinksFooter({
    super.key,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Text.rich(
      TextSpan(
        style: context.bodySmall.copyWith(color: cs.onSurfaceVariant),
        children: [
          const TextSpan(text: 'By continuing you agree to our '),
          TextSpan(
            text: 'Terms & Conditions',
            style: context.bodySmall.medium.copyWith(
              color: cs.primary,
              decoration: TextDecoration.underline,
              decorationColor: cs.primary,
            ),
            recognizer: TapGestureRecognizer()..onTap = onTermsTap,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: context.bodySmall.medium.copyWith(
              color: cs.primary,
              decoration: TextDecoration.underline,
              decorationColor: cs.primary,
            ),
            recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
