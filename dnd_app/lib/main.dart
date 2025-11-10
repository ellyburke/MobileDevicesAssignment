import 'package:flutter/material.dart';

// Imports for other screens
import 'package:dnd_app/screens/friends.dart';
import 'package:dnd_app/screens/characters.dart';
import 'package:dnd_app/screens/sessions.dart';
import 'package:dnd_app/compendium.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DnD App',
      theme: ThemeData(
        appBarTheme: (AppBarTheme(
          backgroundColor: Color(0xFFA23E2E),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        )),
        scaffoldBackgroundColor: Color(0xFFF4EBD0),
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFC2A878),
          onPrimary: Color(0xFFF4EBD0),
          secondary: Color(0xFF6B4E24),
          onSecondary: Color(0xFFF4EBD0),
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Pages list for navigation
  List<Map<String, dynamic>> pages = [
    {'title': 'Characters', 'icon': Icons.add, 'screen': CharacterPage()},
    {'title': 'Game Info', 'icon': Icons.shield},
    {'title': 'Friends', 'icon': Icons.people, 'screen': FriendsPage()},
    {'title': 'Sessions', 'icon': Icons.calendar_month},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Building the homepage
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFA23E2E),
        title: Text("D&D Companion App"),
        actions: [
          IconButton(onPressed: null, icon: Icon(Icons.account_circle)),
          IconButton(onPressed: null, icon: Icon(Icons.logout)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Text("Welcome, John", style: TextStyle(fontSize: 30)),
            // Idea: have the title change greetings based on the time of day
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(170, 130),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CharacterPage()),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(
                        pages[0]['icon'],
                        size: 35,
                        color: Color(0xFF6B4E24),
                      ),
                      Text(
                        pages[0]['title'],
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF6B4E24),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(170, 130),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Compendium()),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(
                        pages[1]['icon'],
                        size: 35,
                        color: Color(0xFF6B4E24),
                      ),
                      Text(
                        pages[1]['title'],
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF6B4E24),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(170, 130),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FriendsPage()),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(
                        pages[2]['icon'],
                        size: 35,
                        color: Color(0xFF6B4E24),
                      ),
                      Text(
                        pages[2]['title'],
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF6B4E24),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(170, 130),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SessionsPage()),
                    );
                  },
                  child: Column(
                    children: [
                      Icon(
                        pages[3]['icon'],
                        size: 35,
                        color: Color(0xFF6B4E24),
                      ),
                      Text(
                        pages[3]['title'],
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF6B4E24),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Recent Notifications",
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
            // A Container that holds any notifications the user has missed
            // Container(
            //   padding: EdgeInsets.only(left: 20, right: 20, top: 10),
            //   height: 300,
            //   child: ListView.builder(
            //     itemCount: 10,
            //     itemBuilder: (context, index){
            //       return Card(
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.zero,
            //         ),
            //         child: Row(
            //           children: [
            //             Container(
            //               width: 10,
            //               height: 40,
            //               color: Colors.lightBlue,
            //             ),
            //             Column(
            //               children: [
            //                 Text("New Charcter added!"),
            //                 Text("jim239 created a new character!")
            //               ],
            //             )
            //
            //           ],
            //
            //         ),
            //       );
            //     }
            //   ),
            // ),
            SizedBox(height: 40),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Upcoming Sessions",
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
