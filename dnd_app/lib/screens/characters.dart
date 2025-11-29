// Characters Screen

import 'package:dnd_app/screens/singleCharacter.dart';
import 'package:flutter/material.dart';
import 'package:dnd_app/screens/newcharacterform.dart';

//  Database imports
import 'package:dnd_app/character_databases.dart';
import 'package:dnd_app/userDatabase.dart';

// Model imports
import 'package:dnd_app/backEnd.dart';

import '../main.dart';

class CharacterPage extends StatefulWidget {
  final String thisUsername;
  const CharacterPage({super.key, required this.thisUsername});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  late final u = widget.thisUsername;
  // Get the list of characters from the database
  late Future<List<Character>> characterList = CharacterDatabase.instance
      .readAllCharacters();

  @override
  void initState() {
    super.initState();
  }

  // NOTE: For the characters tab, just change the data you are pulling

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(username: u),
                ), //This needs to be HomePage(username: username)
              );
            },
            icon: Icon(Icons.arrow_back),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewCharacterForm(passedusername: u)),
                );

                if (result == true || result == null) {
                  setState(() {
                    characterList = CharacterDatabase.instance
                        .readAllCharacters();
                  });
                }
              },
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.black),
                  SizedBox(width: 5),
                  Text(
                    "Add new Character",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ],

          // Tabs for own and friend characters
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Color(0xFFA23E2E)..withValues(alpha: 0.5),
                ),
                // Where we will define each tab
                child: const TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Color(0xFFA23E2E),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Text(
                        "My Characters",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Friend's Characters",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ============================
        // CHARACTER TAB BODY
        // ============================
        body: TabBarView(
          children: [
            FutureBuilder(
              future: characterList,
              builder: (context, snapshot) {
                // While waiting for connection
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // If error
                if (snapshot.hasError) {
                  return Center(child: Text("Error has occurred"));
                }

                // If there are no characters in the database, return
                if (!snapshot.hasData) {
                  return Center(child: Text("No characters in the database:("));
                }
                // To make the data a list for itemCount
                final characters = snapshot.data!;

                return ListView.builder(
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(character.name ?? 'Unnamed'),
                        subtitle: Text(
                          'Level ${character.level ?? 1} ${character.race ?? ''}',
                        ),
                        onTap: () {
                          // Open that specific character
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => singleCharacter(
                                character: character,
                                username: u,
                              ),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            // Make sure the character has an id before deleting
                            if (character.id != null) {
                              await CharacterDatabase.instance.delete(
                                character.id!,
                              );

                              // 🔄 Refresh the list by creating a new future
                              setState(() {
                                characterList = CharacterDatabase.instance
                                    .readAllCharacters();
                              });
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            Center(child: Text("Your friends have no characters yet:(")),
          ],
        ),
      ),
    );
  }
}
