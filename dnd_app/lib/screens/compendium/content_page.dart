import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'content.dart';

class ContentPage extends StatefulWidget {
  final String endpoint;
  final String category;

  const ContentPage({
    super.key,
    required this.endpoint,
    required this.category,
  });

  @override
  ContentPageState createState() => ContentPageState();
}

class ContentPageState extends State<ContentPage> {
  late Future<Content> futureContent;

  @override
  void initState() {
    super.initState();
    futureContent = fetchContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.endpoint.toUpperCase())),
      body: FutureBuilder<Content>(
        future: futureContent,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("Has Data");
            if (snapshot.data is Race) {
              return buildRace(snapshot.data as Race);
            } else if (snapshot.data is Background) {
              return buildBackground(snapshot.data as Background);
            } else if (snapshot.data is Class) {
              return buildClass(snapshot.data as Class);
            } else if (snapshot.data is Spell) {
              return buildSpell(snapshot.data as Spell);
            } else if (snapshot.data is Equipment) {
              return buildEquipment(snapshot.data as Equipment);
            } else if (snapshot.data is Monster) {
              return buildMonster(snapshot.data as Monster);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF1E1B18)),
          );
        },
      ),
    );
  }

  Widget buildRace(Race race) {
    return ListView(
      children: [
        Text("speed: ${race.speed}"),
        Text("ability bonuses: ${race.abilityBonuses}"),
        Text("ability bonus options: ${race.abilityBonusOptions}"),
        Text("alignment: ${race.alignment}"),
        Text("age: ${race.age}"),
        Text("size: ${race.size}"),
        Text("size description: ${race.sizeDescription}"),
        Text("languages: ${race.languages}"),
        Text("language description: ${race.languageDesc}"),
        Text("traits: ${race.traits}"),
      ],
    );
  }

  Widget buildBackground(Background background) {
    return ListView(
      children: [
        Text("starting proficiencies: ${background.startingProficiencies}"),
        Text("language options: ${background.languageOptions}"),
        Text("starting equipment: ${background.startingEquipment}"),
        Text(
          "starting equipment options: ${background.startingEquipmentOptions}",
        ),
        Text("feature: ${background.feature}"),
        Text("personality traits: ${background.personalityTraits}"),
        Text("ideals: ${background.ideals}"),
        Text("bonds: ${background.bonds}"),
        Text("flaws: ${background.flaws}"),
      ],
    );
  }

  Widget buildClass(Class playerClass) {
    return ListView(
      children: [
        Text("hit die: ${playerClass.hitDie}"),
        Text("proficiency choices: ${playerClass.proficiencyChoices}"),
        Text("proficiencies: ${playerClass.proficiencies}"),
        Text("saving throws: ${playerClass.savingThrows}"),
        Text("starting equipment: ${playerClass.startingEquipment}"),
        Text("class levels: ${playerClass.classLevels}"),
        Text("mulit-classing: ${playerClass.multiClassing}"),
        Text("subclasses: ${playerClass.subclasses}"),
        Text("spell casting: ${playerClass.spellCasting}"),
        Text("spells: ${playerClass.spells}"),
      ],
    );
  }

  Widget buildSpell(Spell spell) {
    return Center(
      child: Column(
        children: [
          Text("name: ${spell.name}"),
          Text("desc: ${spell.desc}"),
          Text("higher level: ${spell.higherLevel}"),
          Text("range: ${spell.range}"),
          Text("components: ${spell.components}"),
          Text("material: ${spell.material}"),
          Text("ritual: ${spell.ritual.toString()}"),
          Text("duration: ${spell.duration}"),
          Text("concentration: ${spell.concentration.toString()}"),
          Text("casting time: ${spell.castingTime}"),
          Text("level: ${spell.level.toString()}"),
          Text("attack type: ${spell.attackType}"),
          Text("damage: ${spell.damage}"),
          Text("damage at level: ${spell.damageAtLevel}"),
          Text("school: ${spell.school}"),
          Text("classes: ${spell.classes}"),
          Text("subclasses: ${spell.subclasses}"),
        ],
      ),
    );
  }

  Widget buildEquipment(Equipment equipment) {
    return Center(
      child: ListView(
        children: [
          Text("desc: ${equipment.desc}"),
          Text("equipment category: ${equipment.equipmentCategory}"),
          Text("weapon category: ${equipment.weaponCategory}"),
          Text("weapon range: ${equipment.weaponRange}"),
          Text("category range: ${equipment.categoryRange}"),
          Text("cost: ${equipment.cost}"),
          Text("damage: ${equipment.damage}"),
          Text("range: ${equipment.range}"),
          Text("weight: ${equipment.weight}"),
          Text("properties: ${equipment.properties}"),
          Text("special: ${equipment.special}"),
          Text("contents: ${equipment.contents}"),
        ],
      ),
    );
  }

  Widget buildMonster(Monster monster) {
    return Center(
      child: ListView(
        children: [
          Text("size: ${monster.size}"),
          Text("type: ${monster.type}"),
          Text("alignment: ${monster.alignment!}"),
          Text("armor class: ${monster.armour}"),
          Text("hit points: ${monster.hitPoints}"),
          Text("hit dice: ${monster.hitDice}"),
          Text("hit points roll: ${monster.hitPointsRoll}"),
          Text("speed: ${monster.speed}"),
          Text("strength: ${monster.strength}"),
          Text("dexterity: ${monster.dexterity}"),
          Text("constitution: ${monster.constitution}"),
          Text("intelligence: ${monster.intelligence}"),
          Text("wisdom: ${monster.wisdom}"),
          Text("charisma: ${monster.charisma}"),
          Text("proficiencies: ${monster.proficiencies}"),
          Text("damage vulnerabilities: ${monster.damageVulnerabilities}"),
          Text("damage resistances: ${monster.damageResistances}"),
          Text("damage immunities: ${monster.damageImmunities}"),
          Text("condition immunities: ${monster.conditionImmunities}"),
          Text("senses: ${monster.senses}"),
          Text("languages: ${monster.languages}"),
          Text("challenge rating: ${monster.challengeRating}"),
          Text("XP: ${monster.xp}"),
          Text("special abilities: ${monster.specialAbilities}"),
          Text("actions: ${monster.actions}"),
          Text("legendary actions: ${monster.legendaryActions}"),
          Text("Proficiency Bonus: ${monster.proficiencyBonus}"),
          Text("forms: ${monster.forms}"),
          Text("reactions: ${monster.reactions}"),
        ],
      ),
    );
  }

  Future<Content> fetchContent() async {
    final response = await http.get(
      Uri.parse(
        'https://www.dnd5eapi.co/api/2014/${widget.category}/${widget.endpoint}',
      ),
    );

    print(
      "API call:\n'https://www.dnd5eapi.co/api/2014/${widget.category}/${widget.endpoint}'",
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      if (widget.category == "races") {
        return Race.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else if (widget.category == "backgrounds") {
        return Background.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else if (widget.category == "classes") {
        return Class.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else if (widget.category == "spells") {
        return Spell.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else if (widget.category == "equipment") {
        return Equipment.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else if (widget.category == "monsters") {
        return Monster.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception('Invalid Endpoint');
      }
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Monster');
    }
  }
}
