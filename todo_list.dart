import 'package:flutter/material.dart';
import '../../models/todo.dart';
import 'todo_item.dart';
import 'empty_state.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final bool isLoading;
  final String? emptyMessage;
  final VoidCallback? onRefresh;
  final Function(int todoId)? onToggleComplete;
  final Function(Todo todo)? onEdit;
  final Function(Todo todo)? onDelete;

  const TodoList({
    super.key,
    required this.todos,
    this.isLoading = false,
    this.emptyMessage,
    this.onRefresh,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (todos.isEmpty) {
      return EmptyState(
        message: emptyMessage ?? 'No todos found',
        onActionPressed: onRefresh,
        actionText: onRefresh != null ? 'Refresh' : null,
      );
    }

    Widget listView = ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(
          todo: todo,
          onToggleComplete: onToggleComplete != null 
              ? () => onToggleComplete!(todo.id!)
              : null,
          onEdit: onEdit != null 
              ? () => onEdit!(todo)
              : null,
          onDelete: onDelete != null 
              ? () => onDelete!(todo)
              : null,
        );
      },
    );

    // Wrap with RefreshIndicator if onRefresh is provided
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async {
          onRefresh!();
        },
        child: listView,
      );
    }

    return listView;
  }
}