import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert' show utf8, base64;
import 'dart:typed_data'; 
import 'package:provider/provider.dart';
import '../models/api_config.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchProducts(context);
    });
  }

  Future<void> fetchProducts(BuildContext context) async {
    final apiConfig = Provider.of<ApiConfig>(context, listen: false);
    final apiKey = apiConfig.apiKey;
    final baseApiUrl = apiConfig.apiUrl;
    final apiUrl = '$baseApiUrl/products';

    final authHeader = 'Basic ${base64.encode(utf8.encode('$apiKey:'))}';
    final res = await http.get(Uri.parse(apiUrl), headers: {'Authorization': authHeader});

    if (res.statusCode == 200) {
      final xmlDoc = XmlDocument.parse(res.body);
      final productElements = xmlDoc.findAllElements('product');

      final futures = productElements.map((product) async {
        final id = product.getAttribute('id') ?? '';
        final detailUrl = '$apiUrl/$id';

        final detailRes = await http.get(Uri.parse(detailUrl), headers: {'Authorization': authHeader});
        if (detailRes.statusCode == 200) {
          final detailXml = XmlDocument.parse(detailRes.body);
          final nameElement = detailXml.findAllElements('name').first;
          final name = nameElement.findElements('language').first.text;

          // récupération image
          final imageElement = detailXml.findAllElements('id_default_image').firstOrNull;
          Uint8List? imageBytes;

          if (imageElement != null && imageElement.text.isNotEmpty) {
            final imageId = imageElement.text;
            final imageUrl = '$baseApiUrl/images/products/$id/$imageId';

            try {
              final imageRes = await http.get(Uri.parse(imageUrl), headers: {'Authorization': authHeader});
              if (imageRes.statusCode == 200) {
                imageBytes = imageRes.bodyBytes;
              }
            } catch (_) {
            }
          }

          return {
            'id': id,
            'name': name,
            'image': imageBytes,
          };
        } else {
          return null;
        }
      });

      final results = await Future.wait(futures);

      setState(() {
        _products = results.whereType<Map<String, dynamic>>().toList();
        _loading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des produits')),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🛒 Produits')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('Aucun produit trouvé.', style: TextStyle(fontSize: 18)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final imageBytes = product['image'] as Uint8List?;

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                          child: imageBytes == null
                              ? const Icon(Icons.image_not_supported, color: Colors.grey)
                              : null,
                        ),
                        title: Text(
                          product['name'] ?? 'Sans nom',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text('ID: ${product['id']}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                id: product['id'] ?? '',
                                name: product['name'] ?? '',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
