import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  int? id;
  String username;
  String password;
  List<String> friends; //List of usernames or ids of friends, probably id.

  User(this.id, this.username, this.password, this.friends);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'friends': jsonEncode(friends),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      map['id'],
      map['username'],
      map['password'],
      List<String>.from(jsonDecode(map['friends'])),
    );
  }
}

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();
  static Database? _database;

  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase('user.db');
    return _database!;
  }

  Future<Database> _initializeDatabase(String filename) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, filename);
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        friends TEXT NOT NULL DEFAULT '[]'
        );   
        ''');
  }

  Future<void> insertUser(User user) async {
    final db = await instance.database;
    await db.insert('users', user.toMap());
  }

  Future<List<User>> getAllUser() async {
    final db = await instance.database;
    final result = await db.query('users', orderBy: 'id ASC');
    return result.map((json) => User.fromMap(json)).toList();
  }

  Future<User?> getUserById(int id) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    if (user.id == null) {
      throw ArgumentError('User id cannot be null');
    }
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> addFriend(int id, String friend) async {
    final user = await getUserById(id);
    if (user == null) {
      throw Exception('User not found');
    }
    user.friends.add(friend);
    return await updateUser(user);
  }

  Future<int> removeFriend(int id, String friend) async {
    final user = await getUserById(id);
    if (user == null) {
      throw Exception('User not found');
    }
    user.friends.remove(friend);
    return await updateUser(user);
  }

  //IDK I added this just in case
  Future<int> updatePassword(int id, String password) async {
    final user = await getUserById(id);
    if (user == null) {
      throw Exception('User not found');
    }
    user.password = password;
    return await updateUser(user);
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
