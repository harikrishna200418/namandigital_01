import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../core/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    // Initialize database factory for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER NOT NULL DEFAULT 0';

    await db.execute('''
      CREATE TABLE ${AppConstants.todoTable} (
        ${AppConstants.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${AppConstants.columnTitle} $textType,
        ${AppConstants.columnDescription} TEXT,
        ${AppConstants.columnIsCompleted} $boolType,
        ${AppConstants.columnCreatedAt} $integerType,
        ${AppConstants.columnUpdatedAt} $integerType
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    // For now, we'll just recreate the table
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.todoTable}');
      await _createDB(db, newVersion);
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // Reset database (useful for testing)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}