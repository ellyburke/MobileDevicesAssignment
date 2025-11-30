import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  int? id;
  String username;
  String password;
  List<int> friends; //List of usernames or ids of friends, probably id.
  String firstName;
  String lastName;
  DateTime birthday;
  String? bio;
  String? displayName;
  String? pronouns;
  String? profileImage;
  String email;


  User({
    this.id,
    required this.username,
    required this.password,
    this.friends = const [],
    required this.firstName,
    required this.lastName,
    required this.birthday,
    this.bio,
    this.displayName,
    this.pronouns,
    this.profileImage,
    required this.email
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'friends': jsonEncode(friends),
      'firstName': firstName,
      'lastName': lastName,
      'birthday': birthday.toIso8601String(),
      'bio': bio,
      'displayName': displayName,
      'pronouns': pronouns,
      'profileImage': profileImage,
      'email': email,
    };
  }


  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      friends: map['friends'] != null
          ? List<int>.from(jsonDecode(map['friends']))
          : [],
      firstName: map['firstName'],
      lastName: map['lastName'],
      birthday: DateTime.parse(map['birthday']),
      bio: map['bio'],
      displayName: map['displayName'],
      pronouns: map['pronouns'],
      profileImage: map['profileImage'],
      email: map['email'],
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

  // Deletes database - ONLY FOR TESTING
  // Future<void> deleteOldDatabase() async {
  //   final dbPath = await getDatabasesPath();
  //   final path = join(dbPath, 'user.db');
  //
  //   await deleteDatabase(path);
  // }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      email TEXT NOT NULL,
      firstName TEXT NOT NULL,
      lastName TEXT NOT NULL,
      birthday TEXT NOT NULL,
      bio TEXT,
      displayName TEXT,
      pronouns TEXT,
      profileImage TEXT,
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

  Future<int> addFriend(int id, int friendId) async {
    final user = await getUserById(id);
    if (user == null) {
      throw Exception('User not found');
    }
    user.friends.add(friendId);
    return await updateUser(user);
  }

  Future<int> removeFriend(int id, int friendId) async {
    final user = await getUserById(id);
    if (user == null) {
      throw Exception('User not found');
    }
    user.friends.remove(friendId);
    return await updateUser(user);
  }

  Future<List<User>> getFriends(int id) async {
    final user = await getUserById(id);

    if (user == null) {
      throw Exception('User not found');
    }

    List<User> friendsList = [];
    if (user.friends.isNotEmpty){
      for (int friendId in user.friends){
        final friend = await getUserById(friendId);
        if (friend != null) {
          friendsList.add(friend);
        }
      }
    }
    return friendsList;
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
