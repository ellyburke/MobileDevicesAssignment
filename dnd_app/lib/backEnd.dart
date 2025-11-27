import 'dart:convert';

class Character {
  int? id;
  int? hp;
  int? strength;
  int? dexterity;
  int? intelligence;
  int? constitution;
  int? wisdom;
  int? charisma;
  String? name;
  String? race;
  int? level;
  int? armorClass;
  int? initiative;
  int? speed;
  int? passivePerception;
  String? background;
  String? alignment;
  String? appearance;
  String size;

  String? Class;
  Map<String, bool> skillBonuses;
  Map<String, int> inventory;
  Map<String, int> spellCastingAbility;
  Map<String, int> spellSlots;

  List<String> features;
  List<String>? traits;
  List<String>? equipment;
  int proficiencies;
  List<String> languages;
  List<String> spells;

  Character({
    this.id,
    required this.hp,
    required this.strength,
    required this.dexterity,
    required this.intelligence,
    required this.constitution,
    required this.wisdom,
    required this.charisma,
    required this.name,
    required this.race,
    required this.level,
    required this.armorClass,
    required this.initiative,
    required this.speed,
    required this.passivePerception,
    required this.background,
    required this.alignment,
    required this.Class,
    required this.skillBonuses,
    required this.features,
    required this.traits,
    required this.proficiencies,
    required this.languages,
    required this.size,
    required this.inventory,
    this.equipment,
    required this.spells,
    required this.spellCastingAbility,
    required this.spellSlots,
    this.appearance,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'race': race,
      'background': background,
      'alignment': alignment,
      'appearance': appearance,
      'level': level,
      'hp': hp,
      'strength': strength,
      'dexterity': dexterity,
      'constitution': constitution,
      'intelligence': intelligence,
      'wisdom': wisdom,
      'charisma': charisma,
      'armor_class': armorClass,
      'initiative': initiative,
      'speed': speed,
      'passive_perception': passivePerception,
      'size': size,
      'Class': Class,
      'skills': jsonEncode(skillBonuses),
      'features': jsonEncode(features),
      'traits': jsonEncode(traits ?? <String>[]),
      'equipment': jsonEncode(equipment ?? <String>[]),
      'inventory': jsonEncode(inventory),
      'proficiencies': proficiencies,
      'languages': jsonEncode(languages),
      'spells': jsonEncode(spells),
      'spell_casting_ability': jsonEncode(spellCastingAbility),
      'spell_slots': jsonEncode(spellSlots),
    };
  }

  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'] as int?,
      name: map['name'] ?? '',
      race: map['race'] ?? '',
      background: map['background'] ?? '',
      alignment: map['alignment'] ?? '',
      appearance: map['appearance'],
      level: map['level'] ?? 1,
      hp: map['hp'] ?? 0,
      strength: map['strength'] ?? 0,
      dexterity: map['dexterity'] ?? 0,
      constitution: map['constitution'] ?? 0,
      intelligence: map['intelligence'] ?? 0,
      wisdom: map['wisdom'] ?? 0,
      charisma: map['charisma'] ?? 0,
      armorClass: map['armor_class'] ?? 10,
      initiative: map['initiative'] ?? 0,
      speed: map['speed'] ?? 30,
      passivePerception: map['passive_perception'] ?? 10,
      size: map['size'] ?? '',
      Class: map['Class'] ?? '',
      skillBonuses: _decodeBoolMap(map['skills']),
      features: _decodeList(map['features']),
      traits: _decodeList(map['traits']),
      proficiencies: map['proficiencies'] ?? 0,
      languages: _decodeList(map['languages']),
      inventory: _decodeIntMap(map['inventory']),
      equipment: _decodeList(map['equipment']),
      spells: _decodeList(map['spells']),
      spellCastingAbility: _decodeIntMap(map['spell_casting_ability']),
      spellSlots: _decodeIntMap(map['spell_slots']),
    );
  }
  static List<String> _decodeList(dynamic data) {
    if (data == null) return <String>[];

    // If it's already a List from sqflite
    if (data is List) {
      return List<String>.from(data.map((e) => e.toString()));
    }

    if (data is! String) return <String>[];

    if (data.trim().isEmpty || data.trim() == 'null') {
      return <String>[];
    }

    final decoded = jsonDecode(data);

    if (decoded == null) return <String>[];

    if (decoded is List) {
      return List<String>.from(decoded.map((e) => e.toString()));
    }

    return <String>[];
  }

  static Map<String, int> _decodeIntMap(dynamic data) {
    if (data == null) return <String, int>{};

    if (data is Map) {
      return Map<String, int>.from(
        data.map((key, value) => MapEntry(key.toString(), (value ?? 0) as int)),
      );
    }

    if (data is! String) return <String, int>{};

    if (data.trim().isEmpty || data.trim() == 'null') {
      return <String, int>{};
    }

    final decoded = jsonDecode(data);

    if (decoded == null || decoded is! Map) return <String, int>{};

    return decoded.map<String, int>(
      (key, value) => MapEntry(key.toString(), (value ?? 0) as int),
    );
  }

  static Map<String, bool> _decodeBoolMap(dynamic data) {
    if (data == null) return <String, bool>{};

    if (data is Map) {
      return Map<String, bool>.from(
        data.map(
          (key, value) => MapEntry(key.toString(), (value ?? false) as bool),
        ),
      );
    }

    if (data is! String) return <String, bool>{};

    if (data.trim().isEmpty || data.trim() == 'null') {
      return <String, bool>{};
    }

    final decoded = jsonDecode(data);

    if (decoded == null || decoded is! Map) return <String, bool>{};

    return decoded.map<String, bool>(
      (key, value) => MapEntry(key.toString(), (value ?? false) as bool),
    );
  }
}
