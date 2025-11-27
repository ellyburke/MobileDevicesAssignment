import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'backEnd.dart';

class CharacterDatabase {
  static final CharacterDatabase instance = CharacterDatabase._init();
  static Database? _database;

  CharacterDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('characters.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE characters (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      race TEXT,
      background TEXT,
      alignment TEXT,
      appearance TEXT,
      level INTEGER,
      hp INTEGER,
      strength INTEGER,
      dexterity INTEGER,
      constitution INTEGER,
      intelligence INTEGER,
      wisdom INTEGER,
      charisma INTEGER,
      armor_class INTEGER,
      initiative INTEGER,
      speed INTEGER,
      passive_perception INTEGER,
      size TEXT,
      Class TEXT,
      skills TEXT,
      features TEXT,
      traits TEXT,
      equipment TEXT,
      inventory TEXT,
      proficiencies INT,
      languages TEXT,
      spells TEXT,
      spell_casting_ability TEXT,
      spell_slots TEXT
    )
    ''');
  }

  Future<int> create(Character character) async {
    final db = await instance.database;
    return await db.insert('characters', character.toMap());
  }

  Future<List<Character>> readAllCharacters() async {
    final db = await instance.database;
    final result = await db.query('characters');
    return result.map((map) => Character.fromMap(map)).toList();
  }

  Future<int> update(Character character) async {
    final db = await instance.database;
    return db.update(
      'characters',
      character.toMap(),
      where: 'id = ?',
      whereArgs: [character.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('characters', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
