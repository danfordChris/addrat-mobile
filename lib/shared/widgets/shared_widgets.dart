import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

// ── Primary Button ────────────────────────────────────────────

class PesaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;

  const PesaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? cs.primary,
      ),
      child: isLoading
          ? const SizedBox(height: 22, width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white)))
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ]),
    );
  }
}

// ── Custom Text Field ─────────────────────────────────────────

class PesaTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final void Function(String)? onChanged;
  final int? maxLength;
  final bool readOnly;

  const PesaTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.maxLength,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      maxLength: maxLength,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        counterText: '',
      ),
    );
  }
}

// ── Amount Card ───────────────────────────────────────────────

class AmountCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color? bgColor;
  final Color? textColor;
  final IconData? icon;

  const AmountCard({
    super.key,
    required this.title,
    required this.amount,
    this.bgColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final effectiveText = textColor ?? cs.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor ?? cs.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: effectiveText),
            const SizedBox(width: 6),
          ],
          Text(title,
              style: context.labelSmall.medium.copyWith(
                color: textColor?.withValues(alpha: 0.75) ?? cs.onSurfaceVariant,
              )),
        ]),
        const SizedBox(height: 6),
        Text(amount,
            style: context.titleLarge.bold.copyWith(color: effectiveText)),
      ]),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final config = _resolveConfig(status.toUpperCase(), cs);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: config.bg, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Text(config.label,
        style: context.labelSmall.bold.copyWith(color: config.text)),
    );
  }

  static ({Color bg, Color text, String label}) _resolveConfig(String key, ColorScheme cs) {
    return switch (key) {
      'ACTIVE'      => (bg: cs.secondaryContainer,       text: cs.secondary,          label: 'Inatumika'),
      'APPROVED'    => (bg: cs.secondaryContainer,       text: cs.secondary,          label: 'Imeidhinishwa'),
      'PENDING'     => (bg: cs.tertiaryContainer,        text: cs.tertiary,           label: 'Inasubiri'),
      'OVERDUE'     => (bg: cs.errorContainer,           text: cs.error,              label: 'Imechelewa'),
      'REJECTED'    => (bg: cs.errorContainer,           text: cs.error,              label: 'Imekataliwa'),
      'CLOSED'      => (bg: cs.primaryContainer,         text: cs.primary,            label: 'Imefungwa'),
      'NOT_STARTED' => (bg: cs.surfaceContainerHighest,  text: cs.onSurfaceVariant,   label: 'Haijanza'),
      _             => (bg: cs.surfaceContainerHighest,  text: cs.onSurfaceVariant,   label: key),
    };
  }
}

// ── Animated Shimmer ──────────────────────────────────────────

class ShimmerBox extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = AppRadius.md,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final base  = cs.surfaceContainer;
    final shine = cs.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value, 0),
            colors: [base, shine, base],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }
}

// ── Loading Overlay ───────────────────────────────────────────

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    return Stack(children: [
      child,
      if (isLoading)
        Container(
          color: Colors.black26,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: cs.primary, strokeWidth: 2.5),
                const SizedBox(height: 16),
                Text('Tafadhali subiri...',
                  style: context.bodyMedium.medium.copyWith(color: cs.onSurfaceVariant)),
              ]),
            ),
          ),
        ),
    ]);
  }
}

// ── Currency Formatter ────────────────────────────────────────

extension CurrencyFormat on num {
  String get tzs {
    final f = NumberFormat('#,##0', 'en_US');
    return 'TZS ${f.format(this)}';
  }
}

// ── Snackbars ─────────────────────────────────────────────────

void showError(BuildContext context, String message) {
  final cs = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Text(message)),
    ]),
    backgroundColor: cs.error,
    behavior: SnackBarBehavior.floating,
  ));
}

void showSuccess(BuildContext context, String message) {
  final cs = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Text(message)),
    ]),
    backgroundColor: cs.secondary,
    behavior: SnackBarBehavior.floating,
  ));
}
