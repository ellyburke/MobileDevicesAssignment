import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'contentPage.dart';

class Example {
  var thing1;
  var thing2;
  var thing3;

  Example(this.thing1, this.thing2, this.thing3);
}

class CompendiumPage extends StatefulWidget {
  final List<Example> things = <Example>[
    Example("cat", "dog", "fish"),
    Example("apple", "banana", "orange"),
    Example("red", "blue", "yellow"),
  ];

  CompendiumPage({super.key});

  @override
  CompendiumPageState createState() => CompendiumPageState();
}

class CompendiumPageState extends State<CompendiumPage> {
  String chosenValue = "pick something";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Compendium Page"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Color(0xFFC2A878)),
            padding: EdgeInsets.all(10),
            height: 200,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "This is a label"),
                ),
                DropdownMenu(
                  initialSelection: Text("Hey look"),
                  dropdownMenuEntries: <DropdownMenuEntry>[
                    DropdownMenuEntry<String>(
                      value: chosenValue,
                      label: ("label"),
                    ),
                  ],
                  hintText: "pick something",
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              width: MediaQuery.sizeOf(context).width - 20,
              child: ListView.separated(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContentPage(),
                        ), // Navigates to the FormPage when pressed
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    leading: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      width: 10.0,
                      height: double.infinity,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Colors.red),
                      ),
                    ),
                    title: Text(widget.things[index].thing1),
                    subtitle: Text(widget.things[index].thing2),
                    tileColor: Colors.white,
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
