// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Accueil')),
      body: ListView(
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
