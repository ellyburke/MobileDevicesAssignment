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
  late Future<List<User>> userData = UserDatabase.instance.getAllUser();

  // Store a bool to by pass filtered list initialization
  bool _initialized = false;

  // Main friends list (all friends)
  List<dynamic> friendsList = [];
  Map<String, List<User>> sectionMap = {};

  // Filtered list
  Map<String, List<User>> filteredMap = {};
  List<dynamic> filteredList = [];

  // Text controller for search bar
  TextEditingController searchController = TextEditingController();

  Map<String, List<User>> mapData(List<dynamic> friends, {String text = ''}){
    // Function to map the list into alphabet sections to display on page

    final query = text.trim().toLowerCase();

    // Create a new map
    Map<String, List<User>> newMap = {};

    // Go through the whole list
    for (User friend in friends){
      // Normalize fields (prevent null errors)
      final display = (friend.displayName ?? friend.firstName).toLowerCase();
      final first = friend.firstName.toLowerCase();
      final user = friend.username.toLowerCase();

      // Filter for searching
      if (query.isNotEmpty) {
        final matches = display.contains(query) || first.contains(query) ||
            user.contains(query);
        // Skip adding to map if no match
        if (!matches) continue;
      }

      // Determine section letter
      String firstLetter = (friend.displayName ?? friend.firstName)[0].toUpperCase();

      // Ensure letter has a list to add to
      if (!newMap.containsKey(firstLetter)){
        newMap[firstLetter] = [];
      }
      newMap[firstLetter]?.add(friend);
    }

    // Sort map
    var sortedByKeyMap = SplayTreeMap<String, List<User>>.from(newMap);
    return sortedByKeyMap;
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
    final newUser = User(
      username: "king123",
      password: "supersecure123",
      friends: ["1", "4", "7"],
      firstName: "Charles",
      lastName: "Lee",
      birthday: DateTime(2003, 5, 22),
      bio: "Building cool stuff and breaking things along the way.",
      displayName: "KingCharles",
      pronouns: "he/him",
      profileImage: "https://example.com/marcus.jpg",
      email: "marcus@example.com",
    );
    UserDatabase.instance.insertUser(newUser);
    final refreshedList = UserDatabase.instance.getAllUser();
    setState(() {
      userData = refreshedList;
    });
  }

  void removeFriend(int id){
    UserDatabase.instance.deleteUser(id);
    final refreshedList = UserDatabase.instance.getAllUser();

    setState(() {
      userData = refreshedList;
    });
  }

  @override
  void initState() {
    userData = UserDatabase.instance.getAllUser();
  }
  @override
  Widget build(BuildContext context) {
    // Wrap the entire Scaffold in a Future builder
    return FutureBuilder(
      future: userData,
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

        // Extract data when there is stuff in the database (all friends)
        friendsList = snapshot.data ?? [];

        if (!_initialized){
          sectionMap = mapData(friendsList);
          // Save a filtered version
          filteredMap = mapData(friendsList);
          filteredList = buildFlattenedList(sectionMap);
          _initialized = true;
        }

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
                    Text("Add a friend"),
                  ],
                ),
              ),
            ],
          ),

          body: Column(
            children: [
              const SizedBox(height: 15),

              SearchBar(
                controller: searchController,
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                hintText: "Search username or display name...",
                onChanged: (value){
                  setState(() {
                    filteredMap = mapData(friendsList, text: value);
                    filteredList = buildFlattenedList(filteredMap);
                  });
                },
              ),

              const SizedBox(height: 15),

              // 🔥 Handle the "no friends" case
              if (friendsList.isEmpty)
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
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];

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
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 25,
                            child: const Icon(Icons.person),
                          ),
                          title: Row(
                            children: [
                              Text(
                                item.displayName ?? '${item.firstName}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 25
                                ),
                              ),
                              SizedBox(width: 10,),
                              Text(item.pronouns ?? '')
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("@${item.username}"),
                              if (item.bio != null && item.bio!.isNotEmpty)
                                Text(
                                  "📣 \"${item.bio!}\"",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 15),
                                ),
                            ],
                          ),
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