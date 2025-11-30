/*
This page displays the Selected character,
 */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dnd_app/character_class.dart';
import 'package:http/http.dart' as http;
import 'package:dnd_app/screens/characters.dart';

import 'new_character_form.dart';

class singleCharacter extends StatefulWidget {
  final String username;
  final Character character;
  const singleCharacter({
    super.key,
    required this.character,
    required this.username,
  });

  @override
  State<singleCharacter> createState() => singleCharacterState();
}

class singleCharacterState extends State<singleCharacter> {
  late final u = widget.username;
  Future<void> _showSpellInfo(String index) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.dnd5eapi.co/api/2014/spells/$index'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load spell $index: ${response.body}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final details = SpellDetails.fromJson(json);

      if (!mounted) return;

      final componentsString = details.components.join('');
      final concString = details.concentration ? 'Yes' : 'No';
      final ritualString = details.ritual ? 'Yes' : 'No';
      final hasMaterial =
          details.material != null && details.material!.trim().isNotEmpty;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(details.name),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Level: ${details.levelLabel}'),
                  const SizedBox(height: 4),
                  Text('School: ${details.school}'),
                  const SizedBox(height: 4),
                  Text('Duration: ${details.duration}'),
                  const SizedBox(height: 4),
                  Text('Range: ${details.range}'),
                  const SizedBox(height: 4),
                  Text('Components: $componentsString'),
                  const SizedBox(height: 4),
                  Text('Concentration: $concString'),
                  const SizedBox(height: 4),
                  Text('Ritual: $ritualString'),
                  if (hasMaterial) ...[
                    const SizedBox(height: 4),
                    Text('Materials: ${details.material}'),
                  ],
                  const SizedBox(height: 12),
                  Text(details.description),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load spell info: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;

    // Quick ability map so we can grid them nicely
    final abilities = [
      {'label': 'STR', 'score': c.strength},
      {'label': 'DEX', 'score': c.dexterity},
      {'label': 'CON', 'score': c.constitution},
      {'label': 'INT', 'score': c.intelligence},
      {'label': 'WIS', 'score': c.wisdom},
      {'label': 'CHA', 'score': c.charisma},
    ];

    int _mod(int score) => ((score - 10) ~/ 2);

    return Scaffold(
      appBar: AppBar(
        title: Text("Selected Character: ${c.name}"),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CharacterPage(thisUsername: u),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        c.name ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${c.race}  •  ${c.Class}',
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${c.level}  •  Alignment: ${c.alignment}',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              //This Card shows their Combat stats
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Combat Stats',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _statBox('HP', c.hp.toString()),
                          _statBox('AC', c.armorClass.toString()),
                          _statBox('Init', c.initiative.toString()),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _statBox('Speed', c.speed.toString()),
                          _statBox('Prof', c.proficiencies.toString()),
                          _statBox(
                            'Passive Perception',
                            c.passivePerception.toString(),
                            flex: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              //This Card shows their Spell Casting Ability, even if they don't cast spells
              //This should still show, so the user know's their spell save DC
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spellcasting',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _statBox(
                            'Spell Mod',
                            '${c.spellCastingAbility['Spell Casting Modifier']}',
                            flex: 1,
                          ),
                          _statBox(
                            'Save DC',
                            '${c.spellCastingAbility['Spell Save DC']}',
                            flex: 1,
                          ),
                          _statBox(
                            'Atk Bonus',
                            '${c.spellCastingAbility['Spell Attack Bonus']}',
                            flex: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              //This Card shows their Ability Scores and their modifiers
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ability Scores',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.1,
                        children: [
                          for (final ability in abilities)
                            _abilityBox(
                              ability['label'] as String,
                              ability['score'] as int?,
                              (score) => _mod(score),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              //This card shows the Skills that they chose
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Proficiencies\n',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        const TextSpan(
                          text: '--------\n',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        for (var entry in c.skillBonuses.entries)
                          if (entry.value)
                            TextSpan(
                              text: '${entry.key}\n',
                              style: const TextStyle(fontSize: 18),
                            ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              //This Card shows the traits from their race, as long as they have 1 or more
              if ((c.traits as List).isNotEmpty)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: RichText(
                      text: TextSpan(
                        text: 'Traits\n',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          const TextSpan(
                            text: '--------\n',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          for (var i in (c.traits as List<String>))
                            TextSpan(
                              text: '$i\n',
                              style: const TextStyle(fontSize: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              //This card only shows if they are a spellcaster
              //It shows them how many of each level spell they can cast before they have to rest
              if (c.spellSlots['Level 1'] != 0)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: RichText(
                      text: TextSpan(
                        text: 'Spell Slots\n',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          const TextSpan(
                            text: '-------\n',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          for (var entry in c.spellSlots.entries)
                            if (entry.value > 0)
                              TextSpan(
                                text: '${entry.key}: ${entry.value}\n',
                                style: const TextStyle(fontSize: 18),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              //This card shows the spells that they chose,
              // also has a button for a dialog that explains the spell
              if (c.spellSlots['Level 1'] != 0)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Spells",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: c.spells.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(c.spells[index]),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.info_outline),
                                      onPressed: () =>
                                          _showSpellInfo(c.spells[index]),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              //The rest of these cards are self explanatory
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Languages\n',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        const TextSpan(
                          text: '--------\n',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        for (var i in c.languages)
                          const TextSpan(), // placeholder
                        for (var i in c.languages)
                          TextSpan(
                            text: '$i\n',
                            style: const TextStyle(fontSize: 18),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Inventory\n',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        const TextSpan(
                          text: '--------\n',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        for (var i in c.inventory.entries)
                          TextSpan(
                            text: '${i.key}: ${i.value}\n',
                            style: const TextStyle(fontSize: 18),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Backstory',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.background ?? '',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.appearance ?? '',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Helper Widgets to display certain information

  Widget _statBox(String label, String value, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _abilityBox(
    String label,
    int? score,
    int Function(int) modCalculator,
  ) {
    if (score == null) {
      return Container();
    }
    final mod = modCalculator(score);
    final modStr = mod >= 0 ? '+$mod' : '$mod';

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(score.toString(), style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text('($modStr)', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
