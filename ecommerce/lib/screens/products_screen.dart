// lib/screens/products_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert' show utf8, base64;

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Map<String, String>> _products = [];
  bool _loading = true;
  final String apiUrl = 'http://localhost:8080/api/products';
  final String apiKey = '749UUAHKQ8H6TTUBTYNXCJGSSKBWESBT';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final auth = 'Basic ${base64.encode(utf8.encode('$apiKey:'))}';
    final res = await http.get(Uri.parse(apiUrl), headers: {'Authorization': auth});

    if (res.statusCode == 200) {
      final xmlDoc = XmlDocument.parse(res.body);
      final products = xmlDoc.findAllElements('product');

      setState(() {
        _products = products.map((node) {
          final id = node.getAttribute('id') ?? '';
          final link = node.getAttribute('xlink:href') ?? '';
          return {'id': id, 'link': link};
        }).toList();
        _loading = false;
      });
    } else {
      throw Exception('Erreur Prestashop API : ${res.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produits')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final p = _products[index];
                return ListTile(
                  title: Text('Produit ID: ${p['id']}'),
                  subtitle: Text(p['link'] ?? ''),
                );
              },
            ),
    );
  }
}
