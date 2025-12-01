import 'package:dnd_app/user_profile/registration.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dnd_app/screens/friends.dart';
import 'package:dnd_app/screens/characters/characters.dart';
import 'package:dnd_app/screens/sessions.dart';
import 'package:dnd_app/screens/compendium/compendium.dart';
import 'package:dnd_app/databases/user_database.dart';
import 'package:dnd_app/user_profile/login.dart';
import 'package:dnd_app/user_profile/profile.dart';


void main() async {
  // Initialize sqflite for different platforms if needed
  // sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Store the user for constant use across the app
  User? user;

  late final u = widget.username;
  // Pages list for navigation
  late List<Map<String, dynamic>> pages;

  Future<void> loadUser() async {
    user = await UserDatabase.instance.getUserByUsername(widget.username);
    // Naivagtion pages
    pages = [
      {
        'title': 'Characters',
        'icon': Icons.add,
        'screen': CharacterPage(thisUsername: u, userId: user?.id),
      },
      {'title': 'Compendium', 'icon': Icons.shield, 'screen': Compendium()},
      {
        'title': 'Friends',
        'icon': Icons.people,
        'screen': FriendsPage(userId: user?.id),
      },
      {
        'title': 'Sessions',
        'icon': Icons.calendar_month,
        'screen': SessionsPage(username: u),
      },
    ];

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Color(0xFF6B4E24))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text('Logout', style: TextStyle(color: Color(0xFFA23E2E))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // To prevent back button on homepage
        title: Text("D&D Companion App"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    username: widget.username,
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              );
            },
            icon: Icon(Icons.account_circle, color: Colors.white,),
            tooltip: widget.username,
          ),
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout, color: Colors.white,),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            // Future builder to get snapshot of user data
            Text(
              style: TextStyle(fontSize: 30),
              "Welcome, ${user?.displayName ?? user?.firstName}",
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildMenuButton(0), _buildMenuButton(1)],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildMenuButton(2), _buildMenuButton(3)],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(int index) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(170, 130),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      onPressed: () {
        if (pages[index]['screen'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pages[index]['screen']),
          );
        }
      },
      child: Column(
        children: [
          Icon(pages[index]['icon'], size: 35, color: Color(0xFF6B4E24)),
          Text(
            pages[index]['title'],
            style: TextStyle(fontSize: 20, color: Color(0xFF6B4E24)),
          ),
        ],
      ),
    );
  }
}