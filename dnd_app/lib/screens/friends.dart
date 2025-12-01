import 'package:dnd_app/databases/user_database.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

class FriendsPage extends StatefulWidget {
  final int? userId;

  const FriendsPage({super.key, required this.userId});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  // Main friends list
  List<User> friendsList = [];

  // Filtered data
  Map<String, List<User>> filteredMap = {};
  List<dynamic> filteredList = [];

  TextEditingController searchController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  Future<void> loadFriends() async {
    setState(() => _loading = true);

    final list = await UserDatabase.instance.getFriends(widget.userId!);

    setState(() {
      friendsList = list;
      filteredMap = mapData(friendsList);
      filteredList = buildFlattenedList(filteredMap);
      _loading = false;
    });
  }

  // ============================
  // MAP INTO A→Z SECTIONS
  // ============================
  Map<String, List<User>> mapData(List<User> friends, {String text = ''}) {
    final query = text.trim().toLowerCase();
    Map<String, List<User>> newMap = {};

    for (User friend in friends) {
      final display = (friend.displayName ?? friend.firstName).toLowerCase();
      final first = friend.firstName.toLowerCase();
      final user = friend.username.toLowerCase();

      // FILTER
      if (query.isNotEmpty) {
        final matches =
            display.contains(query) ||
            first.contains(query) ||
            user.contains(query);
        if (!matches) continue;
      }

      // SECTION LETTER
      String firstLetter = (friend.displayName ?? friend.firstName)[0]
          .toUpperCase();

      newMap.putIfAbsent(firstLetter, () => []);
      newMap[firstLetter]!.add(friend);
    }

    return SplayTreeMap<String, List<User>>.from(newMap);
  }

  List<dynamic> buildFlattenedList(Map<String, List<User>> sectionMap) {
    // Function to flatten the list for alphabet sectioning

    final List<dynamic> flattened = [];
    final sortedKeys = sectionMap.keys.toList()..sort();

    for (String key in sortedKeys) {
      flattened.add(key);
      flattened.addAll(sectionMap[key]!);
    }
    return flattened;
  }

  Future<void> addFriend() async {
    final result = await showAddFriendDialog(context);
    if (result == null) return;

    final alreadyFriends = friendsList.any((u) => u.id == result.id);
    if (alreadyFriends) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This person is already your friend")),
      );
      return;
    }

    await UserDatabase.instance.addFriend(widget.userId!, result.id!);

    await loadFriends();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Friend added!")));
  }

  Future<void> removeFriend(int friendId) async {
    await UserDatabase.instance.removeFriend(widget.userId!, friendId);
    await loadFriends();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Friend removed")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        actions: [
          ElevatedButton(
            onPressed: addFriend,
            child: const Row(children: [Icon(Icons.add), Text("Add a friend")]),
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 15),

                // SEARCH BAR
                SearchBar(
                  controller: searchController,
                  padding: const WidgetStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  hintText: "Search username or display name…",
                  onChanged: (value) {
                    setState(() {
                      filteredMap = mapData(friendsList, text: value);
                      filteredList = buildFlattenedList(filteredMap);
                    });
                  },
                ),

                const SizedBox(height: 15),

                // No friends?
                if (friendsList.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("You have no friends :("),
                          ElevatedButton(
                            onPressed: addFriend,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                  // FRIENDS LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];

                        // Alphabet section header
                        if (item is String) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        final user = item as User;

                        return _buildFriendCard(user);
                      },
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildFriendCard(User user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(radius: 25, child: Icon(Icons.person)),

        title: Row(
          children: [
            Text(
              user.displayName ?? user.firstName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
            ),
            const SizedBox(width: 10),
            Text(user.pronouns ?? ''),
          ],
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("@${user.username}"),
            if (user.bio != null && user.bio!.isNotEmpty)
              Text(
                "📣 \"${user.bio!}\"",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15),
              ),
          ],
        ),

        trailing: IconButton(
          onPressed: () => removeFriend(user.id!),
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }

  // ============================
  // ADD FRIEND DIALOG
  // ============================
  Future<User?> showAddFriendDialog(BuildContext context) async {
    final _usernameController = TextEditingController();

    // Local dialog state
    bool valid = false;
    bool notValid = false;
    String? helperText;
    String? errorText;

    Future<void> checkForUser(
      String value,
      void Function(void Function()) setStateDialog,
    ) async {
      final result = await UserDatabase.instance.getUserByUsername(
        value.trim(),
      );

      setStateDialog(() {
        if (result == null) {
          notValid = true;
          valid = false;
        } else {
          notValid = false;
          valid = true;
        }
      });
    }

    return showDialog<User?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Add a Friend by Username"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Enter Username",
                      prefixIcon: const Icon(Icons.person),
                      errorText: notValid ? "User not found" : null,
                      helperText: helperText,
                      suffixIcon: valid
                          ? const Icon(Icons.check, color: Colors.green)
                          : notValid
                          ? const Icon(Icons.close, color: Colors.red)
                          : null,
                    ),
                    onChanged: (value) {
                      checkForUser(value, setStateDialog);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = await UserDatabase.instance.getUserByUsername(
                      _usernameController.text.trim(),
                    );

                    if (user == null) {
                      setStateDialog(() {
                        errorText = "User not found";
                        notValid = true;
                        valid = false;
                      });
                      return;
                    }

                    Navigator.pop(context, user);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
