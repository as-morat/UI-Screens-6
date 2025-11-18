import 'package:learn_local_db/models/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String table = "tasks";
  final String colId = "id";
  final String colContent = "content";
  final String colStatus = "status";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dir = await getDatabasesPath();
    final path = join(dir, "master_db.db");

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE $table (
            $colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colContent TEXT NOT NULL,
            $colStatus INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> addTask(String content) async {
    final db = await database;
    await db.insert(table, {colContent: content, colStatus: 0});
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(table);

    return data
        .map(
          (e) => Task(
            id: e[colId] as int,
            content: e[colContent] as String,
            status: e[colStatus] as int,
          ),
        )
        .toList();
  }

  Future<void> updateTaskStatus(int id, int newStatus) async {
    final db = await database;
    await db.update(
      table,
      {colStatus: newStatus},
      where: "$colId = ?",
      whereArgs: [id],
    );
  }

  Future<void> editTaskContent(int id, String newContent) async {
    final db = await database;
    await db.update(
      table,
      {colContent: newContent},
      where: "$colId = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(table, where: "$colId = ?", whereArgs: [id]);
  }

  Future<void> deleteAllTasks() async {
    final db = await database;
    await db.delete(table);
  }
}
