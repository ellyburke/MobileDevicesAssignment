import 'dart:convert';

class Character {
  int? id;
  int hp;
  int strength;
  int dexterity;
  int intelligence;
  int constitution;
  int wisdom;
  int charisma;
  String name;
  String race;
  int level;
  int armorClass;
  int initiative;
  int speed;
  int passivePerception;
  String background;
  String alignment;
  String? appearance;
  String? size;

  Map<String, int> charClass;
  Map<String, int> skills;
  Map<String, int>? inventory;
  Map<String, int>? spellCastingAbility;
  Map<String, int>? spellSlots;

  List<String> features;
  List<String> traits;
  List<String> classFeatures;
  List<String>? equipment;
  List<String> proficiencies;
  List<String> languages;
  List<String>? spells;

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
    required this.charClass,
    required this.skills,
    required this.features,
    required this.traits,
    required this.classFeatures,
    required this.proficiencies,
    required this.languages,
    required this.size,
    this.inventory,
    this.equipment,
    this.spells,
    this.spellCastingAbility,
    this.spellSlots,
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
      'char_class': jsonEncode(charClass),
      'skills': jsonEncode(skills),
      'features': jsonEncode(features),
      'traits': jsonEncode(traits),
      'class_features': jsonEncode(classFeatures),
      'equipment': jsonEncode(equipment),
      'inventory': jsonEncode(inventory),
      'proficiencies': jsonEncode(proficiencies),
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
      charClass: _decodeMap(map['char_class']),
      skills: _decodeMap(map['skills']),
      features: _decodeList(map['features']),
      traits: _decodeList(map['traits']),
      classFeatures: _decodeList(map['class_features']),
      proficiencies: _decodeList(map['proficiencies']),
      languages: _decodeList(map['languages']),
      inventory: _decodeMapNullable(map['inventory']),
      equipment: _decodeListNullable(map['equipment']),
      spells: _decodeListNullable(map['spells']),
      spellCastingAbility: _decodeMapNullable(map['spell_casting_ability']),
      spellSlots: _decodeMapNullable(map['spell_slots']),
    );
  }

  static Map<String, int> _decodeMap(dynamic data) =>
      Map<String, int>.from(jsonDecode(data ?? '{}'));

  static Map<String, int>? _decodeMapNullable(dynamic data) =>
      data == null ? null : Map<String, int>.from(jsonDecode(data));

  static List<String> _decodeList(dynamic data) =>
      List<String>.from(jsonDecode(data ?? '[]'));

  static List<String>? _decodeListNullable(dynamic data) =>
      data == null ? null : List<String>.from(jsonDecode(data));
}
