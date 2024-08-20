import 'dart:convert';
import 'package:charm/brain.dart';
import 'package:charm/habit.dart';
import 'package:charm/home_page.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitTrackerPage extends StatefulWidget {
  @override
  _HabitTrackerPageState createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> {
  List<Habit> habits = [];
  DateTime focusedDay = DateTime.now(); // Keep track of the focused day

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _onDateSelected(DateTime date, Habit habit) {
    if (date.isAfter(DateTime.now())) {
      // Do nothing if the selected date is in the future
      return;
    }

    setState(() {
      if (habit.completedDates.contains(date)) {
        habit.completedDates.remove(date);
      } else {
        habit.completedDates.add(date);
      }
      focusedDay = date; // Update the focused day
      _saveHabits(); // Save the updated habit list
    });
  }

  void _saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> habitStrings =
        habits.map((habit) => jsonEncode(habit.toJson())).toList();
    await prefs.setStringList('habits', habitStrings);
  }

  void _loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? habitStrings = prefs.getStringList('habits');
    if (habitStrings != null) {
      habits = habitStrings.map((habitString) {
        Map<String, dynamic> json = jsonDecode(habitString);
        return Habit.fromJson(json);
      }).toList();
      setState(() {}); // Update the UI after loading habits
    }
  }

  void _addHabit(String habitName) {
    if (habitName.isNotEmpty) {
      setState(() {
        Habit newHabit = Habit(name: habitName, completedDates: {});
        habits.add(newHabit);
        _saveHabits();
      });
    }
  }

  void _deleteHabit(Habit habit) {
    setState(() {
      habits.remove(habit);
      _saveHabits();
    });
  }

  // Modify the PieChart data to reflect only the days within the selected month
  List<PieChartSectionData> showingSections(Habit habit, DateTime month) {
    // Get the last day to consider for this month (either today or the last day of the month)
    DateTime lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    DateTime lastRelevantDay = DateTime.now().isBefore(lastDayOfMonth)
        ? DateTime.now()
        : lastDayOfMonth;

    // Filter completed dates to only include those before or on the last relevant day
    final completedInMonth = habit.completedDates
        .where((date) =>
            date.month == month.month &&
            date.year == month.year &&
            date.isBefore(lastRelevantDay.add(const Duration(days: 1))))
        .toList();

    int completed = completedInMonth.length;
    int totalDaysInMonthSoFar = lastRelevantDay.day;

    double completedPercentage = (completed / totalDaysInMonthSoFar) * 100;
    double incompletePercentage = 100 - completedPercentage;

    return [
      PieChartSectionData(
        color: Colors.green,
        value: completedPercentage,
        title: '${completedPercentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: incompletePercentage,
        title: '${incompletePercentage.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Habit Tracker',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.purple,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book, // User logo
                        color: Colors.white,
                        size: 30.0,
                      ),
                      SizedBox(width: 8.0), // Space between the icon and text
                      Text(
                        'Charm Diary',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyHomePage(
                          title: 'Charm Diary',
                        )),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Habit Tracker'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HabitTrackerPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lightbulb_outline_rounded),
            title: const Text('Brain Dump'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BPage()),
              );
            },
          ),
        ]),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ...habits.map((habit) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          habit.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.purple,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteHabit(habit);
                          },
                        ),
                      ),
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: focusedDay,
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: '',
                        },
                        selectedDayPredicate: (day) {
                          // Only highlight the selected dates
                          return habit.completedDates.contains(day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          _onDateSelected(selectedDay, habit);
                          setState(() {
                            this.focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            this.focusedDay = focusedDay;
                          });
                        },
                        enabledDayPredicate: (day) {
                          return !day.isAfter(DateTime.now());
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Colors.purple, // Color for selected date
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: const TextStyle(
                            color: Colors
                                .black, // Ensure default text color is black
                          ),
                          todayTextStyle: TextStyle(
                            color: habits.any((habit) => habit.completedDates
                                    .contains(DateTime.now()))
                                ? Colors.black
                                : Colors
                                    .black, // Show today's text in black if not selected
                            fontWeight: FontWeight.bold,
                          ),
                          selectedTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('${habit.name} Progress'),
                              content: SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections:
                                        showingSections(habit, focusedDay),
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 2,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text('Show Progress'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController habitController = TextEditingController();
              return AlertDialog(
                title: const Text('Add New Habit'),
                content: TextField(
                  controller: habitController,
                  decoration:
                      const InputDecoration(hintText: 'Enter habit name'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _addHabit(habitController.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
