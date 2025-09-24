import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../viewmodels/todo_viewmodel.dart';
import '../core/utils.dart';
import 'add_edit_todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoViewModel>().loadTodos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          PopupMenuButton<TodoFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              context.read<TodoViewModel>().setFilter(filter);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: TodoFilter.all,
                child: Text('All'),
              ),
              const PopupMenuItem(
                value: TodoFilter.pending,
                child: Text('Pending'),
              ),
              const PopupMenuItem(
                value: TodoFilter.completed,
                child: Text('Completed'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsCard(),
          Expanded(child: _buildTodoList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search todos...',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (query) {
          context.read<TodoViewModel>().searchTodos(query);
        },
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<TodoViewModel>(
      builder: (context, viewModel, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', viewModel.totalCount, Colors.blue),
                _buildStatItem('Pending', viewModel.pendingCount, Colors.orange),
                _buildStatItem('Completed', viewModel.completedCount, Colors.green),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTodoList() {
    return Consumer<TodoViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.filteredTodos.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: viewModel.filteredTodos.length,
          itemBuilder: (context, index) {
            final todo = viewModel.filteredTodos[index];
            return _buildTodoItem(todo);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No todos found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new todo to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            context.read<TodoViewModel>().toggleTodoCompletion(todo);
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: todo.isCompleted
                ? Colors.grey[600]
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                todo.description,
                style: TextStyle(
                  color: todo.isCompleted
                      ? Colors.grey[500]
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Created: ${Utils.formatDate(todo.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleTodoAction(action, todo),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _navigateToAddEditScreen(todo: todo),
      ),
    );
  }

  void _handleTodoAction(String action, Todo todo) {
    switch (action) {
      case 'edit':
        _navigateToAddEditScreen(todo: todo);
        break;
      case 'delete':
        _showDeleteConfirmation(todo);
        break;
    }
  }

  void _showDeleteConfirmation(Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TodoViewModel>().deleteTodo(todo.id!);
              Utils.showSnackBar(context, 'Todo deleted successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddEditScreen({Todo? todo}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTodoScreen(todo: todo),
      ),
    );
    // Refresh the todo list when returning from add/edit screen
    if (mounted) {
      context.read<TodoViewModel>().loadTodos();
    }
  }
}