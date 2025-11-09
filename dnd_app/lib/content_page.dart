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
      appBar: AppBar(),
      body: FutureBuilder<Content>(
        future: futureContent,
        builder: (context, snapshot) {
          print("Future Builder");
          if (snapshot.hasData) {
            print("Has Data");
            if (snapshot.data is Race) {
              print("Race");
              return buildRace(snapshot.data as Race);
            } else if (snapshot.data is Background) {
              print("Background");
              return buildBackground(snapshot.data as Background);
            } else if (snapshot.data is Class) {
              print("Class");
              return buildClass(snapshot.data as Class);
            } else if (snapshot.data is Spell) {
              print("spell");
              return buildSpell(snapshot.data as Spell);
            } else if (snapshot.data is Equipment) {
              print("Equipment");
              return buildEquipment(snapshot.data as Equipment);
            } else if (snapshot.data is Monster) {
              print("monster");
              return buildMonster(snapshot.data as Monster);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget buildRace(Race race) {
    return Center(child: Text(race.name!));
  }

  Widget buildBackground(Background background) {
    return Center(child: Text(background.name!));
  }

  Widget buildClass(Class playerClass) {
    return Center(child: Text(playerClass.name!));
  }

  Widget buildSpell(Spell spell) {
    return Center(
      child: Column(
        children: [
          Text(spell.name!),
          Text(spell.desc![0]),
          Text(spell.range!),
          Text(spell.ritual.toString()),
          Text(spell.duration!),
          Text(spell.concentration.toString()),
          Text(spell.castingTime!),
          Text(spell.level.toString()),
        ],
      ),
    );
  }

  Widget buildEquipment(Equipment equipment) {
    return Center(
      child: Column(
        children: [
          Text(equipment.name!),
          Row(
            children: [
              Text(equipment.cost!["quantity"].toString()),
              Text(equipment.cost!["unit"]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMonster(Monster monster) {
    return Center(
      child: Column(
        children: [
          Text(monster.name!),
          Text("size: ${monster.size}"),
          Text("alignment: ${monster.alignment!}"),
          Text("armor class: ${monster.armour}"),
          Text("hit points: ${monster.hp}"),
          Text("hit dice: ${monster.hitDice}"),
          Text("speed: ${monster.speed}"),
          Row(
            children: [
              Text("strength: ${monster.strength}"),
              Text("dexterity: ${monster.dexterity}"),
              Text("constitution: ${monster.constitution}"),
              Text("intelligence: ${monster.intelligence}"),
              Text("wisdom: ${monster.wisdom}"),
              Text("charisma: ${monster.charisma}"),
            ],
          ),
          Text("languages: ${monster.languages}"),
          Text("Proficiency Bonus: ${monster.proficiencyBonus}"),
          Text("XP: ${monster.xp}"),
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
      print("category: ${widget.category}");
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
