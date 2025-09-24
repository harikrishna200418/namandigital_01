import 'package:flutter/material.dart';
import '../../models/todo.dart';
import '../../core/utils.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: todo.isCompleted,
                onChanged: onToggleComplete != null ? (_) => onToggleComplete!() : null,
              ),
              const SizedBox(width: 12),
              
              // Todo content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        color: todo.isCompleted 
                            ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                            : null,
                      ),
                    ),
                    if (todo.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        todo.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                          color: todo.isCompleted 
                              ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                              : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Utils.formatDate(todo.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (todo.isCompleted) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                    case 'toggle':
                      onToggleComplete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          todo.isCompleted ? Icons.undo : Icons.check,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(todo.isCompleted ? 'Mark Pending' : 'Mark Complete'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}