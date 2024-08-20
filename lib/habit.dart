//class Habit {
//  final String name;
//  final List<DateTime> _completionDates = [];
//
//  Habit({required this.name});
//
//  List<DateTime> get completionDates => List.unmodifiable(_completionDates);
//
//  void markComplete(DateTime date) {
//    if (!_completionDates.contains(date)) {
//      _completionDates.add(date);
//    }
//  }
//
//  bool isCompleted(DateTime date) {
//    return _completionDates.contains(date);
//  }
//
//  double getCompletionPercentage(DateTime month) {
//    final firstDayOfMonth = DateTime(month.year, month.month, 1);
//    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
//
//    final totalDays = lastDayOfMonth.day;
//    final completedDays = _completionDates
//        .where((date) => date.month == month.month && date.year == month.year)
//        .length;
//
//    return (completedDays / totalDays) * 100;
//  }
//}
//

class Habit {
  final String name;
  final Set<DateTime> completedDates; // Using Set to avoid duplicate dates

  Habit({
    required this.name,
    required this.completedDates,
  });

  // Converting the habit to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'completedDates':
          completedDates.map((date) => date.toIso8601String()).toList(),
    };
  }

  // Creating a habit from JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      name: json['name'],
      completedDates: (json['completedDates'] as List)
          .map((date) => DateTime.parse(date))
          .toSet(),
    );
  }
  void markComplete(DateTime date) {
    if (!completedDates.contains(date)) {
      completedDates.add(date);
    }
  }

  bool isCompleted(DateTime date) {
    return completedDates.contains(date);
  }

  double getCompletionPercentage(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final totalDays = lastDayOfMonth.day;
    final completedDays = completedDates
        .where((date) => date.month == month.month && date.year == month.year)
        .length;

    return (completedDays / totalDays) * 100;
  }
}
