import 'package:flutter/material.dart';
import '../../../../../core/utils/date_helper.dart';
import '../../../../core/utils/responsive.dart';

class HabitsSectionHeader extends StatelessWidget {
  const HabitsSectionHeader({super.key, required this.date});

  final DateTime date;

  String get _title {
    final today = DateHelper.normalize(DateTime.now());
    return date.isAtSameMomentAs(today)
        ? "Today's Habits"
        : DateHelper.formatRelative(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.pagePadding,
        context.spacing(20),
        context.pagePadding,
        context.spacing(12),
      ),
      child: Text(
        _title,
        style: TextStyle(
          fontSize: context.fontSize(20),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
