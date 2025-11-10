// Form ui to create a new character

import 'package:flutter/material.dart';
import 'package:dnd_app/character_databases.dart';
import 'package:dnd_app/backEnd.dart';


class NewCharacterForm extends StatefulWidget{

  const NewCharacterForm({super.key});

  @override
  State<NewCharacterForm> createState() => _NewCharacterFormState();

}

class _NewCharacterFormState extends State<NewCharacterForm>{

  // Form key for validation - Gives access to form widget
  final _formKey = GlobalKey<FormState>();

  // Controllers for each text field
  final _nameController = TextEditingController();
  final _levelController = TextEditingController();
  final _raceController = TextEditingController();
  final _hpController = TextEditingController();
  final _speedController = TextEditingController();
  final _initController = TextEditingController();
  final _wisdomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('New Character'),
      ),
      body: Form(
          key:_formKey,
          child: Padding(
              padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name field
                TextFormField(
                  controller: _nameController,
                decoration: InputDecoration(labelText: 'Character Name'),
                ),

                // Level field
                TextFormField(
                  controller: _levelController,
                  decoration: InputDecoration(labelText: 'Level'),
                ),

                // Race field
                TextFormField(
                  controller: _raceController,
                  decoration: InputDecoration(labelText: 'Race'),
                ),

                // HP
                TextFormField(
                  controller: _hpController,
                  decoration: InputDecoration(labelText: 'HP'),
                ),

                // SPEED
                TextFormField(
                  controller: _speedController,
                  decoration: InputDecoration(labelText: 'Speed'),
                ),

                // INITIATIVE
                TextFormField(
                  controller: _initController,
                  decoration: InputDecoration(labelText: 'Initiative'),
                ),

                // WISDOM
                TextFormField(
                  controller: _wisdomController,
                  decoration: InputDecoration(labelText: 'Wisdom'),
                ),

                SizedBox(height: 20.0),

                // ===============================
                // SUBMIT BUTTON
                // ===============================
                ElevatedButton(
                  onPressed: () {
                    // Validate all form fields before proceeding
                    if (_formKey.currentState!.validate()) {
                      setState (() async {
                        // Create new character in database
                        // STEP 1: Create new object
                        final character = Character(
                            hp: int.parse(_hpController.text),
                            strength: 0,
                            dexterity: 0,
                            intelligence: 0,
                            constitution: 0,
                            wisdom: int.parse(_wisdomController.text),
                            charisma: 0,
                            name: _nameController.text,
                            race: _raceController.text,
                            level: int.parse(_levelController.text),
                            armorClass: 0,
                            initiative: int.parse(_initController.text),
                            speed: int.parse(_speedController.text),
                            passivePerception: 0,
                            background: '',
                            alignment: '',
                            charClass: {},
                            skills: {},
                            features: [],
                            traits: [],
                            classFeatures: [],
                            proficiencies: [],
                            languages: []
                        );

                        // STEP 2: return character object
                        Navigator.pop(context, character);

                      });
                    }
                  },
                  child: Text('Submit'),
                ),

              ],
            ),
    )
      ),
    );
  }
}