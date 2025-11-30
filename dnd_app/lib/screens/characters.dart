// Characters Screen

import 'package:dnd_app/screens/single_character.dart';
import 'package:flutter/material.dart';
import 'package:dnd_app/screens/new_character_form.dart';

//  Database imports
import 'package:dnd_app/character_databases.dart';
import 'package:dnd_app/user_database.dart';

// Model imports
import 'package:dnd_app/character_class.dart';

import '../main.dart';

class CharacterPage extends StatefulWidget {
  final String thisUsername;
  final int? userId;
  const CharacterPage({super.key, required this.thisUsername, this.userId});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  late final id = widget.userId;
  late final u = widget.thisUsername;
  // Get the list of characters from the database
  late Future<List<Character>> characterList = CharacterDatabase.instance
      .getAllCharactersByUsername(u);

  // Store a list of friends usernames and all characters
  late Future<List<Character>> allCharacters = CharacterDatabase.instance
      .readAllCharacters();
  late Future<List<User>> friends = UserDatabase.instance.getFriends(id!);

  List<Character> friendsCharacters = [];

  @override
  void initState() {
    super.initState();
    loadFriendCharacters();
  }

  Future<void> getFriendsCharacters() async {
    // Function that gets all the friend's created characters

    final characters = await allCharacters;
    final friendUsers = await friends;

    // Get all friends usernames
    final friendUsernames = friendUsers.map((u) => u.username).toSet();

    // Filter to get characters
    final list = characters.where((c) {
      return friendUsernames.contains(c.username);
    }).toList();

    friendsCharacters = list;
  }

  void loadFriendCharacters() async {
    await getFriendsCharacters();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Characters"),
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(username: u)),
              );
            },
            icon: Icon(Icons.arrow_back),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                //After Character Creation returns here, the list is refreshed
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewCharacterForm(passedusername: u),
                  ),
                );
                if (result != null) {
                  setState(() {
                    characterList = CharacterDatabase.instance
                        .getAllCharactersByUsername(u);
                  });
                }
              },
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    "Add new Character",
                    style: TextStyle(color: Colors.white),
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
            // =================
            // FIRST TAB
            // =================
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

                // To make the data a list for itemCount
                final characters = snapshot.data!;

                // If there are no characters in the database, return
                if (characters.isEmpty) {
                  return Center(child: Text("You have no characters yet :("));
                }

                return ListView.builder(
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];

                    return _buildCharacterCard(character);
                  },
                );
              },
            ),

            // ===============
            // SECOND TAB
            // ===============
            if (friendsCharacters.isEmpty)
              Center(child: Text("Your friends have no characters yet :("))
            else
              ListView.builder(
                itemCount: friendsCharacters.length,
                itemBuilder: (context, index) {
                  final character = friendsCharacters[index];

                  return _buildCharacterCard(character);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterCard(Character character) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(character.name ?? 'Unnamed'),
        subtitle: Text('Level ${character.level ?? 1} ${character.race ?? ''}'),
        onTap: () {
          // Open that specific character
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  singleCharacter(character: character, username: u),
            ),
          );
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            // Make sure the character has an id before deleting
            if (character.id != null) {
              await CharacterDatabase.instance.delete(character.id!);

              setState(() {
                characterList = CharacterDatabase.instance
                    .getAllCharactersByUsername(u);
              });
            }
          },
        ),
      ),
    );
  }
}
