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
    print("Database location: $path");

    return await openDatabase(path, version: 1, onCreate: _onCreate);
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

  // ==================== CRUD OPERATIONS ====================

  // ==================== C - CREATE ====================
  /// บันทึกข้อมูลผู้ใช้ใหม่ลงฐานข้อมูล
  /// - ใช้ user.toMap() แปลง User object เป็น Map
  /// - ส่งข้อมูล BMI และ BMI Type ไปบันทึกด้วย
  Future<int> insertUser(User user) async {
    final database = await db;
    return await database.insert('tbUsers', user.toMap());
  }

  // ==================== R - READ ====================
  /// ดึงข้อมูลผู้ใช้ทั้งหมดจากฐานข้อมูล
  /// - ใช้ User.fromMap() แปลง Map เป็น User object
  /// - คืนค่าเป็น List<User>
  Future<List<User>> getUsers() async {
    final database = await db;
    final maps = await database.query('tbUsers');
    return maps.map((e) => User.fromMap(e)).toList();
  }

  // ==================== U - UPDATE ====================
  /// อัปเดตข้อมูลผู้ใช้ในฐานข้อมูล
  /// - ใช้ user.toMap() แปลง User object เป็น Map ที่มี BMI ใหม่
  /// - อัปเดตตามค่า id
  Future<int> updateUser(User user) async {
    final database = await db;
    return database.update(
      'tbUsers',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ==================== D - DELETE ====================
  /// ลบข้อมูลผู้ใช้แต่ละคนตามค่า id
  Future<int> deleteUser(int id) async {
    final database = await db;
    return await database.delete('tbUsers', where: 'id = ?', whereArgs: [id]);
  }

  /// ลบข้อมูลผู้ใช้ทั้งหมดในฐานข้อมูล
  Future<void> deleteAllUsers() async {
    final database = await db;
    await database.delete('tbUsers');
  }
}
