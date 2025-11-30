/*
Contributors: Ayaan Mustafa
Date: 2025/11/30
Purpose: Describe Widget for the main compendium navigation page
 */

// Imports
import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'compendium_page.dart';

// Compendium Widget Class
class Compendium extends StatefulWidget {
  // constructor
  const Compendium({super.key});

  // createState method
  @override
  CompendiumState createState() => CompendiumState();
}

// Compendium Widget State
class CompendiumState extends State<Compendium> {
  // List of CompendiumButtons that make up the UI of the Compendium page
  final List<Widget> _compendiumButtons = <Widget>[
    CompendiumButton(label: "races", icon: RpgAwesome.double_team),
    CompendiumButton(label: "backgrounds", icon: RpgAwesome.castle_emblem),
    CompendiumButton(label: "classes", icon: RpgAwesome.shield),
    CompendiumButton(label: "spells", icon: RpgAwesome.fairy_wand),
    CompendiumButton(label: "equipment", icon: RpgAwesome.gem_pendant),
    CompendiumButton(label: "monsters", icon: RpgAwesome.eye_monster),
  ];

  // build method that returns a gridview of Compendium Buttons
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Compendium")),
      body: Expanded(
        child: GridView.count(
          primary: false,
          padding: EdgeInsets.all(20),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 20,
          children: List.generate(_compendiumButtons.length, (index) {
            return Center(child: _compendiumButtons[index]);
          }),
        ),
      ),
    );
  }
}

// CompendiumButton Widget Class
class CompendiumButton extends StatefulWidget {
  // class fields
  final String label; // button label
  final IconData icon; // button icon

  // constructor
  const CompendiumButton({super.key, required this.label, required this.icon});

  // createState() method
  @override
  CompendiumButtonState createState() => CompendiumButtonState();
}

// CompendiumButton Widget State
class CompendiumButtonState extends State<CompendiumButton> {
  // build method that returns a single button
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(170, 130),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: () {
          // On press navigate to the corresponding page of the compendium
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CompendiumPage(category: widget.label.toLowerCase()),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 35, color: Color(0xFF6B4E24)),
            SizedBox(height: 10),
            Text(
              widget.label.toUpperCase(),
              style: TextStyle(fontSize: 20, color: Color(0xFF6B4E24)),
            ),
          ],
        ),
      ),
    );
  }
}
