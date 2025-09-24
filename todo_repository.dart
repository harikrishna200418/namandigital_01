import '../models/todo.dart';
import '../data/todo_dao.dart';

class TodoRepository {
  final TodoDao _todoDao = TodoDao();

  // Create a new todo
  Future<Todo> createTodo(Todo todo) async {
    return await _todoDao.create(todo);
  }

  // Get all todos
  Future<List<Todo>> getAllTodos() async {
    return await _todoDao.readAllTodos();
  }

  // Get a specific todo by id
  Future<Todo?> getTodoById(int id) async {
    return await _todoDao.readTodo(id);
  }

  // Get completed todos
  Future<List<Todo>> getCompletedTodos() async {
    return await _todoDao.readCompletedTodos();
  }

  // Get pending todos
  Future<List<Todo>> getPendingTodos() async {
    return await _todoDao.readPendingTodos();
  }

  // Update a todo
  Future<void> updateTodo(Todo todo) async {
    await _todoDao.update(todo);
  }

  // Delete a todo
  Future<void> deleteTodo(int id) async {
    await _todoDao.delete(id);
  }

  // Delete all completed todos
  Future<void> deleteCompletedTodos() async {
    await _todoDao.deleteCompletedTodos();
  }

  // Toggle todo completion status
  Future<void> toggleTodoCompletion(Todo todo) async {
    final updatedTodo = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );
    await _todoDao.update(updatedTodo);
  }

  // Get statistics
  Future<Map<String, int>> getStatistics() async {
    final total = await _todoDao.getTotalCount();
    final completed = await _todoDao.getCompletedCount();
    final pending = await _todoDao.getPendingCount();
    
    return {
      'total': total,
      'completed': completed,
      'pending': pending,
    };
  }

  // Search todos
  Future<List<Todo>> searchTodos(String query) async {
    if (query.trim().isEmpty) {
      return await getAllTodos();
    }
    return await _todoDao.searchTodos(query.trim());
  }
}