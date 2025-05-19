import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert' show utf8, base64;
import 'package:provider/provider.dart';
import '../models/api_config.dart';
import 'product_detail_screen.dart';


class LowStockScreen extends StatefulWidget {
  const LowStockScreen({super.key});

  @override
  State<LowStockScreen> createState() => _LowStockScreenState();
}

class _LowStockScreenState extends State<LowStockScreen> {
  bool _loading = true;
  List<Map<String, String>> _products = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchLowStock());
  }

  Future<void> _fetchLowStock() async {
    final apiConfig = Provider.of<ApiConfig>(context, listen: false);
    final auth = 'Basic ${base64.encode(utf8.encode('${apiConfig.apiKey}:'))}';

    try {
      // Récupérer tous les produits
      final productsRes = await http.get(
        Uri.parse('${apiConfig.apiUrl}/products?display=[id,name]'),
        headers: {'Authorization': auth},
      );
      if (productsRes.statusCode != 200) throw Exception("Erreur produits");

      final productsDoc = XmlDocument.parse(productsRes.body);
      final productElements = productsDoc.findAllElements('product');

      List<Map<String, String>> lowStockProducts = [];

      // Pour chaque produit vérif stock
      for (var p in productElements) 
      {
        final id = p.getElement('id')?.text ?? '';
        final name = p.getElement('name')?.text ?? '';

        // Récup stock dispo
        final stockRes = await http.get
        (
          Uri.parse('${apiConfig.apiUrl}/stock_availables?filter[id_product]=[$id]'),
          headers: {'Authorization': auth},
        );
        if (stockRes.statusCode != 200) continue;

        final stockDoc = XmlDocument.parse(stockRes.body);
        final stockElements = stockDoc.findAllElements('stock_available');

        for (var s in stockElements) {
          final quantity = int.tryParse(s.getElement('quantity')?.text ?? '0') ?? 0;
          if (quantity < 15) 
          {
            lowStockProducts.add({
              'id': id,
              'name': name,
              'quantity': quantity.toString(),
            });
            break;
          }
        }
      }

      setState(() {
        _products = lowStockProducts;
        _loading = false;
      });
    } catch (e) {
      print("Erreur: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Produits en faible stock")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text("Aucun produit en faible stock"))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ListTile(
                      title: Text(product['name'] ?? ''),
                      subtitle: Text("Stock actuel : ${product['quantity']}"),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(id: product['id']!, name: product['name']!)));
                      },
                    );
                  },
                ),
    );
  }
}
