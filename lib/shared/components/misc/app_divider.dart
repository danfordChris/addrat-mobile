import 'package:flutter/material.dart';
import 'package:ipf_flutter_starter_pack/ipf_flutter_starter_pack.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.height = 1, this.color, this.indent});

  final double height;
  final Color? color;
  final double? indent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height + 16,
      thickness: height,
      color: color ?? context.colorScheme.outlineVariant,
      indent: indent,
      endIndent: indent,
    );
  }
}
