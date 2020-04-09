import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String tableTodo = 'todo';
final String columnId = '_id';
final String columnTitle = "title";
final String columnDone = 'done';

class Todo {
  int id;
  String title;
  bool done;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: title,
      columnDone: done == true ? 1 : 0
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Todo();

  Todo.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    title = map[columnTitle];
    done = map[columnDone] == 1 ? true : false;
  }
}

class DatabaseHelper {
  static final _databaseName = "todo_knight.db";
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
    version: _databaseVersion,
    onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableTodo (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnTitle TEXT NOT NULL,
      $columnDone INTEGER)
    ''');
  }

  Future<int> insert(Todo todo) async {
    Database db = await database;
    int id = await db.insert(tableTodo, todo.toMap());
    return id;
  }

  Future<Todo> getTodo(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableTodo,
    columns: [columnId, columnDone, columnTitle],
    where: '$columnId = ?',
    whereArgs: [id]);
    if (maps.length > 0) {
      return Todo.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Todo>> getAllTodo() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableTodo);

    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete(tableTodo, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Todo todo) async {
    Database db = await database;
    return await db.update(tableTodo, todo.toMap(),
      where: '$columnId = ?', whereArgs: [todo.id]);
  }
}