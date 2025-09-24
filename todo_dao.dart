import 'package:sqflite/sqflite.dart';
import '../models/todo.dart';
import '../core/constants.dart';
import 'database_helper.dart';

class TodoDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Create a new todo
  Future<Todo> create(Todo todo) async {
    final db = await _databaseHelper.database;
    final id = await db.insert(AppConstants.todoTable, todo.toMap());
    return todo.copyWith(id: id);
  }

  // Read a todo by id
  Future<Todo?> readTodo(int id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      AppConstants.todoTable,
      where: '${AppConstants.columnId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Read all todos
  Future<List<Todo>> readAllTodos() async {
    final db = await _databaseHelper.database;
    const orderBy = '${AppConstants.columnCreatedAt} DESC';
    final result = await db.query(AppConstants.todoTable, orderBy: orderBy);

    return result.map((json) => Todo.fromMap(json)).toList();
  }

  // Read completed todos
  Future<List<Todo>> readCompletedTodos() async {
    final db = await _databaseHelper.database;
    const orderBy = '${AppConstants.columnUpdatedAt} DESC';
    final result = await db.query(
      AppConstants.todoTable,
      where: '${AppConstants.columnIsCompleted} = ?',
      whereArgs: [1],
      orderBy: orderBy,
    );

    return result.map((json) => Todo.fromMap(json)).toList();
  }

  // Read pending todos
  Future<List<Todo>> readPendingTodos() async {
    final db = await _databaseHelper.database;
    const orderBy = '${AppConstants.columnCreatedAt} DESC';
    final result = await db.query(
      AppConstants.todoTable,
      where: '${AppConstants.columnIsCompleted} = ?',
      whereArgs: [0],
      orderBy: orderBy,
    );

    return result.map((json) => Todo.fromMap(json)).toList();
  }

  // Update a todo
  Future<int> update(Todo todo) async {
    final db = await _databaseHelper.database;
    return db.update(
      AppConstants.todoTable,
      todo.toMap(),
      where: '${AppConstants.columnId} = ?',
      whereArgs: [todo.id],
    );
  }

  // Delete a todo
  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      AppConstants.todoTable,
      where: '${AppConstants.columnId} = ?',
      whereArgs: [id],
    );
  }

  // Delete all completed todos
  Future<int> deleteCompletedTodos() async {
    final db = await _databaseHelper.database;
    return await db.delete(
      AppConstants.todoTable,
      where: '${AppConstants.columnIsCompleted} = ?',
      whereArgs: [1],
    );
  }

  // Get total count of todos
  Future<int> getTotalCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.todoTable}');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get completed count
  Future<int> getCompletedCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${AppConstants.todoTable} WHERE ${AppConstants.columnIsCompleted} = ?',
      [1],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get pending count
  Future<int> getPendingCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${AppConstants.todoTable} WHERE ${AppConstants.columnIsCompleted} = ?',
      [0],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Search todos by title
  Future<List<Todo>> searchTodos(String query) async {
    final db = await _databaseHelper.database;
    const orderBy = '${AppConstants.columnCreatedAt} DESC';
    final result = await db.query(
      AppConstants.todoTable,
      where: '${AppConstants.columnTitle} LIKE ? OR ${AppConstants.columnDescription} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: orderBy,
    );

    return result.map((json) => Todo.fromMap(json)).toList();
  }
}