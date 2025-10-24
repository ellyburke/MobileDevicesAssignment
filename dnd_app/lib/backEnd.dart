class Character {
  int hp;
  int strength;
  int dexterity;
  int intelligence;
  int constitution;
  int wisdom;
  int charisma;
  String name;
  String race;

  //Map with class as the key and level of that class as value (FOR MULTICLASS)
  //{Fighter(Champion):8, Thief(Assassin):1)
  Map<String, int> charClass;
  int level;
  String background;
  int armorClass;

  //Map with skills as key and bonus as the value
  //{Stealth:2, Insight:1}
  Map<String, int> skills;
  int initiative;
  int speed;
  String alignment;

  //List of all features for character
  List<String> features;
  List<String> traits;
  List<String> classFeatures;
  int passivePerception;
  List<String>? equipment;

  //{'gold':x, 'platinum':y, 'health potions':z}
  Map<String, int>? inventory;
  List<String> proficiencies;
  List<String> languages;
  List<String>? spells;

  //{'SpellCasting Modifier':x, 'Spell Save DC':y, 'Spell Attack Bonus':z}
  Map<String, int>? spellCastingAbility;

  //{'Level 1':x, 'Level 2':y, 'Level 3':z, 'Level 4':a, 'Level 5':b}
  Map<String, int>? spellSlots;
  String? appearance;


  Character(
      this.hp,
      this.strength,
      this.dexterity,
      this.intelligence,
      this.constitution,
      this.wisdom,
      this.charisma,
      this.name,
      this.race,
      this.speed,
      this.charClass,
      this.level,
      this.background,
      this.armorClass,
      this.skills,
      this.initiative,
      this.alignment,
      this.features,
      this.traits,
      this.classFeatures,
      this.passivePerception,
      List<String> this.equipment,
      Map<String, int> this.inventory,
      this.proficiencies,
      this.languages,
      List<String> this.spells,
      Map<String, int> this.spellCastingAbility,
      Map<String, int> this.spellSlots,
      String this.appearance
      );

  int getStrength() {return strength;}

  int getDexterity() {return dexterity;}

  int getIntelligence() {return intelligence;}

  int getConstitution() { return constitution; }

  int getWisdom() { return wisdom; }

  int getCharisma() { return charisma; }

  int getSpeed() { return speed; }

  int getInitiative() { return initiative; }

  int getArmorClass() { return armorClass; }

  int getPassivePerception() { return passivePerception; }

  int getHP() { return hp; }

  String getName() { return name; }

  String getRace() { return race; }
  
  String getBackground() { return background; }

  String getAlignment() { return alignment; }

  String? getAppearance() { return appearance; }
  
  Map<String, int>? getSpellSlots() { return spellSlots; }
  
  Map<String, int>? getSpellCastingAbility() { return spellCastingAbility; }
  
  List<String>? getSpells() { return spells; }
  
  Map<String, int> getClass() { return charClass; }
  
  List<String>? getEquipment() { return equipment; }
  
  Map<String, int>? getInventory() { return inventory; }
  
  List<String> getLanguages() { return languages; }
  
  List<String> getProficiencies() { return proficiencies; }
  
  Map<String, int> getSkills() { return skills; }
  
  List<String> getTraits() { return traits; }
  
  List<String> getFeatures() { return features; }
  
  List<String> getClassFeatures() { return classFeatures; }
  
  void setHP(int newHP) { hp = newHP; }
  
  void levelUp() { level++; }
  
  void setAC(int newAC) { armorClass = newAC; }
  
  void setInitiative(int newInitiative) { initiative = newInitiative; }
  
  void setRace(String newRace) { race = newRace; }
  
  void setSpeed(int newSpeed) { speed = newSpeed; }
  
  void setPassivePerception(int newPassivePerception) { passivePerception = newPassivePerception; }
  
  void setAppearance(String newAppearance) { appearance = newAppearance; }
  
  void setAlignment(String newAlignment) { alignment = newAlignment; }
  
  void setBackground(String newBackground) { background = newBackground; }
  
  void setClass(Map<String, int> newClass) { charClass = newClass; }
  
  void setEquipment(List<String> newEquipment) { equipment = newEquipment; }
  
  void setFeatures(List<String> newFeatures) { features = newFeatures; }
  
  void setStrength(int newStrength) { strength = newStrength; }

  void setDexterity(int newDexterity) { dexterity = newDexterity; }
  
  void setIntelligence(int newIntelligence) { intelligence = newIntelligence; }

  void setConstitution(int newConstitution) { constitution = newConstitution; }
  
  void setWisdom(int newWisdom) { wisdom = newWisdom; }
  
  void setCharisma(int newCharisma) { charisma = newCharisma; }
  
  void setName(String newName) { name = newName; }
  
  void setSkills(Map<String, int> newSkills) { skills = newSkills; }
  
  void setTraits(List<String> newTraits) { traits = newTraits; }
  
  void setClassFeatures(List<String> newClassFeatures) { classFeatures = newClassFeatures; }
  
  void setInventory(Map<String, int> newInventory) { inventory = newInventory; }

  void setLanguages(List<String> newLanguages) { languages = newLanguages; }
  
  void setProficiencies(List<String> newProficiencies) { proficiencies = newProficiencies; }
  
  void setSpells(List<String> newSpells) { spells = newSpells; }

  void setSpellCastingAbility(Map<String, int> newSpellCastingAbility) { spellCastingAbility = newSpellCastingAbility; }
  
  void setSpellSlots(Map<String, int> newSpellSlots) { spellSlots = newSpellSlots; }
  
}
