import 'package:dnd_app/userDatabase.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

class FriendsPage extends StatefulWidget{
  const FriendsPage({super.key});
  
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>{

  // Get the list of friends in the database
  late Future<List<User>> friendsList = UserDatabase.instance.getAllUser();
  Map<String, List<User>> sectionMap = {};

  void mapData(List<dynamic> friends){
    // Function to map the list into alphabet sections to display on page

    // Create a new map
    Map<String, List<User>> newMap = {};

    // Go through the whole list
    for (User friend in friends){
      final firstLetter = friend.username[0].toUpperCase();

      // Check if the letter is in the map already
      if (!newMap.containsKey(firstLetter)){
        newMap[firstLetter] = [];
      }
      newMap[firstLetter]?.add(friend);
    }

    // Sort map
    var sortedByKeyMap = SplayTreeMap<String, List<User>>.from(newMap);
    sectionMap = sortedByKeyMap;

  }

  List<dynamic> buildFlattenedList(Map<String, List<User>> sectionMap) {
    // This function returns a flattened list of friends including the section
    // headers to display in the list builder
    final List<dynamic> flattened = [];

    final sortedKeys = sectionMap.keys.toList()..sort();

    for (String key in sortedKeys) {
      flattened.add(key);                   // Section header (String)
      flattened.addAll(sectionMap[key]!);   // Section items (User objects)
    }

    return flattened;
  }


  // Add a user for testing
  void addFriend(){
    final newUser = User(3, 'jim345', 'passwords', ['10','2']);
    UserDatabase.instance.insertUser(newUser);
    final refreshedList = UserDatabase.instance.getAllUser();
    setState(() {
      friendsList = refreshedList;
    });
  }

  @override
  void initState() {
    friendsList = UserDatabase.instance.getAllUser();
  }
  @override
  Widget build(BuildContext context) {
    // Wrap the entire Scaffold in a Future builder
    return FutureBuilder(
      future: friendsList,
      builder: (context, snapshot) {

        // While loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If error
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("Friends")),
            body: Center(child: Text("An error has occurred")),
          );
        }

        // Extract data
        final dynamic friends = snapshot.data ?? [];
        // Section map and flatten
        mapData(friends);
        final list = buildFlattenedList(sectionMap);

        return Scaffold(
          appBar: AppBar(
            title: Text("Friends"),
            actions: [
              ElevatedButton(
                onPressed: () {
                  addFriend();
                },
                child: Row(
                  children: const [
                    Icon(Icons.add),
                    Text("Add a friend now"),
                  ],
                ),
              ),
            ],
          ),

          body: Column(
            children: [
              const SizedBox(height: 15),

              SearchBar(
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                hintText: "Search for a friend...",
              ),

              const SizedBox(height: 15),

              // 🔥 Handle the "no friends" case
              if (friends.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("You have no friends :("),
                        ElevatedButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add),
                              Text("Add a friend now"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
              // Show friends list
                Expanded(
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];

                      // If the 'item' is a string
                      if (item is String){
                        return Row(
                          children: [
                            SizedBox(width: 12,),
                            Text(
                              item,
                              style: TextStyle(

                                  fontSize: 35,
                                  fontWeight: FontWeight.bold
                              ),
                            )
                          ],
                        );
                      }

                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(),
                          title: Text(item.username),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );



  }
}