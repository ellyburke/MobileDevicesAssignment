// import 'dart:async';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:http/http.dart' as http;

class Response {
  int? count;
  List? results;

  Response({this.count, this.results});

  factory Response.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"count": int count, "results": List results} => Response(
        count: count,
        results: results,
      ),
      _ => throw const FormatException(
        "Failed to load Response in content.dart",
      ),
    };
  }
}

class Content {}

class Race extends Content {
  String? name;
  int? speed;
  String? age;
  String? alignment;
  String? size;
  String? sizeDescription;

  Race({
    this.name,
    this.speed,
    this.age,
    this.alignment,
    this.size,
    this.sizeDescription,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "name": String name,
        "speed": int speed,
        "age": String age,
        "alignment": String alignment,
        "size": String size,
        "size_description": String sizeDescription,
      } =>
        Race(
          name: name,
          speed: speed,
          age: age,
          alignment: alignment,
          size: size,
          sizeDescription: sizeDescription,
        ),
      _ => throw const FormatException("Failed to load Race in content.dart"),
    };
  }
}

class Background extends Content {
  String? name;

  Map<String, dynamic>? feature;

  Background({this.name, this.feature});

  factory Background.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"name": String name, "feature": Map<String, dynamic> feature} =>
        Background(name: name, feature: feature),
      _ => throw const FormatException(
        "Failed to load Background in content.dart",
      ),
    };
  }
}

class Class extends Content {
  String? name;
  int? hitDie;

  Class({this.name, this.hitDie});

  factory Class.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"name": String name, "hit_die": int hitDie} => Class(
        name: name,
        hitDie: hitDie,
      ),
      _ => throw const FormatException("Failed to load Class in content.dart"),
    };
  }
}

class Spell extends Content {
  String? name;
  List? desc;
  String? range;
  String? material;
  bool? ritual;
  String? duration;
  bool? concentration;
  String? castingTime;
  int? level;

  Spell({
    this.name,
    this.desc,
    this.range,
    this.material,
    this.ritual,
    this.duration,
    this.concentration,
    this.castingTime,
    this.level,
  });

  factory Spell.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "name": String name,
        "desc": List desc,
        "range": String range,
        // "material": String material,
        "ritual": bool ritual,
        "duration": String duration,
        "concentration": bool concentration,
        "casting_time": String castingTime,
        "level": int level,
      } =>
        Spell(
          name: name,
          desc: desc,
          range: range,
          // material: material,
          ritual: ritual,
          duration: duration,
          concentration: concentration,
          castingTime: castingTime,
          level: level,
        ),
      _ => throw const FormatException("Failed to load Spell in content.dart"),
    };
  }
}

class Equipment extends Content {
  String? name;
  Map<String, dynamic>? cost;

  Equipment({this.name, this.cost});

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"name": String name, "cost": Map<String, dynamic> cost} => Equipment(
        name: name,
        cost: cost,
      ),
      _ => throw const FormatException(
        "Failed to load Equipment in content.dart",
      ),
    };
  }
}

class Monster extends Content {
  String? name;
  String? size;
  String? alignment;
  List? armour;
  int? hp;
  String? hitDice;
  Map<String, dynamic>? speed;
  int? strength;
  int? dexterity;
  int? constitution;
  int? intelligence;
  int? wisdom;
  int? charisma;
  String? languages;
  int? proficiencyBonus;
  int? xp;

  Monster({
    this.name,
    this.size,
    this.alignment,
    this.armour,
    this.hp,
    this.hitDice,
    this.speed,
    this.strength,
    this.dexterity,
    this.constitution,
    this.intelligence,
    this.wisdom,
    this.charisma,
    this.languages,
    this.proficiencyBonus,
    this.xp,
  });

  factory Monster.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "name": String name,
        "size": String size,
        "alignment": String alignment,
        "armor_class": List armour,
        "hit_points": int hp,
        "hit_dice": String hitDice,
        "speed": Map<String, dynamic> speed,
        "strength": int strength,
        "dexterity": int dexterity,
        "constitution": int constitution,
        "intelligence": int intelligence,
        "wisdom": int wisdom,
        "charisma": int charisma,
        "languages": String languages,
        "proficiency_bonus": int proficiencyBonus,
        "xp": int xp,
      } =>
        Monster(
          name: name,
          size: size,
          alignment: alignment,
          armour: armour,
          hp: hp,
          hitDice: hitDice,
          speed: speed,
          strength: strength,
          dexterity: dexterity,
          constitution: constitution,
          intelligence: intelligence,
          wisdom: wisdom,
          charisma: charisma,
          languages: languages,
          proficiencyBonus: proficiencyBonus,
          xp: xp,
        ),
      _ => throw const FormatException(
        "Failed to load Monster in content.dart",
      ),
    };
  }
}
