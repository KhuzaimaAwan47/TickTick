import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/task_model.dart';
import '../model/user_model.dart';

class DatabaseHelper{
  final databaseName = "todo.db";

  //Tables


  String user = '''
   CREATE TABLE users (
   usrId INTEGER PRIMARY KEY AUTOINCREMENT,
   fullName TEXT,
   usrName TEXT UNIQUE,
   usrPassword TEXT
   )
   ''';

  String task = '''
    CREATE TABLE tasks (
      id TEXT PRIMARY KEY,
      usrId INTEGER,
      date TEXT,
      title TEXT,
      description TEXT,
      FOREIGN KEY (usrId) REFERENCES users(usrId)
    )
    )
  ''';

  //Create a connection to the database
  Future<Database> initDB ()async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path,version: 1 , onCreate: (db,version)async{
      await db.execute(user);
      await db.execute(task);
    });
  }

  //Function

  //Authentication
  Future<bool> authenticate(Users usr)async{
    final Database db = await initDB();
    var result = await db.rawQuery("select * from users where usrName = '${usr.usrName}' AND usrPassword = '${usr.password}' ");
    if(result.isNotEmpty){
      return true;
    }else{
      return false;
    }
  }

  //Sign up
  Future<int> createUser(Users usr)async{
    final Database db = await initDB();
    return db.insert("users", usr.toMap());
  }


  //Get current User details
  Future<Users?> getUser(String usrName)async{
    final Database db = await initDB();
    var res = await db.query("users",where: "usrName = ?", whereArgs: [usrName]);
    return res.isNotEmpty? Users.fromMap(res.first):null;
  }

  Future<Users?> getUserById(int usrId) async {
    final Database db = await initDB();
    var res = await db.query("users", where: "usrId = ?", whereArgs: [usrId]);
    return res.isNotEmpty ? Users.fromMap(res.first) : null;
  }

  // save a task
  Future<int> insertTask(Task task) async {
    final Database db = await initDB();
    return db.insert("tasks", task.toMap());
  }

  // update a task
  Future<int> updateTask(Task task) async {
    final Database db = await initDB();
    return await db.update("tasks", task.toMap(), where: "id = ?", whereArgs: [task.id]);
  }

  // Remove a task by its id
  Future<int> removeTask(String id) async {
    final Database db = await initDB();
    return db.delete("tasks", where: "id = ?", whereArgs: [id]);
  }

  // Retrieve all tasks
  Future<List<Task>> getTask(int usrId) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query(
      "tasks",
      where: "usrId = ?",
      whereArgs: [usrId],
    );

    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'] as String,
        usrId: maps[i]['usrId'] is int
            ? maps[i]['usrId']
            : int.parse(maps[i]['usrId'].toString()),
        date: maps[i]['date'] as String,
        title: maps[i]['title' ]as String,
        description: maps[i]['description'] as String,
      );
    });
  }



}