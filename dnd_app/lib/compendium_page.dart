import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'content.dart';
import 'content_page.dart';

class CompendiumPage extends StatefulWidget {
  final String category;

  const CompendiumPage({super.key, required this.category});

  @override
  CompendiumPageState createState() => CompendiumPageState();
}

class CompendiumPageState extends State<CompendiumPage> {
  late Future<Response> futureResponse;

  @override
  void initState() {
    super.initState();
    futureResponse = fetchResponse();
  }

  Future<Response> fetchResponse() async {
    final response = await http.get(
      Uri.parse('https://www.dnd5eapi.co/api/2014/${widget.category}'),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Response.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Compendium Page"),
        backgroundColor: Color(0xFFA23E2E),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Color(0xFFC2A878)),
            padding: EdgeInsets.all(10),
            height: 100,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: "Search (WIP)"),
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
              child: FutureBuilder(
                future: futureResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                      itemCount: snapshot.data!.count!,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ContentPage(
                                    endpoint:
                                        snapshot.data!.results![index]["index"],
                                    category: widget.category,
                                  );
                                },
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
                              decoration: BoxDecoration(
                                color: Color(0xFFA23E2E),
                              ),
                            ),
                          ),
                          title: Text(snapshot.data!.results![index]["name"]),
                          subtitle: Text(snapshot.data!.results![index]["url"]),
                          tileColor: Colors.white,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                    );
                  }
                  // By default, show a loading spinner.
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
