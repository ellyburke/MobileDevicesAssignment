// Sessions screen

import 'package:flutter/material.dart';

class SessionsPage extends StatefulWidget{
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Sessions tab"),
        actions: [
          IconButton(onPressed: null, icon: Icon(Icons.account_circle)),
          IconButton(onPressed: null, icon: Icon(Icons.logout))
        ],
      ),
    );
  }
}