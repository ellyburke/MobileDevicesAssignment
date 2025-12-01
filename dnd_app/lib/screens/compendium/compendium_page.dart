/*
Contributors: Ayaan Mustafa
Date: 2025/11/30
Purpose: Describe Widget for a single page of the compendium
 */

// imports
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'content.dart';
import 'content_page.dart';

// CompendiumPage Widget Class
class CompendiumPage extends StatefulWidget {
  // class fields
  final String category; // category of items

  // constructor
  const CompendiumPage({super.key, required this.category});

  // createState
  @override
  CompendiumPageState createState() => CompendiumPageState();
}

class CompendiumPageState extends State<CompendiumPage> {
  late Future<Response> futureResponse;

  // initState method
  @override
  void initState() {
    // call parent class initState()
    super.initState();
    // perform API call for all items in category
    futureResponse = fetchResponse();
  }

  // method that performs HTTP request
  Future<Response> fetchResponse() async {
    // make API call
    final response = await http.get(
      Uri.parse('https://www.dnd5eapi.co/api/2014/${widget.category}'),
    );

    // if successful return response as Response object
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Response.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load response');
    }
  }

  // build method that displays the items of the HTTP response
  // this will be a list of all the items in the chosen category
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,),
          title: Text("Compendium Page"),
        backgroundColor: Color(0xFFA23E2E),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
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
                      // On press navigate to that items page for details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ContentPage(
                              endpoint: snapshot.data!.results![index]["index"],
                              category: widget.category.replaceAll(
                                RegExp(r'\s'),
                                '-',
                              ),
                            );
                          },
                        ),
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
                        decoration: BoxDecoration(color: Color(0xFFA23E2E)),
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
            // by default show a loading spinner
            return const SizedBox(
              height: 200,
              width: 200,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF1E1B18)),
              ),
            );
          },
        ),
      ),
    );
  }
}
