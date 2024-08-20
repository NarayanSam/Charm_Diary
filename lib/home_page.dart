import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'horizontal_day_daylist.dart';
import 'todo_grid_view.dart';
import 'todo_information_popup.dart';
import 'brain.dart';
import 'package:charm/habit_tracker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<String> dayDependentTodos = [];
  List<int> dayDependentTodosIndices = [];
  List<String> todoInformation = [];
  String weekday = "";

  @override
  void initState() {
    super.initState();
    _initializeCurrentDay();
    _loadTodos();
  }

  void _initializeCurrentDay() {
    final now = DateTime.now();
    // Get the current weekday (1 = Monday, 7 = Sunday)
    switch (now.weekday) {
      case DateTime.monday:
        weekday = "Mon";
        break;
      case DateTime.tuesday:
        weekday = "Tue";
        break;
      case DateTime.wednesday:
        weekday = "Wed";
        break;
      case DateTime.thursday:
        weekday = "Thu";
        break;
      case DateTime.friday:
        weekday = "Fri";
        break;
      case DateTime.saturday:
        weekday = "Sat";
        break;
      case DateTime.sunday:
        weekday = "Sun";
        break;
    }
  }

  void _loadTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      todoInformation = prefs.getStringList('todoInformation') ?? [];
      _updateList();
    });
  }

  void _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('todoInformation', todoInformation);
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      value,
      style: const TextStyle(
          fontWeight: FontWeight.bold, fontSize: 20, color: Colors.redAccent),
    )));
  }

  void changeWeekday(String newDay) {
    setState(() {
      weekday = newDay;
    });
    print("changed, $weekday");

    _updateList();
  }

  void _updateList() {
    dayDependentTodos.clear();
    dayDependentTodosIndices.clear(); // Clear the indices list
    for (int i = 0; i < todoInformation.length; i++) {
      String todo = todoInformation[i];
      if (todo.split(",")[0] == weekday) {
        dayDependentTodos.add(todo);
        dayDependentTodosIndices
            .add(i); // Store the index of the todo in the original list
      }
    }
  }

  void _editTodoDialog(int todoIndex, String selectedTodo) {
    final List<String> todoParts = selectedTodo.split(",");
    TextEditingController titleController =
        TextEditingController(text: todoParts[1]);
    TextEditingController descriptionController =
        TextEditingController(text: todoParts[2]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Update the todo item with new values
                  todoInformation[todoIndex] =
                      "${todoParts[0]},${titleController.text},${descriptionController.text}";
                  _updateList(); // Update the todo list
                  _saveTodos(); // Save changes
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _onSave() {
    if (descriptionController.text.isEmpty || titleController.text.isEmpty) {
      showInSnackBar("Title or description can't be empty!");
    } else {
      setState(() {
        todoInformation.add(
            "$weekday,${titleController.text},${descriptionController.text}");
        _updateList();
        _saveTodos();
        titleController.clear();
        descriptionController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.title,
            style: const TextStyle(
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
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          HorizontalDayList(
            dayUpdateFunction: changeWeekday,
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Color(0xFFFCF5FF),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  boxShadow: [BoxShadow(blurRadius: 10.0)]),
              child: TodoGridView(
                todoList: dayDependentTodos,
                onDelete: (index) {
                  setState(() {
                    int todoIndex = dayDependentTodosIndices[index];
                    todoInformation.removeAt(todoIndex);
                    _updateList();
                    _saveTodos();
                  });
                },
                todos: todoInformation,
                onTodoClick: (int index) {
                  final selectedTodo = todoInformation[index];
                  _editTodoDialog(index, selectedTodo);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return TodoInformationPopup(
                  titleController: titleController,
                  descriptionController: descriptionController,
                  onSave: _onSave,
                );
              });
        },
        splashColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        backgroundColor: Colors.purple,
        child: const Icon(
          Icons.add,
          size: 50,
        ),
      ),
    );
  }
}
