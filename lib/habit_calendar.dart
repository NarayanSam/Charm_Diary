// lib/widgets/habit_tile.dart
import 'package:charm/habit.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final Function(DateTime) onDateSelected;

  const HabitTile({
    Key? key,
    required this.habit,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          habit.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TableCalendar(
          focusedDay: DateTime.now(),
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) {
            return habit.isCompleted(day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            onDateSelected(selectedDay);
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
