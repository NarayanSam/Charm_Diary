import 'package:flutter/material.dart';
import 'todo_tile.dart';

class TodoGridView extends StatelessWidget {
  final List<String> todoList;
  final Function(int) onDelete;

  const TodoGridView(
      {Key? key,
      required this.todoList,
      required this.onDelete,
      required List<String> todos,
      required void Function(int index) onTodoClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: todoList.length,
      itemBuilder: (context, index) {
        final todo = todoList[index].split(',');
        final title = todo[1];
        final description = todo[2];
        return TodoTile(
          title: title,
          description: description,
          onDelete: () => onDelete(index),
        );
      },
    );
  }
}
