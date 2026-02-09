import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get db async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bmi.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tbUsers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT,
        pwd TEXT,
        weight REAL,
        height REAL,
        bmi REAL,
        bmi_type TEXT
      )
    ''');
  }

  // -------- CRUD --------
  Future<int> insertUser(User user) async {
    final database = await db;
    return await database.insert('tbUsers', user.toMap());
  }

  Future<List<User>> getUsers() async {
    final database = await db;
    final maps = await database.query('tbUsers');
    return maps.map((e) => User.fromMap(e)).toList();
  }
  Future<int> updateUser(User user) async {
  final database = await db;
  return database.update(
    'tbUsers',
    user.toMap(),
    where: 'id = ?',
    whereArgs: [user.id],
  );
}

  Future<int> deleteUser(int id) async {
    final database = await db;
    return await database.delete(
      'tbUsers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllUsers() async {
    final database = await db;
    await database.delete('tbUsers');
  }
}
