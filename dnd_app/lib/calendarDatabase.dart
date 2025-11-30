import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CalendarEvent {
  int? id;
  String? username;

  /// Store only the date portion (year-month-day)
  DateTime date;

  /// 'HH:MM' 24h format stuff like ('09:05' '14:30')
  String time;

  List<String> attendees;

  CalendarEvent({
    this.id,
    required this.username,
    required this.date,
    required this.time,
    required this.attendees,
  });

  //This formats the date into a YYYY-MM-DD string
  static String _yyyyMmDd(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'date': _yyyyMmDd(date), // 'YYYY-MM-DD'
      'time': time, // 'HH:MM' 24h string
      'attendees': jsonEncode(attendees),
    };
  }

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    final String dateStr = map['date'] as String;
    final DateTime parsedDate = DateTime.parse('${dateStr}T00:00:00');

    // attendees stored as JSON
    final raw = map['attendees'] as String? ?? '[]';
    final List<String> people = (jsonDecode(raw) as List)
        .map((e) => e.toString())
        .toList();

    return CalendarEvent(
      id: (map['id'] as num?)?.toInt(),
      username: map['username'] ?? '',
      date: parsedDate,
      time: map['time'] as String, // 'HH:MM'
      attendees: people,
    );
  }
}

class CalendarDatabase {
  static final CalendarDatabase instance = CalendarDatabase._init();
  static Database? _database;
  CalendarDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase('calendar.db');
    return _database!;
  }

  Future<Database> _initializeDatabase(String filename) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, filename);
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE calendar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        date TEXT NOT NULL,                  -- 'YYYY-MM-DD'
        time TEXT NOT NULL,                  -- 'HH:MM' 24h
        attendees TEXT NOT NULL DEFAULT '[]', -- JSON array of strings
        FOREIGN KEY (username) REFERENCES users (username) ON DELETE CASCADE
      );
    ''');

    //This makes certain queries much faster by creating a composite index on date and time
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_calendar_date_time ON calendar(date, time);',
    );
  }

  //Insert function
  Future<int> insert(CalendarEvent event) async {
    final db = await instance.database;
    return db.insert('calendar', event.toMap());
  }

  //List all events
  Future<List<CalendarEvent>> getAllEvents() async {
    final db = await instance.database;
    final result = await db.query('calendar', orderBy: 'date ASC, time ASC');
    return result.map((json) => CalendarEvent.fromMap(json)).toList();
  }

  Future<List<CalendarEvent>> getEventsByUserName(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'calendar',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'date ASC, time ASC'
    );
    return result.map((json) => CalendarEvent.fromMap(json)).toList();
  }

  //List events on a specific date
  Future<List<CalendarEvent>> getEventsOnDate(DateTime day) async {
    final db = await instance.database;
    final yyyyMmDd = CalendarEvent._yyyyMmDd(day);
    final result = await db.query(
      'calendar',
      where: 'date = ?',
      whereArgs: [yyyyMmDd],
      orderBy: 'time ASC',
    );
    return result.map((json) => CalendarEvent.fromMap(json)).toList();
  }

  Future<CalendarEvent?> getEventById(int eventId) async {
    final db = await instance.database;
    final result = await db.query(
      'calendar',
      where: 'id = ?',
      whereArgs: [eventId],
    );
    return result.isNotEmpty ? CalendarEvent.fromMap(result.first) : null;
  }

  Future<int> updateEvent(CalendarEvent event) async {
    final db = await instance.database;
    if (event.id == null) {
      throw ArgumentError('updateEvent requires event.id to be non-null');
    }
    return db.update(
      'calendar',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> deleteEvent(int eventId) async {
    final db = await instance.database;
    return db.delete('calendar', where: 'id = ?', whereArgs: [eventId]);
  }

  Future<int> deleteEventByDateTime(DateTime date, String time) async {
    final db = await instance.database;
    final yyyyMmDd = CalendarEvent._yyyyMmDd(date);
    return db.delete(
      'calendar',
      where: 'date = ? AND time = ?',
      whereArgs: [yyyyMmDd, time],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
