import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';
import 'package:pesa_lending/core/theme/app_theme.dart';

class ScanOverlay extends StatelessWidget {
  const ScanOverlay({
    super.key,
    required this.isScanning,
    required this.child,
  });

  final bool isScanning;
  final Widget child;

  static const _aspectRatio = 85.6 / 53.98;

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final width = MediaQuery.of(context).size.width - 48;
    final height = width / _aspectRatio;

    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: cs.primary, width: 2),
          ),
          child: Stack(
            children: [
              _CornerAccents(width: width, height: height),
              if (isScanning)
                _SweepLine(height: height),
            ],
          ),
        ),
      ],
    );
  }
}

class _CornerAccents extends StatelessWidget {
  const _CornerAccents({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    const size = 20.0;
    const thick = 3.0;
    final color = context.colorScheme.primary;
    return Stack(
      children: [
        Positioned(top: 0, left: 0, child: _Corner(size, thick, color, top: true, left: true)),
        Positioned(top: 0, right: 0, child: _Corner(size, thick, color, top: true, left: false)),
        Positioned(bottom: 0, left: 0, child: _Corner(size, thick, color, top: false, left: true)),
        Positioned(bottom: 0, right: 0, child: _Corner(size, thick, color, top: false, left: false)),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner(this.size, this.thick, this.color, {required this.top, required this.left});
  final double size;
  final double thick;
  final Color color;
  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CornerPainter(thick, color, top: top, left: left),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter(this.thick, this.color, {required this.top, required this.left});
  final double thick;
  final Color color;
  final bool top;
  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    canvas.drawLine(Offset(x, y), Offset(left ? size.width : 0, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, top ? size.height : 0), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SweepLine extends StatelessWidget {
  const _SweepLine({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    final primary = context.colorScheme.primary;
    return Positioned.fill(
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, primary.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
      ).animate(onPlay: (c) => c.repeat()).moveY(
            begin: 0,
            end: height - 4,
            duration: 1500.ms,
            curve: Curves.easeInOut,
          ).then().moveY(
            begin: height - 4,
            end: 0,
            duration: 1500.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}
