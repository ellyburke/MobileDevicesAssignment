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
  List<dynamic>? abilityBonuses;
  Map<String, dynamic>? abilityBonusOptions;
  String? alignment;
  String? age;
  String? size;
  String? sizeDescription;
  List<dynamic>? languages;
  String? languageDesc;
  List<dynamic>? traits;
  List<dynamic>? subraces;

  Race({
    this.name,
    this.speed,
    this.abilityBonuses,
    this.abilityBonusOptions,
    this.alignment,
    this.age,
    this.size,
    this.sizeDescription,
    this.languages,
    this.languageDesc,
    this.traits,
    this.subraces,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      name: json["name"],
      speed: json["speed"],
      abilityBonuses: json["ability_bonuses"],
      abilityBonusOptions: json["ability_bonus_options"],
      alignment: json["alignment"],
      age: json["age"],
      size: json["size"],
      sizeDescription: json["size_description"],
      languages: json["languages"],
      languageDesc: json["language_desc"],
      traits: json["traits"],
      subraces: json["subraces"],
    );
  }
}

class Background extends Content {
  String? name;
  List<dynamic>? startingProficiencies;
  Map<String, dynamic>? languageOptions;
  List<dynamic>? startingEquipment;
  List<dynamic>? startingEquipmentOptions;
  Map<String, dynamic>? feature;
  Map<String, dynamic>? personalityTraits;
  Map<String, dynamic>? ideals;
  Map<String, dynamic>? bonds;
  Map<String, dynamic>? flaws;

  Background({
    this.name,
    this.startingProficiencies,
    this.languageOptions,
    this.startingEquipment,
    this.startingEquipmentOptions,
    this.feature,
    this.personalityTraits,
    this.ideals,
    this.bonds,
    this.flaws,
  });

  factory Background.fromJson(Map<String, dynamic> json) {
    return Background(
      name: json["name"],
      startingProficiencies: json["starting_proficiencies"],
      languageOptions: json["language_options"],
      startingEquipment: json["starting_equipment"],
      startingEquipmentOptions: json["starting_equipment_options"],
      feature: json["feature"],
      personalityTraits: json["personality_traits"],
      ideals: json["ideals"],
      bonds: json["bonds"],
      flaws: json["flaws"],
    );
  }
}

class Class extends Content {
  String? name;
  int? hitDie;
  List<dynamic>? proficiencyChoices;
  List<dynamic>? proficiencies;
  List<dynamic>? savingThrows;
  List<dynamic>? startingEquipment;
  List<dynamic>? startingEquipmentOptions;
  String? classLevels;
  Map<String, dynamic>? multiClassing;
  List<dynamic>? subclasses;
  List<dynamic>? spellCasting;
  String? spells;

  Class({
    this.name,
    this.hitDie,
    this.proficiencyChoices,
    this.proficiencies,
    this.savingThrows,
    this.startingEquipment,
    this.startingEquipmentOptions,
    this.classLevels,
    this.multiClassing,
    this.subclasses,
    this.spellCasting,
    this.spells,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      name: json["name"],
      hitDie: json["hit_die"],
      proficiencyChoices: json["proficiency_choices"],
      proficiencies: json["proficiencies"],
      savingThrows: json["saving_throws"],
      startingEquipment: json["starting_equipment"],
      startingEquipmentOptions: json["starting_equipment_options"],
      classLevels: json["class_levels"],
      multiClassing: json["multi_classing"],
      subclasses: json["subclasses"],
      spellCasting: json["spell_casting"],
      spells: json["spells"],
    );
  }
}

class Spell extends Content {
  String? name;
  List<dynamic>? desc;
  List<dynamic>? higherLevel;
  String? range;
  List<dynamic>? components;
  String? material;
  bool? ritual;
  String? duration;
  bool? concentration;
  String? castingTime;
  int? level;
  Map<String, dynamic>? healAtSlotLevel;
  String? attackType;
  Map<String, dynamic>? damage;
  Map<String, dynamic>? damageAtLevel;
  Map<String, dynamic>? school;
  List<dynamic>? classes;
  List<dynamic>? subclasses;

  Spell({
    this.name,
    this.desc,
    this.higherLevel,
    this.range,
    this.components,
    this.material,
    this.ritual,
    this.duration,
    this.concentration,
    this.castingTime,
    this.level,
    this.healAtSlotLevel,
    this.attackType,
    this.damage,
    this.damageAtLevel,
    this.school,
    this.classes,
    this.subclasses,
  });

  factory Spell.fromJson(Map<String, dynamic> json) {
    for (String key in json.keys) {
      print("$key: ${json[key].runtimeType}");
    }
    return Spell(
      name: json["name"],
      desc: json["desc"],
      higherLevel: json["higher_level"],
      range: json["range"],
      components: json["components"],
      material: json["material"],
      ritual: json["ritual"],
      duration: json["duration"],
      concentration: json["concentration"],
      castingTime: json["casting_time"],
      level: json["level"],
      healAtSlotLevel: json["heal_at_slot_level"],
      attackType: json["attack_type"],
      damage: json["damage"],
      damageAtLevel: json["damage_at_slot_level"],
      school: json["school"],
      classes: json["classes"],
      subclasses: json["subclasses"],
    );
  }
}

class Equipment extends Content {
  String? name;
  List<dynamic>? desc;
  Map<String, dynamic>? equipmentCategory;
  String? weaponCategory;
  String? weaponRange;
  String? categoryRange;
  Map<String, dynamic>? cost;
  Map<String, dynamic>? damage;
  Map<String, dynamic>? range;
  int? weight;
  List<dynamic>? properties;
  List<dynamic>? special;
  List<dynamic>? contents;

  Equipment({
    this.name,
    this.desc,
    this.equipmentCategory,
    this.weaponCategory,
    this.weaponRange,
    this.categoryRange,
    this.cost,
    this.damage,
    this.range,
    this.weight,
    this.properties,
    this.special,
    this.contents,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      name: json["name"],
      desc: json["desc"],
      equipmentCategory: json["equipment_category"],
      weaponCategory: json["weapon_category"],
      categoryRange: json["category_range"],
      cost: json["cost"],
      damage: json["json"],
      range: json["range"],
      weight: json["weight"],
      properties: json["properties"],
      special: json["special"],
      contents: json["contents"],
    );
  }
}

class Monster extends Content {
  String? name;
  String? size;
  String? type;
  String? alignment;
  List<dynamic>? armour;
  int? hitPoints;
  String? hitDice;
  String? hitPointsRoll;
  Map<String, dynamic>? speed;
  int? strength;
  int? dexterity;
  int? constitution;
  int? intelligence;
  int? wisdom;
  int? charisma;
  List<dynamic>? proficiencies;
  List<dynamic>? damageVulnerabilities;
  List<dynamic>? damageResistances;
  List<dynamic>? damageImmunities;
  List<dynamic>? conditionImmunities;
  Map<String, dynamic>? senses;
  String? languages;
  double? challengeRating;
  int? proficiencyBonus;
  int? xp;
  List<dynamic>? specialAbilities;
  List<dynamic>? actions;
  List<dynamic>? legendaryActions;
  List<dynamic>? forms;
  List<dynamic>? reactions;

  Monster({
    this.name,
    this.size,
    this.type,
    this.alignment,
    this.armour,
    this.hitPoints,
    this.hitDice,
    this.hitPointsRoll,
    this.speed,
    this.strength,
    this.dexterity,
    this.constitution,
    this.intelligence,
    this.wisdom,
    this.charisma,
    this.proficiencies,
    this.damageVulnerabilities,
    this.damageResistances,
    this.damageImmunities,
    this.conditionImmunities,
    this.senses,
    this.languages,
    this.challengeRating,
    this.proficiencyBonus,
    this.xp,
    this.specialAbilities,
    this.actions,
    this.legendaryActions,
    this.forms,
    this.reactions,
  });

  factory Monster.fromJson(Map<String, dynamic> json) {
    // print("=-=--=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=");
    // for (String key in json.keys) {
    //   print("$key: ${json[key].runtimeType}");
    // }

    return Monster(
      name: json["name"],
      size: json["size"],
      type: json["type"],
      alignment: json["alignment"],
      armour: json["armor_class"],
      hitPoints: json["hit_points"],
      hitDice: json["hit_dice"],
      hitPointsRoll: json["hit_points_roll"],
      speed: json["speed"],
      strength: json["strength"],
      dexterity: json["dexterity"],
      constitution: json["constitution"],
      intelligence: json["intelligence"],
      wisdom: json["wisdom"],
      charisma: json["charisma"],
      proficiencies: json["proficiencies"],
      damageVulnerabilities: json["damage_vulnerabilities"],
      damageResistances: json["damage_resistances"],
      damageImmunities: json["damage_immunities"],
      conditionImmunities: json["condition_immunities"],
      senses: json["senses"],
      languages: json["languages"],
      challengeRating: json["challenge_rating"].toDouble(),
      proficiencyBonus: json["proficiency_bonus"],
      xp: json["xp"],
      specialAbilities: json["special_abilities"],
      actions: json["actions"],
      legendaryActions: json["legendary_actions"],
      forms: json["forms"],
      reactions: json["reactions"],
    );
  }
}
