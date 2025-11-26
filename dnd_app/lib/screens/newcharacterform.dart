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
final _backgroundController = TextEditingController();
final _levelController = TextEditingController();

int? hp = 0;
int hitDie = 0;
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
int proficiencies = 0;
List<String> languages = [];
List<String>? raceLanguages;
List<String> selectedSpells = [];
String speedInfo = '';
String sizeInfo = '';
String abilityBonusText = '';
String languageText = '';
String traitText = '';

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
                onPressed: () async {
                  // Validate all form fields before proceeding
                  if (_formKey.currentState!.validate()) {
                    //setState(() async {
                    // STEP 2: return character object
                    name = _nameController.text;
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RaceSelector()),
                    );
                    if (result != null) {
                      if (context.mounted) {
                        Navigator.pop(context, result);
                      }
                    }
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
        sizeInfo = 'Size: $size';
        speedInfo = 'Speed: ${speed.toString()}';
        abilityBonusText = '$race Ability Bonuses';
        languageText = "Languages Known as $race";
        traitText = "$race traits";
      });
    } else {
      throw Exception('Failed to load Race Info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Choose your race")),
      body: SafeArea(
        child: Padding(
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
              Text(speedInfo),
              Text(sizeInfo),
              SizedBox(height: 16.0),
              Text(
                abilityBonusText,
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
                languageText,
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
                traitText,
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
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SelectClass()),
                    );
                    if (result != null) {
                      if (context.mounted) {
                        Navigator.pop(context, result);
                      }
                    }
                  },
                  child: Text("Confirm"),
                ),
              ),
            ],
          ),
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
        hitDie = decoded['hit_die'];
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("What Level is your Character 1-20"),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _levelController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Character level',
                  hintStyle: TextStyle(
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed >= 1 && parsed <= 20) {
                      level = parsed;
                    } else {
                      level = 1;
                    }
                  });
                },
              ),
              SizedBox(height: 8.0),
              Text("Now, choose your first class"),
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
                ListView.builder(
                  shrinkWrap: true,
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

              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    skillBonuses.updateAll(
                      (key, value) => selectedSkills.contains(key),
                    );
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const statsPage(),
                      ),
                    );
                    if (result != null) {
                      if (context.mounted) {
                        Navigator.pop(context, result);
                      }
                    }
                  },
                  child: Text("Confirm"),
                ),
              ),
            ],
          ),
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

  /// Actual spell level from the API: 0–9
  final int level;

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

  /// How many cantrips the class knows at this level.
  int _cantripLimit = 0;

  /// Max leveled spells (your “prepared spells”) the character can choose.
  int _maxPrepared = 0;

  /// Cantrip spells (level 0)
  List<SpellSummary> _cantripSpells = [];

  /// All leveled spells grouped by their spell level (1–9).
  /// e.g. { 1: [...], 2: [...], 3: [...] }
  Map<int, List<SpellSummary>> _leveledSpells = {};

  /// Optional cache so Info button doesn’t refetch the same spell twice.
  final Map<String, SpellDetails> _detailsCache = {};

  /// Cleric auto-known L1 spells
  final List<String> _autoLevel1SpellIndices = ['bless', 'cure-wounds'];

  @override
  void initState() {
    super.initState();
    _loadSpells();
  }

  int _getCastingModForClass() {
    final cls = selectedClass?.toLowerCase();

    int abilityScore;

    if (cls == 'wizard') {
      abilityScore = intelligence ?? 10;
    } else if (cls == 'cleric' || cls == 'druid' || cls == 'ranger') {
      abilityScore = wisdom ?? 10;
    } else if (cls == 'warlock' ||
        cls == 'paladin' ||
        cls == 'sorcerer' ||
        cls == 'bard') {
      abilityScore = charisma ?? 10;
    } else {
      abilityScore = 10; // fallback
    }

    return ((abilityScore - 10) ~/ 2);
  }

  Future<void> _loadSpells() async {
    try {
      final clsIndex = selectedClass?.toLowerCase();
      final lvl = level;

      if (clsIndex == null || lvl == null) {
        setState(() {
          _isLoading = false;
          _error = 'Class or level not set.';
        });
        return;
      }

      // 1. Get class levels for spellcasting + prof + cantrips
      final levelsResp = await http.get(
        Uri.parse('https://www.dnd5eapi.co/api/2014/classes/$clsIndex/levels'),
      );

      if (levelsResp.statusCode != 200) {
        throw Exception('Failed to load class levels: ${levelsResp.body}');
      }

      final levelsJson = jsonDecode(levelsResp.body) as List<dynamic>;
      final Map<String, dynamic> levelMap = levelsJson
          .cast<Map<String, dynamic>>()
          .firstWhere((e) => e['level'] == lvl);

      // prof_bonus → global proficiencies
      final profBonus = levelMap['prof_bonus'] as int?;
      if (profBonus != null) {
        proficiencies = profBonus;
      }

      // spellcasting block
      final spellcasting = levelMap['spellcasting'] as Map<String, dynamic>?;

      if (spellcasting != null) {
        _cantripLimit = spellcasting['cantrips_known'] as int? ?? 0;

        for (var i = 1; i <= 9; i++) {
          final key = 'spell_slots_level_$i';
          final slots = spellcasting[key] as int? ?? 0;
          spellSlots['Level $i'] = slots;
        }

        // All casters treated as prepared casters: limit = level + casting mod
        final mod = _getCastingModForClass();
        _maxPrepared = (lvl + mod).clamp(1, 99);
      } else {
        // No spellcasting at this level (e.g. Paladin/Ranger before 2)
        _cantripLimit = 0;
        _maxPrepared = 0;
        for (var i = 1; i <= 9; i++) {
          spellSlots['Level $i'] = 0;
        }
      }

      // 2. Fetch the spells for this class & level
      final spellsResp = await http.get(
        Uri.parse(
          'https://www.dnd5eapi.co/api/2014/classes/$clsIndex/levels/$lvl/spells',
        ),
      );

      if (spellsResp.statusCode != 200) {
        throw Exception(
          'Failed to load spells for $clsIndex level $lvl: ${spellsResp.body}',
        );
      }

      final spellsJson = jsonDecode(spellsResp.body) as Map<String, dynamic>;
      final results = spellsJson['results'] as List<dynamic>? ?? [];

      final List<SpellSummary> cantrips = [];
      final Map<int, List<SpellSummary>> leveled = {};

      // Fetch details sequentially (avoid hammering the API)
      for (final s in results) {
        final index = s['index'] as String;
        final details = await _fetchSpellDetails(index);

        if (details.level == 0) {
          cantrips.add(
            SpellSummary(index: details.index, name: details.name, level: 0),
          );
        } else if (details.level >= 1 && details.level <= 9) {
          leveled.putIfAbsent(details.level, () => []);
          leveled[details.level]!.add(
            SpellSummary(
              index: details.index,
              name: details.name,
              level: details.level,
            ),
          );
        }
      }

      // Auto-add Cleric L1 spells if this is a cleric
      if (selectedClass?.toLowerCase() == 'cleric') {
        for (final idx in _autoLevel1SpellIndices) {
          if (!selectedSpells.contains(idx)) {
            selectedSpells.add(idx);
          }
        }
      }

      setState(() {
        _cantripSpells = cantrips;
        _leveledSpells = leveled;
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
    // Check cache first
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

  int _selectedLeveledCount() {
    int total = 0;
    _leveledSpells.forEach((lvl, spellsAtLevel) {
      total += spellsAtLevel
          .where((s) => selectedSpells.contains(s.index))
          .length;
    });
    return total;
  }

  int get _leveledLimit => _maxPrepared;

  void _toggleSpell(SpellSummary spell) {
    final cls = selectedClass?.toLowerCase();
    final isCantrip = spell.level == 0;

    // Cleric: still auto-knows Bless + Cure Wounds; can't choose other L1s.
    if (cls == 'cleric' && spell.level == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Clerics automatically know Bless and Cure Wounds instead of choosing level 1 spells.',
          ),
        ),
      );
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
      if (_cantripLimit > 0 && count >= _cantripLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can only select $_cantripLimit cantrip(s) as a $selectedClass.',
            ),
          ),
        );
        return;
      }
    } else {
      // All leveled spells share the same cap (_maxPrepared)
      final leveledLimit = _leveledLimit;
      if (leveledLimit > 0) {
        final current = _selectedLeveledCount();
        if (current >= leveledLimit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can only select $leveledLimit leveled spell(s) as a $selectedClass.',
              ),
            ),
          );
          return;
        }
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
    final leveledSelected = _selectedLeveledCount();
    final leveledLimit = _leveledLimit;

    return Scaffold(
      appBar: AppBar(title: const Text("Select your Spells")),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
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
                    'Class: $selectedClass (Level $level)',
                    style: const TextStyle(
                      color: Color(0xFFA23E2E),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cantrips: choose $_cantripLimit (selected: $cantripSelected)',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 18,
                    ),
                  ),
                  if (leveledLimit > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Leveled spells: choose up to $leveledLimit (selected: $leveledSelected)',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 18,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'Spell Slots:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  for (var lvl = 1; lvl <= 9; lvl++)
                    if ((spellSlots['Level $lvl'] ?? 0) > 0)
                      Text('Level $lvl: ${spellSlots['Level $lvl']} slot(s)'),
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
                          ..._cantripSpells.map(_buildSpellRow).toList(),
                          const SizedBox(height: 16),
                        ],
                        for (var lvl = 1; lvl <= 9; lvl++) ...[
                          if (_leveledSpells[lvl] != null &&
                              _leveledSpells[lvl]!.isNotEmpty) ...[
                            Text(
                              'Level $lvl Spells',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ..._leveledSpells[lvl]!
                                .map(_buildSpellRow)
                                .toList(),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const backgroundPage(),
                            ),
                          );
                          if (result != null) {
                            if (context.mounted) {
                              Navigator.pop(context, result);
                            }
                          }
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
  bool _classHasSpellsAtThisLevel() {
    if (selectedClass == null || level == null) return false;

    final cls = selectedClass!;
    final lvl = level!;

    // Full casters – spells from level 1
    if (cls == 'Bard' ||
        cls == 'Cleric' ||
        cls == 'Druid' ||
        cls == 'Wizard' ||
        cls == 'Sorcerer' ||
        cls == 'Warlock') {
      return true;
    }

    // Half-casters – spells starting at level 2
    if ((cls == 'Paladin' || cls == 'Ranger') && lvl >= 2) {
      return true;
    }

    return false;
  }

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
      body: SafeArea(
        child: Padding(
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
                    Container(
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
                                (strbonus +
                                int.parse(_strengthController.text));
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
                    Container(
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
                                (dexbonus +
                                int.parse(_dexterityController.text));
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
                Text(
                  "Constitiution measures health, stamina, and vital force.",
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Container(
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
                    Container(
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
                    Container(
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
                    Container(
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
                                (chabonus +
                                int.parse(_charismaController.text));
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
                    onPressed: () async {
                      strength = strTotal;
                      dexterity = dexTotal;
                      constitution = conTotal;
                      intelligence = intTotal;
                      wisdom = wisTotal;
                      charisma = chaTotal;

                      if (_classHasSpellsAtThisLevel()) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const pickSpells(),
                          ),
                        );
                        if (result != null) {
                          if (context.mounted) {
                            Navigator.pop(context, result);
                          }
                        }
                      } else {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const backgroundPage(),
                          ),
                        );
                        if (result != null) {
                          if (context.mounted) {
                            Navigator.pop(context, result);
                          }
                        }
                      }
                    },
                    child: const Text('Confirm Stats'),
                  ),
                ),
              ],
            ),
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
    await CharacterDatabase.instance.create(character);
  }

  void resetCharacterGlobals() {
    hp = 0;
    strength = 0;
    dexterity = 0;
    intelligence = 0;
    constitution = 0;
    wisdom = 0;
    charisma = 0;

    name = null;
    race = null;
    level = 1;
    armorClass = 0;
    initiative = 0;
    speed = 0;
    passivePerception = 10;
    background = null;
    alignment = null;
    appearance = null;
    size = 'Small';

    charClass = null;
    selectedClass = null;

    skillBonuses = {
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

    inventory = {'Gold': 100};

    spellCastingAbility = {
      'Spell Casting Modifier': 0,
      'Spell Save DC:': 0,
      'Spell Attack Bonus': 0,
    };

    spellSlots = {
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

    abilityBonus = null;

    features = [];
    traits = null;
    equipment = null;
    proficiencies = 0;
    languages = [];
    raceLanguages = null;
    selectedSpells = [];

    sizeInfo = '';
    speedInfo = '';
    abilityBonusText = '';
    languageText = "";
    traitText = "";

    _nameController.clear();
    _strengthController.clear();
    _dexterityController.clear();
    _constitutionController.clear();
    _intelligenceController.clear();
    _wisdomController.clear();
    _charismaController.clear();
    _armorClassController.clear();
    _appearanceController.clear();
    _levelController.clear();
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
      body: SafeArea(
        child: Padding(
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
              SizedBox(height: 16.0),
              Text("Describe your characters background and origins"),
              SizedBox(height: 8.0),
              TextFormField(
                textAlign: TextAlign.start,
                controller: _backgroundController,
                decoration: InputDecoration(
                  hintText: 'Background',
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
                    background = _backgroundController.text;
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
                      if (skillBonuses['Perception'] == true) {
                        passivePerception =
                            ((((wisdom! - 10) ~/ 2)) + proficiencies);
                      } else {
                        passivePerception = (((wisdom! - 10) ~/ 2));
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
                      hp =
                          ((level! - 1) * (hitDie ~/ 2) +
                              ((constitution! - 10) ~/ 2)) +
                          (hitDie + ((constitution! - 10) ~/ 2));
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
                        background: background ?? "Acolyte",
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
                      resetCharacterGlobals();
                      Navigator.pop(context, character);
                    },
                    child: const Text('Create Character'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
