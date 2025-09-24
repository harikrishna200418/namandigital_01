import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../repositories/todo_repository.dart';

class TodoViewModel extends ChangeNotifier {
  final TodoRepository _repository = TodoRepository();
  
  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TodoFilter _currentFilter = TodoFilter.all;
  
  // Getters
  List<Todo> get todos => _filteredTodos;
  List<Todo> get filteredTodos => _filteredTodos;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TodoFilter get currentFilter => _currentFilter;
  bool get isEmpty => _filteredTodos.isEmpty;
  
  // Statistics
  int get totalCount => _todos.length;
  int get completedCount => _todos.where((todo) => todo.isCompleted).length;
  int get pendingCount => _todos.where((todo) => !todo.isCompleted).length;

  // Initialize and load todos
  Future<void> loadTodos() async {
    _setLoading(true);
    try {
      _todos = await _repository.getAllTodos();
      debugPrint('Loaded ${_todos.length} todos from database');
      _applyFilters();
      debugPrint('After filtering: ${_filteredTodos.length} todos visible');
    } catch (e) {
      debugPrint('Error loading todos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new todo
  Future<void> addTodo(String title, {String description = ''}) async {
    if (title.trim().isEmpty) return;
    
    _setLoading(true);
    try {
      final newTodo = Todo(
        title: title.trim(),
        description: description.trim(),
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final createdTodo = await _repository.createTodo(newTodo);
      debugPrint('Todo created with ID: ${createdTodo.id}');
      
      // Reload all todos from database to ensure consistency
      await loadTodos();
    } catch (e) {
      debugPrint('Error adding todo: $e');
      _setLoading(false);
    }
  }

  // Update a todo
  Future<void> updateTodo(Todo todo) async {
    _setLoading(true);
    try {
      await _repository.updateTodo(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo;
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Error updating todo: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete a todo
  Future<void> deleteTodo(int id) async {
    _setLoading(true);
    try {
      await _repository.deleteTodo(id);
      _todos.removeWhere((todo) => todo.id == id);
      _applyFilters();
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle todo completion
  Future<void> toggleTodoCompletion(Todo todo) async {
    try {
      await _repository.toggleTodoCompletion(todo);
      final index = _todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        _todos[index] = todo.copyWith(
          isCompleted: !todo.isCompleted,
          updatedAt: DateTime.now(),
        );
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Error toggling todo completion: $e');
    }
  }

  // Delete all completed todos
  Future<void> deleteCompletedTodos() async {
    _setLoading(true);
    try {
      await _repository.deleteCompletedTodos();
      _todos.removeWhere((todo) => todo.isCompleted);
      _applyFilters();
    } catch (e) {
      debugPrint('Error deleting completed todos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search todos
  void searchTodos(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
  }

  // Set filter
  void setFilter(TodoFilter filter) {
    _currentFilter = filter;
    _applyFilters();
  }

  // Apply filters and search
  void _applyFilters() {
    List<Todo> filtered = List.from(_todos);
    debugPrint('Starting with ${filtered.length} todos');

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((todo) =>
        todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        todo.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
      debugPrint('After search filter: ${filtered.length} todos');
    }

    // Apply completion filter
    switch (_currentFilter) {
      case TodoFilter.pending:
        filtered = filtered.where((todo) => !todo.isCompleted).toList();
        debugPrint('After pending filter: ${filtered.length} todos');
        break;
      case TodoFilter.completed:
        filtered = filtered.where((todo) => todo.isCompleted).toList();
        debugPrint('After completed filter: ${filtered.length} todos');
        break;
      case TodoFilter.all:
        debugPrint('No filter applied: ${filtered.length} todos');
        break;
    }

    _filteredTodos = filtered;
    debugPrint('Final filtered todos: ${_filteredTodos.length}');
    notifyListeners(); // Notify UI of changes
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

enum TodoFilter { all, pending, completed }