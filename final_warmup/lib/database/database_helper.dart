import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

/// Database helper class for managing Task CRUD operations
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  /// Get or create database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database and create table
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  /// Create tasks table
  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        completedAt TEXT
      )
    ''');
  }

  /// CREATE: Insert a new task
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  /// READ: Get all tasks
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// READ: Get tasks by completion status
  Future<List<Task>> getTasksByStatus(bool isCompleted) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [isCompleted ? 1 : 0],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  /// READ: Get task by id
  Future<Task?> getTaskById(int id) async {
    final db = await database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  /// UPDATE: Update a task
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// UPDATE: Toggle task completion status
  Future<int> toggleTaskStatus(int id, bool isCompleted) async {
    final db = await database;
    return await db.update(
      'tasks',
      {
        'isCompleted': isCompleted ? 1 : 0,
        'completedAt': isCompleted ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// DELETE: Delete a task
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// DELETE: Delete all completed tasks
  Future<int> deleteCompletedTasks() async {
    final db = await database;
    return await db.delete('tasks', where: 'isCompleted = ?', whereArgs: [1]);
  }

  /// Get task count
  Future<int> getTaskCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tasks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get completed task count
  Future<int> getCompletedTaskCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE isCompleted = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Close database
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
