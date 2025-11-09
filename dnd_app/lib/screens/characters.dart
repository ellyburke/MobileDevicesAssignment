// Characters Screen

import 'package:flutter/material.dart';
import 'package:dnd_app/screens/newcharacterform.dart';


//  Database imports
import 'package:dnd_app/character databases.dart';

// Model imports
import 'package:dnd_app/backEnd.dart';

class CharacterPage extends StatefulWidget {
  const CharacterPage({super.key});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage>
{

  // Get the list of characters from the database
  late Future<List<Character>> characterList = CharacterDatabase.instance.readAllCharacters();


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
              actions: [
                TextButton(
                    onPressed: () async {
                      // Navigate to new character form
                      final newCharacter = await Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => NewCharacterForm()
                      ));

                      print(newCharacter);

                      // Add character to the database if not null
                      if (newCharacter != null){
                        await CharacterDatabase.instance.create(newCharacter);
                        final refreshedList = CharacterDatabase.instance.readAllCharacters();
                        characterList = refreshedList;
                      }

                      // Refresh list
                      setState(() {
                        print(characterList);
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.black,),
                        SizedBox(width: 5),
                        Text("Add new Character", style: TextStyle(color: Colors.black),)
                      ],
                    ))
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
                        borderRadius:  const BorderRadius.all(Radius.circular(10)),
                        color:  Color(0xFFA23E2E).withOpacity(0.5)
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
                                overflow: TextOverflow.ellipsis
                            ),
                          ),
                        ]
                    ),
                  ),
                ),
              )
          ),

          // ============================
          // CHARACTER TAB BODY
          // ============================
          body: TabBarView(
              children: [
                FutureBuilder(
                    future: characterList,
                    builder: (context, snapshot){
                      print(characterList);
                      // While waiting for connection
                      if (snapshot.connectionState ==  ConnectionState.waiting){
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      // If error
                      if (snapshot.hasError){
                        print(snapshot.error);
                        return Center(
                          child: Text("Error has occured"),
                        );
                      }

                      // If there are no characters in the database, return
                      if (!snapshot.hasData){
                        return Center(
                          child: Text("No characters in the database:("),
                        );
                      }
                      // To make the data a list for itemCount
                      final characters = snapshot.data!;
                      return ListView.builder(
                          itemCount: characters.length,
                          itemBuilder: (context, index){
                            // Display each character one at a time
                            final character = characters[index];
                            return Card(
                                margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                                color: Colors.grey,
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(character.name,
                                            style: TextStyle(fontSize: 25) ,),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text('Level ${character.level.toString()}\t|\t${character.race}',
                                            style: TextStyle(fontSize: 15),),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text('${character.hp.toString()} HP\t|\t'
                                              '${character.speed} SPD\t|\t'
                                              '${character.initiative} INIT\t|\t'
                                              '${character.wisdom} WDM',
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                    ],
                                  ) ,
                                )
                            );
                          });
                    }
                ),

                Center(
                    child: Text("You have no friends yet:("))
              ]
          ),

          // Impliment this in a seperate file so you can only switch between bodies
          bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: const [
                // Character Tab
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: 'Characters',
                ),
                // Game info tab
                BottomNavigationBarItem(
                  icon: Icon(Icons.shield),
                  label: 'Game Info',
                ),
                // Friends tab
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Friends',
                ),
                // Sessions tab
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: 'Sessions',
                ),
              ]
          ),
        )
    );


  }
}