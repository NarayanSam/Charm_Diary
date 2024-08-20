// lib/widgets/progress_pie_chart.dart
import 'package:charm/habit.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressPieChart extends StatelessWidget {
  final Habit habit;
  final DateTime month;

  const ProgressPieChart({
    Key? key,
    required this.habit,
    required this.month,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalDays = DateTime(month.year, month.month + 1, 0).day;
    final completedDays = habit.completedDates
        .where((date) => date.month == month.month && date.year == month.year)
        .length;

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: completedDays.toDouble(),
            title: '$completedDays/$totalDays',
          ),
          PieChartSectionData(
            color: Colors.red,
            value: (totalDays - completedDays).toDouble(),
            title: '${totalDays - completedDays}/$totalDays',
          ),
        ],
        centerSpaceRadius: 40,
        borderData: FlBorderData(show: false),
        sectionsSpace: 0,
      ),
    );
  }
}
