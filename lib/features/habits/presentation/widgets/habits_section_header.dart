import 'package:flutter/material.dart';
import '../../../../../core/utils/date_helper.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        _title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}