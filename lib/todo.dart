import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:timezone/timezone.dart' as tz;
import 'todo_grid_view.dart';
import 'todo_information_popup.dart';

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  @override
  _TodoHomePageState createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  List<TodoItem> todos = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _addTodo() {
    setState(() {
      final newTodo = TodoItem(
        id: todos.length + 1,
        title: 'New Todo',
        description: 'Description',
      );
      todos.add(newTodo);
    });
  }

  void _editTodoDialog(int todoIndex, String selectedTodo) {
    final List<String> todoParts = selectedTodo.split(",");
    titleController.text = todoParts[1];
    descriptionController.text = todoParts[2];

    showDialog(
      context: context,
      builder: (context) {
        return TodoInformationPopup(
          titleController: titleController,
          descriptionController: descriptionController,
          onSave: (title, description, dateTime) {
            setState(() {
              todos[todoIndex] = TodoItem(
                id: todos[todoIndex].id,
                title: title,
                description: description,
              );
              titleController.clear();
              descriptionController.clear();
            });
          },
        );
      },
    );
  }

  void _editTodo(int index) {
    final selectedTodo = todos[index].toString();
    _editTodoDialog(index, selectedTodo);
  }

  void _deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: TodoGridView(
        todos: todos.map((todo) => todo.toString()).toList(),
        onTodoClick: _editTodo,
        onDelete: _deleteTodo,
        todoList: todos.map((todo) => todo.toString()).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoItem {
  final int id;
  final String title;
  final String description;

  TodoItem({
    required this.id,
    required this.title,
    required this.description,
  });

  @override
  String toString() {
    return 'TodoItem($id,$title,$description)';
  }
}
