// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/api_config.dart';


class HomeScreen extends StatefulWidget {
  
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accueil')),
      body: 
        ListView(
          children: 
          [
            ListTile(
              title: Text("Voir les produits"),
              onTap: () => Navigator.pushNamed(context, '/products'),
            ),
          ],
        ),
    );
  }
}
