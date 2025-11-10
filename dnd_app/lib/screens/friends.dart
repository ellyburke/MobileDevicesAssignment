import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget{
  const FriendsPage({super.key});
  
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>{
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFA23E2E),
          title: Text("Friends"),
          actions: [
            IconButton(onPressed: null, icon: Icon(Icons.account_circle)),
            IconButton(onPressed: null, icon: Icon(Icons.logout))
          ],
        ),
      body: Center(
        child: Text("Friend page coming soon!",
          style: TextStyle(fontSize: 20),),
      ),
    );
  }
}