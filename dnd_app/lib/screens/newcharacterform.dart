// Form ui to create a new character

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dnd_app/character_databases.dart';
import 'package:dnd_app/backEnd.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'characters.dart';

final _formKey = GlobalKey<FormState>();

// Controllers for each text field
final _nameController = TextEditingController();
final _strengthController = TextEditingController();
final _dexterityController = TextEditingController();
final _constitutionController = TextEditingController();
final _intelligenceController = TextEditingController();
final _wisdomController = TextEditingController();
final _charismaController = TextEditingController();
final _armorClassController = TextEditingController();
final _appearanceController = TextEditingController();

int? hp = 0;
int? strength = 0;
int? dexterity = 0;
int? intelligence = 0;
int? constitution = 0;
int? wisdom = 0;
int? charisma = 0;
String? name;
String? race;
int? level = 1;
int? armorClass = 0;
int? initiative = 0;
int? speed = 0;
int? passivePerception = 10;
String? background;
String? alignment;
String? appearance;
String size = 'Small';

Map<String, int>? charClass;
String? selectedClass;
Map<String, bool> skillBonuses = {
  'Athletics': false,
  'Acrobatics': false,
  'Sleight of Hand': false,
  'Stealth': false,
  'Arcana': false,
  'History': false,
  'Investigation': false,
  'Nature': false,
  'Religion': false,
  'Animal Handling': false,
  'Insight': false,
  'Medicine': false,
  'Perception': false,
  'Survival': false,
  'Deception': false,
  'Intimidation': false,
  'Performance': false,
  'Persuasion': false,
};
Map<String, int> inventory = {'Gold': 100};
Map<String, int> spellCastingAbility = {
  'Spell Casting Modifier': 0,
  'Spell Save DC:': 0,
  'Spell Attack Bonus': 0,
};
Map<String, int> spellSlots = {
  'Level 1': 0,
  'Level 2': 0,
  'Level 3': 0,
  'Level 4': 0,
  'Level 5': 0,
  'Level 6': 0,
  'Level 7': 0,
  'Level 8': 0,
  'Level 9': 0,
};
Map<String, dynamic>? abilityBonus;

List<String> features = [];
List<String>? traits;
List<String>? equipment;
int proficiencies = 2;
List<String> languages = [];
List<String>? raceLanguages;
List<String> selectedSpells = [];

class NewCharacterForm extends StatefulWidget {
  const NewCharacterForm({super.key});

  @override
  State<NewCharacterForm> createState() => _NewCharacterFormState();
}

class _NewCharacterFormState extends State<NewCharacterForm> {
  // Form key for validation - Gives access to form widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Character')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Let's start with the hardest choice",
                style: TextStyle(
                  color: Color(0xFFA23E2E),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Name your character",
                style: TextStyle(color: Color(0xFFA23E2E), fontSize: 15.0),
              ),
              // Name field
              TextField(
                textAlign: TextAlign.center,
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Character Name',
                  hintStyle: TextStyle(
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ),

              SizedBox(height: 20.0),

              // ===============================
              // SUBMIT BUTTON
              // ===============================
              ElevatedButton(
                onPressed: () {
                  // Validate all form fields before proceeding
                  if (_formKey.currentState!.validate()) {
                    //setState(() async {
                    // STEP 2: return character object
                    name = _nameController.text;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RaceSelector()),
                    );
                    //});
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RaceSelector extends StatefulWidget {
  const RaceSelector({super.key});

  @override
  State<RaceSelector> createState() => _RaceSelectorState();
}

class _RaceSelectorState extends State<RaceSelector> {
  final List<String> options = [
    'Dragonborn',
    'Dwarf',
    'Elf',
    'Gnome',
    'Half-Elf',
    'Half-Orc',
    'Halfling',
    'Human',
    'Tiefling',
  ];

  Future<void> getRaceInfo() async {
    final response = await http.get(
      Uri.parse(
        'https://www.dnd5eapi.co/api/2014/races/${race?.toLowerCase()}',
      ),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        speed = decoded['speed'];
        final bonusesList = decoded['ability_bonuses'] as List<dynamic>?;

        if (bonusesList == null || bonusesList.isEmpty) {
          // No bonuses for this race
          abilityBonus = null;
        } else {
          abilityBonus = {
            for (final b in bonusesList)
              (b['ability_score']['name'] as String): b['bonus'] as int,
          };
        }
        size = decoded['size'];

        final raceLangList = decoded['languages'] as List<dynamic>;

        raceLanguages = raceLangList
            .map((t) => (t as Map<String, dynamic>)['name'] as String)
            .toList();

        final traitList = decoded['traits'] as List<dynamic>;

        traits = traitList
            .map((t) => (t as Map<String, dynamic>)['name'] as String)
            .toList();
      });
    } else {
      throw Exception('Failed to load Race Info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose your race")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              initialValue: race,
              decoration: InputDecoration(
                hintText: 'Select a Race',
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              isExpanded: true,
              items: options.map((text) {
                return DropdownMenuItem<String>(
                  value: text,
                  child: Center(child: Text(text)),
                );
              }).toList(),
              onChanged: (value) {
                race = value!;
                setState(() {
                  getRaceInfo();
                });
              },
            ),
            SizedBox(height: 16.0),
            if (race == 'Dragonborn')
              Column(
                children: [
                  Image.asset(
                    'assets/images/Dragonborn.jpg',
                    width: 250,
                    height: 250, //500
                    fit: BoxFit.cover, // Try cover, contain, fill
                  ),
                  Text(
                    "Source: https://mythopedia.com/name-generator/dnd-dragonborn-names",
                    style: TextStyle(fontSize: 8),
                  ),
                ],
              ),

            if (race == 'Dwarf')
              Column(
                children: [
                  Image.asset(
                    'assets/images/Dwarf.png',
                    width: 250,
                    height: 250, //500
                    fit: BoxFit.contain, // Try cover, contain, fill
                  ),
                  Text(
                    "Source: https://www.dndbeyond.com/species/13-dwarf",
                    style: TextStyle(fontSize: 8),
                  ),
                ],
              ),

            if (race == 'Elf')
              Column(
                children: [
                  Image.asset(
                    'assets/images/Elf.png',
                    width: 250,
                    height: 250, //500
                    fit: BoxFit.contain, // Try cover, contain, fill
                  ),
                  Text(
                    "Source: https://astral-reach.fandom.com/wiki/Elves",
                    style: TextStyle(fontSize: 8),
                  ),
                ],
              ),

            if (race == 'Gnome')
              Column(
                children: [
                  Image.asset(
                    'assets/images/Gnome.png',
                    width: 250,
                    height: 250, //500
                    fit: BoxFit.contain, // Try cover, contain, fill
                  ),
                  Text(
                    "Source: https://criticalrole.miraheze.org/wiki/Gnome",
                    style: TextStyle(fontSize: 8),
                  ),
                ],
              ),

            if (race == 'Half-Elf')
              Column(
                children: [
                  Image.asset(
                    'assets/images/Half-Elf.png',
                    width: 250,
                    height: 250, //500
                    fit: BoxFit.contain, // Try cover, contain, fill
                  ),
                  Text(
                    "Source: www.dndbeyond.com/species/20-half-elf",
                    style: TextStyle(fontSize: 8),
                  ),
                ],
              ),

            if (race == 'Half-Orc')
              Column(
                children: [
                  Image.asset(
                    'assets/images/Half-Orc.png',
                    width: 250,
                    height: 250, //500
                    fit: BoxFit.contain, // Try cover, contain, fill
                  ),
                  Text(
                    "Source: www.dndbeyond.com/species/2-half-orc",
                    style: TextStyle(fontSize: 8),
                  ),
                ],
              ),

            if (race == 'Halfling')
              Column(
                children: [
                  Image.asset(
                    'assets/images/Halfling.png',
                    width: 250,
                    height: 250, //500
                    fit: BoxFit.contain, // Try cover, contain, fill
                  ),
                  Text(
                    "Source: www.dndbeyond.com/species/14-halfling",
                    style: TextStyle(fontSize: 8),
                  ),
                ],
              ),

            if (race == 'Human')
              Column(
                children: [
                  Image.asset(
                    'assets/images/Human.png',
                    width: 250,
                    height: 250, //500
                    fit: BoxFit.contain, // Try cover, contain, fill
                  ),
                  Text(
                    "Source: www.dndbeyond.com/species/1-human",
                    style: TextStyle(fontSize: 8),
                  ),
                ],
              ),

            if (race == 'Tiefling')
              Column(
                children: [
                  Image.asset(
                    'assets/images/Tiefling.png',
                    width: 250,
                    height: 250, //500
                    fit: BoxFit.contain, // Try cover, contain, fill
                  ),
                  Text(
                    "Source: www.dndbeyond.com/species/7-tiefling",
                    style: TextStyle(fontSize: 8),
                  ),
                ],
              ),
            SizedBox(height: 16.0),
            Text('Speed: ${speed.toString()}'),
            Text('Size: $size'),
            SizedBox(height: 16.0),
            Text(
              '$race Ability Bonuses',
              style: TextStyle(
                color: Color(0xFFA23E2E),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (abilityBonus != null)
              for (final entry in abilityBonus!.entries)
                Text('${entry.key} +${entry.value}'),
            SizedBox(height: 16.0),
            Text(
              "Languages Known as $race",
              style: TextStyle(
                color: Color(0xFFA23E2E),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (raceLanguages != null && raceLanguages!.isNotEmpty)
              for (var j in raceLanguages!) Text(j),
            SizedBox(height: 16.0),
            Text(
              "$race traits",
              style: TextStyle(
                color: Color(0xFFA23E2E),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (traits != null && traits!.isNotEmpty)
              for (var i in traits!) Text(i),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SelectClass()),
                  );
                },
                child: Text("Confirm"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectClass extends StatefulWidget {
  const SelectClass({super.key});

  @override
  State<SelectClass> createState() => SelectClassState();
}

class SelectClassState extends State<SelectClass> {
  String? skillDesc;
  List<String?> selectedSkills = [];
  int? skillCount;
  final List<String> options = [
    'Barbarian',
    'Bard',
    'Cleric',
    'Druid',
    'Fighter',
    'Monk',
    'Paladin',
    'Ranger',
    'Rogue',
    'Sorcerer',
    'Warlock',
    'Wizard',
  ];
  List<String>? skills;
  Future<void> getSkills(String selectedClass) async {
    final response = await http.get(
      Uri.parse(
        'https://www.dnd5eapi.co/api/classes/${selectedClass.toLowerCase()}',
      ),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      // proficiency_choices can be missing or empty
      final choices = decoded['proficiency_choices'] as List<dynamic>? ?? [];

      if (choices.isEmpty) {
        setState(() {
          skills = [];
          skillCount = 0;
          skillDesc = 'This class has no proficiency choices.';
          selectedSkills = [];
        });
        return;
      }

      final firstChoice = choices.first as Map<String, dynamic>;

      final options = firstChoice['from']['options'] as List<dynamic>? ?? [];

      if (options.isEmpty) {
        setState(() {
          skills = [];
          skillCount = 0;
          skillDesc = 'No options available for this class.';
          selectedSkills = [];
        });
        return;
      }

      final names = options
          .map((opt) => (opt['item'] as Map<String, dynamic>)['name'] as String)
          .toList();

      final count = firstChoice['choose'] as int;

      setState(() {
        skills = names;
        skillCount = count;
        skillDesc = firstChoice['desc'] as String;
        selectedSkills = List<String?>.filled(count, null);
        hp = decoded['hit_die'];
      });
    } else {
      debugPrint(
        'Error fetching skills: ${response.statusCode} ${response.body}',
      );
      throw Exception('Failed to load skills');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose your class")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("You will start at level 1"),
            SizedBox(height: 8.0),
            Text("You will be able to level up later"),
            SizedBox(height: 8.0),
            Text("For now, choose your first class"),
            DropdownButtonFormField<String>(
              initialValue: selectedClass,
              decoration: InputDecoration(
                hintText: "Select a Class",
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              isExpanded: true,
              items: options.map((text) {
                return DropdownMenuItem<String>(
                  value: text,
                  child: Center(child: Text(text)),
                );
              }).toList(),
              onChanged: (value) async {
                if (value == null) return;

                setState(() {
                  selectedClass = value;
                  charClass ??= {};
                  charClass![selectedClass!] = 1;
                  skillDesc = null;
                  skills = null;
                  skillCount = null;
                });

                await getSkills(value);
              },
            ),
            SizedBox(height: 8.0),
            if (skillDesc != null) ...[
              Text(skillDesc!),
              const SizedBox(height: 8.0),
            ],
            if (skills != null &&
                skills!.isNotEmpty &&
                skillCount != null &&
                skillCount! > 0 &&
                selectedSkills.length == skillCount)
              Expanded(
                child: ListView.builder(
                  itemCount: skillCount!,
                  itemBuilder: (context, index) {
                    final String? currentValue = index < selectedSkills.length
                        ? selectedSkills[index]
                        : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: DropdownButtonFormField<String>(
                        initialValue: currentValue,
                        decoration: InputDecoration(
                          labelText: 'Skill ${index + 1}',
                          border: const OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: skills!
                            .map(
                              (skill) => DropdownMenuItem<String>(
                                value: skill,
                                child: Text(skill),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSkills[index] = value;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  skillBonuses.updateAll(
                    (key, value) => selectedSkills.contains(key),
                  );
                  if (selectedClass == 'Bard' ||
                      selectedClass == 'Druid' ||
                      selectedClass == 'Cleric' ||
                      selectedClass == 'Wizard' ||
                      selectedClass == 'Sorcerer' ||
                      selectedClass == 'Warlock') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => pickSpells()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => statsPage()),
                    );
                  }
                },
                child: Text("Confirm"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class pickSpells extends StatefulWidget {
  const pickSpells({super.key});

  @override
  State<pickSpells> createState() => pickSpellsState();
}

class SpellSummary {
  final String index;
  final String name;
  final int level; // 0 = cantrip, 1 = level 1

  SpellSummary({required this.index, required this.name, required this.level});
}

class SpellDetails {
  final String index;
  final String name;
  final int level;
  final String school;
  final String duration;
  final String range;
  final List<String> components;
  final bool concentration;
  final bool ritual;
  final String? material;
  final String description;

  SpellDetails({
    required this.index,
    required this.name,
    required this.level,
    required this.school,
    required this.duration,
    required this.range,
    required this.components,
    required this.concentration,
    required this.ritual,
    required this.material,
    required this.description,
  });

  factory SpellDetails.fromJson(Map<String, dynamic> json) {
    final descList = (json['desc'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return SpellDetails(
      index: json['index'] as String,
      name: json['name'] as String,
      level: json['level'] as int,
      school: (json['school']?['name'] as String?) ?? 'Unknown',
      duration: json['duration'] as String? ?? 'Unknown',
      range: json['range'] as String? ?? 'Unknown',
      components: (json['components'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      concentration: json['concentration'] as bool? ?? false,
      ritual: json['ritual'] as bool? ?? false,
      material: json['material'] as String?,
      description: descList.join('\n\n'),
    );
  }

  String get levelLabel => level == 0 ? 'Cantrip' : 'Level $level';
}

class pickSpellsState extends State<pickSpells> {
  bool _isLoading = true;
  String? _error;

  int _cantripLimit = 0;
  int _level1Limit = 0;
  List<String> _autoLevel1SpellIndices = []; // for cleric

  List<SpellSummary> _cantripSpells = [];
  List<SpellSummary> _level1Spells = [];

  final Map<String, SpellDetails> _detailsCache = {};

  @override
  void initState() {
    super.initState();
    _configureLimits();
    _loadSpells();
  }

  void _configureLimits() {
    final cls = selectedClass?.toLowerCase();

    switch (cls) {
      case 'druid':
        _cantripLimit = 2;
        _level1Limit = 0;
        _autoLevel1SpellIndices = [];
        break;
      case 'bard':
        _cantripLimit = 2;
        _level1Limit = 4;
        _autoLevel1SpellIndices = [];
        break;
      case 'wizard':
        _cantripLimit = 3;
        _level1Limit = 6;
        _autoLevel1SpellIndices = [];
        break;
      case 'sorcerer':
        _cantripLimit = 4;
        _level1Limit = 2;
        _autoLevel1SpellIndices = [];
        break;
      case 'warlock':
        _cantripLimit = 2;
        _level1Limit = 2;
        _autoLevel1SpellIndices = [];
        break;
      case 'cleric':
        _cantripLimit = 3;
        _level1Limit = 0; // they don't choose L1 spells
        _autoLevel1SpellIndices = ['bless', 'cure-wounds'];
        break;
      default:
        _cantripLimit = 0;
        _level1Limit = 0;
        _autoLevel1SpellIndices = [];
    }
  }

  Future<void> _loadSpells() async {
    try {
      final clsIndex = selectedClass?.toLowerCase();
      if (clsIndex == null) {
        setState(() {
          _isLoading = false;
          _error = 'No class selected.';
        });
        return;
      }

      final classResp = await http.get(
        Uri.parse('https://www.dnd5eapi.co/api/2014/classes/$clsIndex/spells'),
      );

      if (classResp.statusCode != 200) {
        throw Exception('Failed to load class spells: ${classResp.body}');
      }

      final decoded = jsonDecode(classResp.body) as Map<String, dynamic>;
      final results = decoded['results'] as List<dynamic>? ?? [];

      final List<SpellSummary> cantrips = [];
      final List<SpellSummary> level1 = [];

      for (final s in results) {
        final index = s['index'] as String;

        final details = await _fetchSpellDetails(index);

        if (details.level == 0) {
          cantrips.add(
            SpellSummary(index: details.index, name: details.name, level: 0),
          );
        } else if (details.level == 1) {
          level1.add(
            SpellSummary(index: details.index, name: details.name, level: 1),
          );
        }
      }

      if (_autoLevel1SpellIndices.isNotEmpty) {
        for (final idx in _autoLevel1SpellIndices) {
          if (!selectedSpells.contains(idx)) {
            selectedSpells.add(idx);
          }
        }
      }

      setState(() {
        _cantripSpells = cantrips;
        _level1Spells = level1;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<SpellDetails> _fetchSpellDetails(String index) async {
    if (_detailsCache.containsKey(index)) {
      return _detailsCache[index]!;
    }

    final resp = await http.get(
      Uri.parse('https://www.dnd5eapi.co/api/2014/spells/$index'),
    );

    if (resp.statusCode != 200) {
      throw Exception('Failed to load spell $index: ${resp.body}');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final details = SpellDetails.fromJson(json);
    _detailsCache[index] = details;
    return details;
  }

  bool _isSelected(SpellSummary spell) {
    return selectedSpells.contains(spell.index);
  }

  int _selectedCantripCount() {
    return _cantripSpells
        .where((spell) => selectedSpells.contains(spell.index))
        .length;
  }

  int _selectedLevel1Count() {
    return _level1Spells
        .where((spell) => selectedSpells.contains(spell.index))
        .length;
  }

  void _toggleSpell(SpellSummary spell) {
    final isCantrip = spell.level == 0;
    final isLevel1 = spell.level == 1;
    final cls = selectedClass?.toLowerCase();

    if (!isCantrip && !isLevel1) {
      return;
    }

    final alreadySelected = _isSelected(spell);

    if (alreadySelected) {
      setState(() {
        selectedSpells.remove(spell.index);
      });
      return;
    }

    if (isCantrip) {
      final count = _selectedCantripCount();
      if (count >= _cantripLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can only select $_cantripLimit cantrip(s) as a $selectedClass.',
            ),
          ),
        );
        return;
      }
    } else if (isLevel1) {
      if (cls == 'cleric') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clerics automatically know Bless and Cure Wounds.'),
          ),
        );
        return;
      }

      final count = _selectedLevel1Count();
      if (count >= _level1Limit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can only select $_level1Limit level 1 spell(s) as a $selectedClass.',
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      selectedSpells.add(spell.index);
    });
  }

  Future<void> _showSpellInfo(SpellSummary summary) async {
    try {
      final details = await _fetchSpellDetails(summary.index);

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

  Widget _buildSpellRow(SpellSummary spell) {
    final selected = _isSelected(spell);

    final isCleric = selectedClass?.toLowerCase() == 'cleric';
    final isLevel1 = spell.level == 1;
    final isAutoClericLevel1 =
        isCleric && isLevel1 && _autoLevel1SpellIndices.contains(spell.index);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(spell.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAutoClericLevel1)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text(
                  'Automatic',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              )
            else
              TextButton(
                onPressed: () => _toggleSpell(spell),
                child: Text(selected ? 'Deselect' : 'Select'),
              ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showSpellInfo(spell),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cantripSelected = _selectedCantripCount();
    final level1Selected = _selectedLevel1Count();

    return Scaffold(
      appBar: AppBar(title: const Text("Select your Spells")),
      body: _isLoading
          ? Center(
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Loading, This may take a while..."),
                  SizedBox(height: 8.0),
                  CircularProgressIndicator(),
                ],
              ),
            )
          : _error != null
          ? Center(child: Text(_error!))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Class: $selectedClass',
                    style: TextStyle(
                      color: Color(0xFFA23E2E),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cantrips: choose $_cantripLimit '
                    '(selected: $cantripSelected)',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Level 1 spells: choose $_level1Limit '
                    '(selected: $level1Selected)',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 18,
                    ),
                  ),
                  if (selectedClass?.toLowerCase() == 'cleric')
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        'As a Cleric, you automatically know Bless and Cure Wounds.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        if (_cantripSpells.isNotEmpty) ...[
                          Text(
                            'Cantrips',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ..._cantripSpells.map(_buildSpellRow),
                          const SizedBox(height: 16),
                        ],
                        if (_level1Spells.isNotEmpty) ...[
                          Text(
                            'Level 1 Spells',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ..._level1Spells.map(_buildSpellRow),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const statsPage(),
                            ),
                          );
                        },
                        child: const Text('Confirm Spells'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class statsPage extends StatefulWidget {
  const statsPage({super.key});
  @override
  statsPageState createState() => statsPageState();
}

class statsPageState extends State<statsPage> {
  int strbonus = abilityBonus?["STR"] ?? 0;
  int dexbonus = abilityBonus?["DEX"] ?? 0;
  int conbonus = abilityBonus?["CON"] ?? 0;
  int intbonus = abilityBonus?["INT"] ?? 0;
  int wisbonus = abilityBonus?["WIS"] ?? 0;
  int chabonus = abilityBonus?["CHA"] ?? 0;
  int strTotal = 0;
  int dexTotal = 0;
  int conTotal = 0;
  int intTotal = 0;
  int wisTotal = 0;
  int chaTotal = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Character Stats")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Now it is time for you to roll for your stats"),
              SizedBox(height: 8.0),
              Text(
                "Roll a 20 sided dice for each of the stats below, and then enter the number in the Box",
              ),
              SizedBox(height: 16.0),
              Text("Strength"),
              SizedBox(height: 8.0),
              Text(
                "Strength measures bodily power, athletic training, and the extent to which you can exert raw physical forces.",
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: TextField(
                      textAlign: TextAlign.start,
                      controller: _strengthController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: 'base',
                        hintStyle: TextStyle(
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          strTotal =
                              (strbonus + int.parse(_strengthController.text));
                        });
                      },
                    ),
                  ),
                  Text(' +  $strbonus = $strTotal'),
                ],
              ),
              SizedBox(height: 16.0),
              Text("Dexterity"),
              SizedBox(height: 8.0),
              Text("Dexterity measures agility, reflexes, and balance."),
              SizedBox(height: 8.0),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: TextField(
                      textAlign: TextAlign.start,
                      controller: _dexterityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: 'base',
                        hintStyle: TextStyle(
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          dexTotal =
                              (dexbonus + int.parse(_dexterityController.text));
                        });
                      },
                    ),
                  ),
                  Text(' +  $dexbonus = $dexTotal'),
                ],
              ),
              SizedBox(height: 16.0),
              Text("Constitution"),
              SizedBox(height: 8.0),
              Text("Constitiution measures health, stamina, and vital force."),
              SizedBox(height: 8.0),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: TextField(
                      textAlign: TextAlign.start,
                      controller: _constitutionController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: 'base',
                        hintStyle: TextStyle(
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          conTotal =
                              (conbonus +
                              int.parse(_constitutionController.text));
                        });
                      },
                    ),
                  ),
                  Text(' +  $conbonus = $conTotal'),
                ],
              ),
              SizedBox(height: 16.0),
              Text("Intelligence"),
              SizedBox(height: 8.0),
              Text(
                "Intelligence measures mental acuity, accuracy of recall, and the ability to reason.",
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: TextField(
                      textAlign: TextAlign.start,
                      controller: _intelligenceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: 'base',
                        hintStyle: TextStyle(
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          intTotal =
                              (intbonus +
                              int.parse(_intelligenceController.text));
                        });
                      },
                    ),
                  ),
                  Text(' +  $intbonus = $intTotal'),
                ],
              ),
              SizedBox(height: 16.0),
              Text("Wisdom"),
              SizedBox(height: 8.0),
              Text(
                "Wisdom relfects how attuned you are to the world around you and represents perceptiveness and intuition.",
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: TextField(
                      textAlign: TextAlign.start,
                      controller: _wisdomController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: 'base',
                        hintStyle: TextStyle(
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          wisTotal =
                              (wisbonus + int.parse(_wisdomController.text));
                        });
                      },
                    ),
                  ),
                  Text(' +  $wisbonus = $wisTotal'),
                ],
              ),
              SizedBox(height: 16.0),
              Text("Charisma"),
              SizedBox(height: 8.0),
              Text(
                "Charisma measures your ability to interact effectively with others. it includes such factors as confidence and eloquence, and it can represent a charming or commanding personality.",
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: TextField(
                      textAlign: TextAlign.start,
                      controller: _charismaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: 'base',
                        hintStyle: TextStyle(
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          chaTotal =
                              (chabonus + int.parse(_charismaController.text));
                        });
                      },
                    ),
                  ),
                  Text(' +  $chabonus = $chaTotal'),
                ],
              ),
              SizedBox(height: 50.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    strength = strTotal;
                    dexterity = dexTotal;
                    constitution = conTotal;
                    intelligence = intTotal;
                    wisdom = wisTotal;
                    charisma = chaTotal;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const backgroundPage(),
                      ),
                    );
                  },
                  child: const Text('Confirm Stats'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class backgroundPage extends StatefulWidget {
  const backgroundPage({super.key});

  @override
  backgroundState createState() => backgroundState();
}

class backgroundState extends State<backgroundPage> {
  void addCharacter(Character character) async {
    final newCharacter = Character(
      hp: hp,
      strength: strength,
      dexterity: dexterity,
      intelligence: intelligence,
      constitution: constitution,
      wisdom: wisdom,
      charisma: charisma,
      name: name,
      race: race,
      level: level,
      armorClass: armorClass,
      initiative: initiative,
      speed: speed,
      passivePerception: passivePerception,
      background: "acolyte",
      alignment: alignment,
      charClass: charClass,
      skillBonuses: skillBonuses,
      features: features,
      traits: traits,
      proficiencies: proficiencies,
      languages: languages,
      size: size,
      inventory: inventory,
      equipment: equipment,
      spells: selectedSpells,
      spellCastingAbility: spellCastingAbility,
      spellSlots: spellSlots,
      appearance: appearance,
    );
    await CharacterDatabase.instance.create(newCharacter);
  }

  final List<String?> selectedExtra = List<String?>.filled(2, null);
  List<String> extralanguages = [
    'Abyssal',
    'Celestial',
    'Common Sign Language',
    'Deep Speech',
    'Dwarvish',
    'Elvish',
    'Giant',
    'Gnomish',
    'Goblin',
    'Halfling',
    'Infernal',
    'Orc',
    'Primordial',
    'Sylvan',
    'Undercommon',
  ];
  List<String> alignOptions = [
    'Lawful Good',
    'Neutral Good',
    'Chaotic Good',
    'Lawful Neutral',
    'True Neutral',
    'Chaotic Neutral',
    'Lawful Evil',
    'Neutral Evil',
    'Chaotic Evil',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Character Info")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Now lets get the rest of your Characters information"),
            SizedBox(height: 16.0),
            Text("Choose 2 Languages to learn."),
            SizedBox(height: 8.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedExtra[index],
                    decoration: InputDecoration(
                      labelText: 'Language ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    isExpanded: true,
                    items: extralanguages
                        .map(
                          (skill) => DropdownMenuItem<String>(
                            value: skill,
                            child: Text(skill),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedExtra[index] = value!;
                      });
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),
            Text("Choose your characters alignment"),
            DropdownButtonFormField<String>(
              initialValue: alignment,
              decoration: InputDecoration(
                hintText: "Select an alignment",
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              isExpanded: true,
              items: alignOptions.map((text) {
                return DropdownMenuItem<String>(
                  value: text,
                  child: Center(child: Text(text)),
                );
              }).toList(),
              onChanged: (value) async {
                if (value == null) return;
                alignment = value;
              },
            ),
            SizedBox(height: 16.0),
            Text("Enter your Characters Armor Class"),
            TextFormField(
              textAlign: TextAlign.center,
              controller: _armorClassController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: 'AC',
                hintStyle: TextStyle(
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  armorClass = int.parse(_armorClassController.text);
                });
              },
            ),
            SizedBox(height: 16.0),
            Text("Describe your characters appearance (optional)"),
            SizedBox(height: 8.0),
            TextFormField(
              textAlign: TextAlign.start,
              controller: _appearanceController,
              decoration: InputDecoration(
                hintText: 'How do they look',
                hintStyle: TextStyle(
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  appearance = _appearanceController.text;
                });
              },
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    for (var i in selectedExtra) {
                      languages.add(i!);
                    }
                    if (skillBonuses['perception'] == true) {
                      passivePerception =
                          ((((wisdom! - 10) ~/ 2) as int?)! + proficiencies);
                    } else {
                      passivePerception = (((wisdom! - 10) ~/ 2) as int?);
                    }
                    if (selectedClass == 'Wizard') {
                      spellCastingAbility['Spell Casting Modifier'] =
                          (((intelligence! - 10) ~/ 2));
                    } else if (selectedClass == 'Cleric' ||
                        selectedClass == 'Druid' ||
                        selectedClass == 'Ranger') {
                      spellCastingAbility['Spell Casting Modifier'] =
                          ((wisdom! - 10) ~/ 2);
                    } else if (selectedClass == 'Warlock' ||
                        selectedClass == 'Paladin' ||
                        selectedClass == 'Sorcerer' ||
                        selectedClass == 'Bard') {
                      spellCastingAbility['Spell Casting Modifier'] =
                          ((charisma! - 10) ~/ 2);
                    }
                    spellCastingAbility['Spell Save DC'] =
                        8 +
                        proficiencies +
                        spellCastingAbility['Spell Casting Modifier']!;
                    spellCastingAbility['Spell Attack Bonus'] =
                        proficiencies +
                        spellCastingAbility['Spell Casting Modifier']!;
                    initiative = (((dexterity! - 10) ~/ 2) as int?);
                    Character character = Character(
                      hp: hp,
                      strength: strength,
                      dexterity: dexterity,
                      intelligence: intelligence,
                      constitution: constitution,
                      wisdom: wisdom,
                      charisma: charisma,
                      name: name,
                      race: race,
                      level: level,
                      armorClass: armorClass,
                      initiative: initiative,
                      speed: speed,
                      passivePerception: passivePerception,
                      background: "acolyte",
                      alignment: alignment,
                      charClass: charClass,
                      skillBonuses: skillBonuses,
                      features: features,
                      traits: traits,
                      proficiencies: proficiencies,
                      languages: languages,
                      size: size,
                      inventory: inventory,
                      equipment: equipment,
                      spells: selectedSpells,
                      spellCastingAbility: spellCastingAbility,
                      spellSlots: spellSlots,
                      appearance: appearance,
                    );
                    addCharacter(character);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CharacterPage(),
                      ),
                    );
                  },
                  child: const Text('Create Character'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
