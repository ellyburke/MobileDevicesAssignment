/*
Widget for the compendium page
 */

import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'compendiumPage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compendium',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF4EBD0),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFFA23E2E)),
      ),
      home: Compendium(),
    );
  }
}

class Compendium extends StatefulWidget {
  const Compendium({super.key});

  @override
  CompendiumState createState() => CompendiumState();
}

class CompendiumState extends State<Compendium> {
  // int _selectedIndex = 0;

  final List<Widget> _compendiumButtons = <Widget>[
    CompendiumButton(
      text: "Races",
      color: Colors.orange,
      icon: RpgAwesome.double_team,
    ),
    CompendiumButton(
      text: "Backgrounds",
      color: Colors.yellow,
      icon: RpgAwesome.castle_emblem,
    ),
    CompendiumButton(
      text: "Classes",
      color: Colors.green,
      icon: RpgAwesome.shield,
    ),
    CompendiumButton(
      text: "Spells",
      color: Colors.blue,
      icon: RpgAwesome.fairy_wand,
    ),
    CompendiumButton(
      text: "Items",
      color: Colors.indigo,
      icon: RpgAwesome.gem_pendant,
    ),
    CompendiumButton(
      text: "Monsters",
      color: Colors.purple,
      icon: RpgAwesome.eye_monster,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            print("I want to go home");
          },
          icon: Icon(Icons.home, color: Colors.white),
        ),
        title: Text(
          "Compendium",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Center(
        child: GridView.count(
          primary: false,
          padding: EdgeInsets.all(20),
          crossAxisCount: 2,
          childAspectRatio: 2.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: List.generate(_compendiumButtons.length, (index) {
            return Center(child: _compendiumButtons[index]);
          }),
        ),
      ),
    );
  }
}

class CompendiumButton extends StatefulWidget {
  final String text;
  final MaterialColor color;
  final IconData icon;

  const CompendiumButton({
    super.key,
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  CompendiumButtonState createState() => CompendiumButtonState();
}

class CompendiumButtonState extends State<CompendiumButton> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ButtonTheme(
        height: 50,
        minWidth: 50,
        shape: BeveledRectangleBorder(),
        child: ElevatedButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompendiumPage(),
              ), // Navigates to the FormPage when pressed
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6B4E24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            // padding: EdgeInsets.all(20),
          ),
          child: Expanded(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: Colors.white),
                SizedBox(height: 10),
                Text(widget.text, style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
