import 'package:flutter/material.dart';
import '../../../../../core/utils/responsive.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: context.fontSize(16),
          ),
    );
  }
}