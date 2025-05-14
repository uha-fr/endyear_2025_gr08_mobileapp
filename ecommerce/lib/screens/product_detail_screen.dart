import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final String id;
  final String name;

  const ProductDetailScreen({required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produit #$id')),
      body: Center(
        child: Text("Nom du produit : $name", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
