/*
Widget for the compendium page
 */

import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'compendium_page.dart';

class Compendium extends StatefulWidget {
  const Compendium({super.key});

  @override
  CompendiumState createState() => CompendiumState();
}

class CompendiumState extends State<Compendium> {
  final List<Widget> _compendiumButtons = <Widget>[
    CompendiumButton(label: "races", icon: RpgAwesome.double_team),
    CompendiumButton(label: "backgrounds", icon: RpgAwesome.castle_emblem),
    CompendiumButton(label: "classes", icon: RpgAwesome.shield),
    CompendiumButton(label: "spells", icon: RpgAwesome.fairy_wand),
    CompendiumButton(label: "equipment", icon: RpgAwesome.gem_pendant),
    CompendiumButton(label: "monsters", icon: RpgAwesome.eye_monster),
  ];

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

class CompendiumButton extends StatefulWidget {
  final String label;
  final IconData icon;

  const CompendiumButton({super.key, required this.label, required this.icon});

  @override
  CompendiumButtonState createState() => CompendiumButtonState();
}

class CompendiumButtonState extends State<CompendiumButton> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(170, 130),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: () {
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
