/*
Contributors: Ayaan Mustafa
Date: 2025/11/30
Purpose: Describe Widget for a single item of the compendium for each category
 */

// imports
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'content.dart';

// ContentPage Widget Class
class ContentPage extends StatefulWidget {
  // class fields
  final String endpoint; // the endpoint to call in the API
  final String category; // category the item belongs to

  // Constructor
  const ContentPage({
    super.key,
    required this.endpoint,
    required this.category,
  });

  // createState method
  @override
  ContentPageState createState() => ContentPageState();
}

// ContentPage Widget State
class ContentPageState extends State<ContentPage> {
  late Future<Content> futureContent;

  // initState method
  @override
  void initState() {
    // call parent class Constructor
    super.initState();
    // fetch the specific item
    futureContent = fetchContent();
  }

  // build method that builds different pages depending on what
  // type of item is selected
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.endpoint.toUpperCase()),
      ),
      body: FutureBuilder<Content>(
        future: futureContent,
        builder: (context, snapshot) {
          // check if API request is successful
          if (snapshot.hasData) {
            // Check what kind of item to build and return a widget to
            // display it
            if (snapshot.data is Race) {
              return buildRace(snapshot.data as Race);
            } else if (snapshot.data is Background) {
              return buildBackground(snapshot.data as Background);
            } else if (snapshot.data is PlayerClass) {
              return buildClass(snapshot.data as PlayerClass);
            } else if (snapshot.data is Spell) {
              return buildSpell(snapshot.data as Spell);
            } else if (snapshot.data is Equipment) {
              return buildEquipment(snapshot.data as Equipment);
            } else if (snapshot.data is Monster) {
              return buildMonster(snapshot.data as Monster);
            } else {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFF1E1B18)),
              );
            }
          }
          // by default return circular progress indicator
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF1E1B18)),
          );
        },
      ),
    );
  }

  // method that returns a widget that displays all the information about a
  // Race, by displaying all fields of the race object
  Widget buildRace(Race race) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: ListView(
        children: [
          title("Description"),
          heading("Size"),
          Text("${race.size}, ${race.sizeDescription}"),
          SizedBox(height: 10),
          heading("Age"),
          Text("${race.age}"),
          SizedBox(height: 10),
          heading("Language"),
          Text("${race.languageDesc}"),
          SizedBox(height: 10),
          heading("Alignment"),
          Text("${race.alignment}"),
          SizedBox(height: 10),
          Divider(thickness: 2.5),
          title("Abilities"),
          heading("Speed"),
          Text("${race.speed}"),
          SizedBox(height: 10),
          heading("Ability bonuses:"),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: race.abilityBonuses!.length,
            itemBuilder: (context, index) {
              return Text(
                "+${race.abilityBonuses![index]["bonus"]} ${race.abilityBonuses![index]["ability_score"]["name"]}",
              );
            },
          ),
          SizedBox(height: 10),
          ?race.abilityBonusOptions != null
              ? heading("Ability Bonus Options")
              : null,
          ?race.abilityBonusOptions != null
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:
                      race.abilityBonusOptions!["from"]["options"].length,
                  itemBuilder: (context, index) {
                    return Text(
                      "+${race.abilityBonusOptions!["from"]["options"][index]["bonus"]}"
                      " ${race.abilityBonusOptions!["from"]["options"][index]["ability_score"]["name"]}",
                    );
                  },
                )
              : null,
          SizedBox(height: 10),
          heading("Language Options"),
          futureLanguages(),
          SizedBox(height: 10),
          heading("Traits"),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: race.traits!.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: fetchData(race.traits![index]["url"]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        subHeading(snapshot.data!["name"]),
                        Text("${snapshot.data!["desc"].join("\n")}"),
                        SizedBox(height: 10),
                      ],
                    );
                  } else {
                    return CircularProgressIndicator(color: Color(0xFF1E1B18));
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // method that returns a widget that displays all the information about a
  // background, by displaying all fields of the background object
  Widget buildBackground(Background background) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: ListView(
        children: [
          title("Feature"),
          heading(background.feature!["name"]),
          Text(background.feature!["desc"].join("\n\n")),
          SizedBox(height: 10),
          Divider(thickness: 2.5),
          title("Starting Proficiencies & Equipment"),
          heading("Starting Proficiencies"),
          displayListDict(background.startingProficiencies),
          SizedBox(height: 10),
          heading("Language Options"),
          futureLanguages(),
          SizedBox(height: 10),
          heading("Equipment"),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: background.startingEquipment!.length,
              itemBuilder: (context, index) {
                return Text(
                  background.startingEquipment![index]["equipment"]["name"],
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Divider(thickness: 2.5),
          title("Roleplay Guide"),
          Row(
            children: [
              heading("Personality Traits, "),
              Text("Choose 2", style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
          displayRolePlay(background.personalityTraits),
          SizedBox(height: 10),
          Row(
            children: [
              heading("Ideals, "),
              Text("Choose 1", style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: background.ideals!["from"]["options"].length,
              itemBuilder: (context, index) {
                return Text(
                  "${background.ideals!["from"]["options"][index]["desc"]}",
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              heading("Bonds, "),
              Text("Choose 2", style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
          displayRolePlay(background.bonds),
          SizedBox(height: 10),
          Row(
            children: [
              heading("Flaws, "),
              Text("Choose 2", style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
          displayRolePlay(background.flaws),
        ],
      ),
    );
  }

  // method that returns a widget that displays all the information about a
  // player class, by displaying all fields of the PlayerClass object
  // API calls for player class have nested API calls
  // uses TabView to separate the different information
  Widget buildClass(PlayerClass playerClass) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: "Description"),
                Tab(text: "Levels"),
                Tab(text: "Subclasses"),
                ?playerClass.spells != null ? Tab(text: "Spells") : null,
              ],
              labelColor: Colors.black,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    children: [
                      Text("Hit Die: ${playerClass.hitDie}"),
                      Text("Spell Casting: ${playerClass.spellCasting}"),
                      SizedBox(height: 10),
                      heading("Proficiencies"),
                      displayListDict(playerClass.proficiencies),
                      SizedBox(height: 10),
                      heading("Proficiency Choices"),
                      playerClass.name == "Bard"
                          ? Text("bard prof choices")
                          : Text(playerClass.proficiencyChoices![0]["desc"]),
                      SizedBox(height: 10),
                      heading("Starting Equipment"),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: playerClass.startingEquipment!.length,
                        itemBuilder: (context, index) {
                          return Text(
                            "${playerClass.startingEquipment![index]["equipment"]["name"]}, Amount: ${playerClass.startingEquipment![index]["quantity"]}",
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      heading("Starting Equipment Options"),
                      displayOptions(playerClass.startingEquipmentOptions),
                      SizedBox(height: 10),
                      heading("Multi-Classing"),
                      subHeading("Prerequisites"),
                      playerClass.name == "Fighter"
                          ? ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: playerClass.multiClassing!.keys
                                  .toList()
                                  .length,
                              itemBuilder: (context, index) {
                                return Text(
                                  "${playerClass.multiClassing!["prerequisite_options"]["from"]["options"][index]["minimum_score"]} "
                                  "${playerClass.multiClassing!["prerequisite_options"]["from"]["options"][index]["ability_score"]["name"]}",
                                );
                              },
                            )
                          : ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: playerClass
                                  .multiClassing!["prerequisites"]
                                  .length,
                              itemBuilder: (context, index) {
                                return Text(
                                  "${playerClass.multiClassing!["prerequisites"][index]["minimum_score"]} "
                                  "${playerClass.multiClassing!["prerequisites"][index]["ability_score"]["name"]}",
                                );
                              },
                            ),
                      SizedBox(height: 10),
                      subHeading("Proficiencies Gained"),
                      displayListDict(
                        playerClass.multiClassing!["proficiencies"],
                      ),
                    ],
                  ),
                  FutureBuilder(
                    future: fetchLevels(playerClass.classLevels),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return displayLevel(snapshot.data![index]);
                          },
                        );
                      } else {
                        return CircularProgressIndicator(
                          color: Color(0xFF1E1B18),
                        );
                      }
                    },
                  ),
                  FutureBuilder(
                    future: fetchData(playerClass.subclasses![0]["url"]),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView(
                          primary: true,
                          children: [
                            title(
                              "${snapshot.data!["subclass_flavor"]}: "
                              "${snapshot.data!["name"]}",
                            ),
                            heading("Description"),
                            Text(snapshot.data!["desc"].join("\n\n")),
                            SizedBox(height: 10),
                            FutureBuilder(
                              future: fetchLevels(
                                snapshot.data!["subclass_levels"],
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      return displayLevel(
                                        snapshot.data![index],
                                        subclass: true,
                                      );
                                    },
                                  );
                                } else {
                                  return CircularProgressIndicator(
                                    color: Color(0xFF1E1B18),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      } else {
                        return CircularProgressIndicator(
                          color: Color(0xFF1E1B18),
                        );
                      }
                    },
                  ),
                  ?playerClass.spells != null
                      ? FutureBuilder(
                          future: fetchResponse(playerClass.spells.toString()),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.count,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ContentPage(
                                              endpoint: snapshot
                                                  .data!
                                                  .results![index]["index"],
                                              category: "spells",
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    title: Text(
                                      "${snapshot.data!.results![index]["name"]}",
                                    ),
                                    subtitle:
                                        snapshot
                                                .data!
                                                .results![index]["level"] ==
                                            0
                                        ? Text("Cantrip")
                                        : Text(
                                            "Level: ${snapshot.data!.results![index]["level"]}",
                                          ),
                                  );
                                },
                              );
                            } else {
                              return CircularProgressIndicator(
                                color: Color(0xFF1E1B18),
                              );
                            }
                          },
                        )
                      : null,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // method that returns a widget that displays all the information about a
  // spell, by displaying all fields of the spell object
  Widget buildSpell(Spell spell) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: ListView(
        children: [
          title("Description"),
          Text(spell.desc!.join("\n")),
          SizedBox(height: 10),
          ?spell.higherLevel!.isEmpty ? null : heading("At Higher Levels"),
          ?spell.higherLevel!.isEmpty
              ? null
              : Text("higher level: ${spell.higherLevel!.join("\n")}"),
          SizedBox(height: 10),
          Divider(thickness: 2.5),
          title("Information"),
          heading("Level"),
          Text(spell.level.toString()),
          SizedBox(height: 10),
          heading("School"),
          Text("${spell.school!["name"]}"),
          SizedBox(height: 10),
          heading("Range"),
          Text("${spell.range}"),
          SizedBox(height: 10),
          heading("Components"),
          Text(spell.components!.join(", ")),
          SizedBox(height: 10),
          heading("Materials"),
          spell.material == null ? Text("None") : Text("${spell.material}"),
          SizedBox(height: 10),
          heading("Duration"),
          Text("${spell.duration}"),
          SizedBox(height: 10),
          heading("Concentration"),
          spell.concentration == false
              ? Text("Not Required")
              : Text("Required"),
          SizedBox(height: 10),
          heading("Casting Time"),
          Text("${spell.castingTime}"),
          SizedBox(height: 10),
          heading("Classes"),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: spell.classes!.length,
            itemBuilder: (context, index) {
              return Text("${spell.classes![index]["name"]}:");
            },
          ),
          SizedBox(height: 10),
          heading("Subclasses"),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: spell.subclasses!.length,
            itemBuilder: (context, index) {
              return Text("${spell.subclasses![index]["name"]}");
            },
          ),
        ],
      ),
    );
  }

  // method that returns a widget that displays all the information about a
  // piece of equipment, by displaying all fields of the equipment object
  Widget buildEquipment(Equipment equipment) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.all(20),
        children: [
          ?equipment.desc!.isEmpty
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title("Description"),
                    Text("${equipment.desc?.join("\n\n")}\n"),
                  ],
                ),
          ?equipment.desc!.isEmpty ? null : Divider(thickness: 2.5),
          heading("Equipment Category: "),
          Text("${equipment.equipmentCategory!["name"]}"),
          ?equipment.armourCategory == null
              ? null
              : Text("Amour category: ${equipment.armourCategory}"),
          ?equipment.armourClass == null
              ? null
              : Text("Amour Class: ${equipment.armourClass!["base"]}"),
          ?(equipment.armourClass != null &&
                  equipment.armourClass!.containsKey("max_bonus"))
              ? Text("Dexterity Bonus: ${equipment.armourClass!["max_bonus"]}")
              : null,
          ?equipment.weaponCategory == null
              ? null
              : Text("weapon category: ${equipment.weaponCategory}"),
          ?equipment.weaponRange == null
              ? null
              : Text("weapon range: ${equipment.weaponRange}"),
          ?equipment.categoryRange == null
              ? null
              : Text("category range: ${equipment.categoryRange}"),
          ?equipment.cost!.isEmpty
              ? null
              : Text(
                  "cost: ${equipment.cost!["quantity"]} ${equipment.cost!["unit"]}",
                ),
          ?equipment.damage == null
              ? null
              : Text("damage: ${equipment.damage}"),
          ?equipment.range == null ? null : Text("range: ${equipment.range}"),
          ?equipment.weight == null
              ? null
              : Text("weight: ${equipment.weight}"),
          ?equipment.properties!.isEmpty
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Properties"),
                    displayListDict(equipment.properties),
                  ],
                ),
          ?equipment.special!.isEmpty
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Special"),
                    Text("${equipment.special}"),
                    SizedBox(height: 10),
                  ],
                ),
          ?equipment.contents!.isEmpty
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Contents"),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: equipment.contents!.length,
                      itemBuilder: (context, index) {
                        return Text(
                          "${equipment.contents![index]["quantity"]}, "
                          "${equipment.contents![index]["item"]["name"]}",
                        );
                      },
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  // method that returns a widget that displays all the information about a
  // monster, by displaying all fields of the monster object
  Widget buildMonster(Monster monster) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white),
        child: ListView(
          children: [
            title("Stats"),
            heading("Challenge Rating: ${monster.challengeRating}"),
            subHeading("XP: ${monster.xp}"),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Size: ${monster.size}"),
                      Text("Type: ${monster.type}"),
                      Text("Alignment: ${monster.alignment!}"),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      SizedBox(width: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Armour Class: ${monster.armour![0]["value"]}"),
                          Text("Armour Type: ${monster.armour![0]["type"]}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hit Points: ${monster.hitPoints}"),
                    Text("Hit Dice: ${monster.hitDice}"),
                    Text("Hit Points Roll: ${monster.hitPointsRoll}"),
                  ],
                ),
                SizedBox(width: 60),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Proficiency Bonus: ${monster.proficiencyBonus}"),
                    SizedBox(width: 100, child: displayDict(monster.speed)),
                  ],
                ),
              ],
            ),
            Divider(),
            heading("Ability Scores"),
            Row(
              children: [
                displayProf(monster.proficiencies),
                displayScores(monster),
              ],
            ),
            Divider(),
            ?monster.damageVulnerabilities!.isEmpty
                ? null
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading("Damage Vulnerabilities"),
                      Text(
                        "Damage Vulnerabilities: ${monster.damageVulnerabilities!.join(", ")}",
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
            ?monster.damageResistances!.isEmpty
                ? null
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading("Damage Resistances"),
                      Text(
                        "Damage Resistances: ${monster.damageResistances!.join(", ")}",
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
            ?monster.damageImmunities!.isEmpty
                ? null
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading("Damage Immunities"),
                      Text(
                        "Damage Immunities: ${monster.damageImmunities!.join(", ")}",
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
            ?monster.conditionImmunities!.isEmpty
                ? null
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading("Condition Immunities"),
                      Text(
                        "Condition Immunities: ${monster.conditionImmunities!.join(", ")}",
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
            heading("Senses"),
            displayDict(monster.senses),
            SizedBox(height: 10),
            heading("Languages"),
            Text("${monster.languages}"),
            SizedBox(height: 10),
            Divider(thickness: 2.5),
            ?monster.specialAbilities!.isEmpty
                ? null
                : title("Special Abilities"),
            ?monster.specialAbilities!.isEmpty
                ? null
                : displayListDict(monster.specialAbilities),
            ?monster.actions!.isEmpty ? null : Divider(thickness: 2.5),
            ?monster.actions!.isEmpty ? null : title("Actions"),
            ?monster.actions!.isEmpty ? null : displayListDict(monster.actions),
            ?monster.legendaryActions!.isEmpty ? null : Divider(thickness: 2.5),
            ?monster.legendaryActions!.isEmpty
                ? null
                : title("Legendary Actions"),
            ?monster.legendaryActions!.isEmpty
                ? null
                : displayListDict(monster.legendaryActions),
            ?monster.reactions!.isEmpty ? null : Divider(thickness: 2.5),
            ?monster.reactions!.isEmpty ? null : title("Reactions"),
            ?monster.reactions!.isEmpty
                ? null
                : displayListDict(monster.reactions),
          ],
        ),
      ),
    );
  }

  // method that returns a widget that displays the contents of a dictionary
  // Used to get the name and descriptions of items from API calls
  // or if the dictionary only contains only displays the names
  Widget displayDict(Map<String, dynamic>? dict) {
    List<String> dictKeys = dict!.keys.toList();

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: dict.length,
      itemBuilder: (context, index) {
        final key = dictKeys[index];
        final value = dict[key];

        return key == "name"
            ? Text("$value")
            : Text(
                "${key.split('_').map((w) => w.capitalize()).join(' ')}: $value",
              );
      },
    );
  }

  // method that returns a widget that displays the contents of a list of
  // dictionaries. Used to get the name and descriptions of items from API calls
  Widget displayListDict(List<dynamic>? list) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: list!.length,
      itemBuilder: (context, index) {
        return list[index].keys.toList().contains("desc")
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heading("${list[index]["name"]}:"),
                  Text("${list[index]["desc"]}"),
                  SizedBox(height: 10),
                ],
              )
            : Text("${list[index]["name"]}");
      },
    );
  }

  // method that returns a widget that displays a monster's proficients
  Widget displayProf(List<dynamic>? prof) {
    return Expanded(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: prof!.length,
        itemBuilder: (context, index) {
          return Text(
            "${prof[index]["proficiency"]["name"]}: +${prof[index]["value"]}",
          );
        },
      ),
    );
  }

  // method that returns a widget that displays a monsters stat scores in a
  // grid form using row and column widgets
  Widget displayScores(Monster monster) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(children: [Text("Strength"), Text("${monster.strength}")]),
            Column(children: [Text("Dexterity"), Text("${monster.dexterity}")]),
            Column(
              children: [Text("Constitution"), Text("${monster.constitution}")],
            ),
          ],
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [Text("Intelligence"), Text("${monster.intelligence}")],
            ),
            Column(children: [Text("Wisdom"), Text("${monster.wisdom}")]),
            Column(children: [Text("Charisma"), Text("${monster.charisma}")]),
          ],
        ),
      ],
    );
  }

  // widget that displays roleplay tips from a background
  Widget displayRolePlay(Map<String, dynamic>? guide) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: guide!["from"]["options"].length,
        itemBuilder: (context, index) {
          return Text("${guide["from"]["options"][index]["string"]}");
        },
      ),
    );
  }

  Widget displayOptions(List<dynamic>? optionSet) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: optionSet!.length,
      itemBuilder: (context, index) {
        return Text(
          "Choose: ${optionSet[index]["choose"]}\n ${optionSet[index]["desc"]}",
        );
      },
    );
  }

  // method that returns widget displaying all levels of a player class and
  // the information about each level
  // this requires API calls nested in previous responses
  Widget displayLevel(Map<String, dynamic>? level, {bool subclass = false}) {
    if (level == null) {
      return Text("level");
    } else {
      String classType = "class";
      if (subclass) {
        classType = "subclass";
      }
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title("Level: ${level["level"]}"),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: level["features"].length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("${level["features"][index]["name"]}"),
                    FutureBuilder(
                      future: fetchData("${level["features"][index]["url"]}"),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text("${snapshot.data!["desc"].join("\n\n")}");
                        } else {
                          return CircularProgressIndicator(
                            color: Color(0xFF1E1B18),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            ),
            ?level.keys.contains("spellcasting")
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading("Spellcasting"),
                      SizedBox(
                        width: 200,
                        child: displayDict(level["spellcasting"]),
                      ),
                      SizedBox(height: 10),
                    ],
                  )
                : null,
            ?level.keys.contains("${classType}_specific")
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading("${classType.capitalize()} Specific"),
                      SizedBox(
                        width: 200,
                        child: SizedBox(
                          width: 200,
                          child: displayDict(level["${classType}_specific"]),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  )
                : null,
          ],
        ),
      );
    }
  }

  // method that returns a widget to display the languages from the game,
  // fetched from the API
  Widget futureLanguages() {
    return FutureBuilder(
      future: fetchResponse("/api/2014/languages"),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GridView.builder(
            padding: EdgeInsets.all(0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              childAspectRatio: 8,
              crossAxisCount: 2,
            ),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.count,
            itemBuilder: (context, index) {
              return Text(snapshot.data!.results![index]["name"]);
            },
          );
        } else {
          return CircularProgressIndicator(color: Color(0xFF1E1B18));
        }
      },
    );
  }

  // method that Calls the API for the item using its category and endpoint
  Future<Content> fetchContent() async {
    // make API call
    final response = await http.get(
      Uri.parse(
        'https://www.dnd5eapi.co/api/2014/${widget.category}/${widget.endpoint}',
      ),
    );

    // if successful
    if (response.statusCode == 200) {
      // depending on the category of the object build a different object
      // from the response
      if (widget.category == "races") {
        return Race.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else if (widget.category == "backgrounds") {
        return Background.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else if (widget.category == "classes") {
        return PlayerClass.fromJson(
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

  // method for basic API call
  // used when response is very specific, only returns JSON converted to map
  Future<Map<String, dynamic>> fetchData(String? url) async {
    // Make API call
    final response = await http.get(
      Uri.parse("https://www.dnd5eapi.co${url!}"),
    );

    // if successful return JSON in map form
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      // otherwise throw exception
      throw Exception("Failed to load content");
    }
  }

  // method that makes an API call to get the languages in the game
  // languages response has the same fields as Response object
  Future<Response> fetchResponse(String url) async {
    // make API call
    final response = await http.get(Uri.parse('https://www.dnd5eapi.co$url'));

    // if successful return response as map
    if (response.statusCode == 200) {
      return Response.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      // otherwise throw exception
      throw Exception("Failed to load response");
    }
  }

  // method that makes API call to get all levels of a class
  // API response is a list of dictionaries
  Future<List<dynamic>> fetchLevels(String? url) async {
    // make API call
    final response = await http.get(
      Uri.parse("https://www.dnd5eapi.co${url!}"),
    );

    // if successful return response
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // otherwise throw exception
      throw Exception("Failed to load levels");
    }
  }

  // Text widget that displays text in title format
  Widget title(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Color(0xFFA23E2E),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Text widget that displays text in heading format
  Widget heading(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Color(0xFFC2A878),
        fontSize: 18,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  // Text widget that displays text in subheading format
  Widget subHeading(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Color(0xFF1E1B18),
        fontSize: 16,
        decoration: TextDecoration.underline,
        decorationThickness: 1.5,
      ),
    );
  }
}

// Extension of Flutter String class
extension StringExtension on String {
  // method that capitalized the first letter of a strong
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
