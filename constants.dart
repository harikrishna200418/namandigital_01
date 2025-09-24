class AppConstants {
  static const String appName = 'Todo App';
  static const String databaseName = 'todo_database.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String todoTable = 'todos';
  
  // Column names
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnDescription = 'description';
  static const String columnIsCompleted = 'is_completed';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;
}