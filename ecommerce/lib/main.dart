import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show utf8, base64;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String apiUrl = "http://localhost:8080/api/orders"; 
  final String apiKey = "749UUAHKQ8H6TTUBTYNXCJGSSKBWESBT";

  Future<String> fetchOrders() async {
    final basicAuth = 'Basic ' + base64.encode(utf8.encode('$apiKey:'));
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception("Échec : ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prestashop API Test',
      home: Scaffold(
        appBar: AppBar(title: Text("Test API Prestashop")),
        body: FutureBuilder<String>(
          future: fetchOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Erreur: ${snapshot.error}"));
            } else {
              return SingleChildScrollView(
                padding: EdgeInsets.all(10),
                child: Text(snapshot.data ?? '', style: TextStyle(fontSize: 12)),
              );
            }
          },
        ),
      ),
    );
  }
}
