import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DnD App',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    // Building the homepage
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("D&D Companion App"),
        actions: [
          IconButton(onPressed: null, icon: Icon(Icons.account_circle)),
          IconButton(onPressed: null, icon: Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text("Welcome, John", style: TextStyle(fontSize: 45)),
            
          ],
        )
      ),
    );
  }
}
