import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert' show utf8, base64;
import 'package:provider/provider.dart';
import '../models/api_config.dart';

import 'product_detail_screen.dart'; 

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Map<String, String>> _products = [];
  bool _loading = true;

  //final String apiUrl = 'http://localhost:8080/api/products';
 // final String apiKey = '749UUAHKQ8H6TTUBTYNXCJGSSKBWESBT'; 

  @override
  void initState() {
    super.initState();
    //fetchProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    fetchProducts(context);
  });
  }

  Future<void> fetchProducts(BuildContext context) async 
  {
    final apiConfig = Provider.of<ApiConfig>(context, listen: false);
    final apiKey =apiConfig.apiKey; //'749UUAHKQ8H6TTUBTYNXCJGSSKBWESBT';
    final apiUrl = '${apiConfig.apiUrl}/products'; //'http://localhost:8080/api/products';

  final auth = 'Basic ${base64.encode(utf8.encode('$apiKey:'))}';
  final res = await http.get(Uri.parse(apiUrl), headers: {'Authorization': auth});

  if (res.statusCode == 200) {
    final xmlDoc = XmlDocument.parse(res.body);
    final productElements = xmlDoc.findAllElements('product');

    final futures = productElements.map((product) async {
      final id = product.getAttribute('id') ?? '';
      final detailUrl = '$apiUrl/$id';

      final detailRes = await http.get(Uri.parse(detailUrl), headers: {'Authorization': auth});
      if (detailRes.statusCode == 200) {
        final detailXml = XmlDocument.parse(detailRes.body);
        final nameElement = detailXml.findAllElements('name').first;
        final name = nameElement.findElements('language').first.text;

        return {'id': id, 'name': name};
      } else {
        return null;
      }
    });

    final results = await Future.wait(futures);

    setState(() {
      _products = results.whereType<Map<String, String>>().toList();
      _loading = false;
    });
  } else {
    throw Exception('Erreur API produits : ${res.statusCode}');
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
                  title: Text(p['name'] ?? 'Sans nom'),
                  subtitle: Text('ID: ${p['id']}'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          id: p['id'] ?? '',
                          name: p['name'] ?? '',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
