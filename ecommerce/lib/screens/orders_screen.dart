import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert' show utf8, base64;
import 'package:provider/provider.dart';
import '../models/api_config.dart';

import 'product_detail_screen.dart'; 

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> 
{
  List<Map<String, String>> _orders = [];
  bool _loading = true;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    fetchOrders(context);
  });
  }

  Future<void> fetchOrders(BuildContext context) async 
  {
    final apiConfig = Provider.of<ApiConfig>(context, listen: false);
    final apiKey =apiConfig.apiKey; 
    final apiUrl = '${apiConfig.apiUrl}/orders'; 

  final auth = 'Basic ${base64.encode(utf8.encode('$apiKey:'))}';
  final res = await http.get(Uri.parse(apiUrl), headers: {'Authorization': auth});

  if (res.statusCode == 200) 
  {
    final xmlDoc = XmlDocument.parse(res.body);
    final orderElements = xmlDoc.findAllElements('order');

    final futures = orderElements.map((order) async 
    {
      final id = order.getAttribute('id') ?? '';
      final detailUrl = '$apiUrl/$id';

      final detailRes = await http.get(Uri.parse(detailUrl), headers: {'Authorization': auth});
      if (detailRes.statusCode == 200) 
      {
        final detailXml = XmlDocument.parse(detailRes.body);
        final reference = detailXml.findAllElements('reference').first.text;
        return {'id': id, 'name': reference};

      } 
      else {
        return null;
      }
    });

    final results = await Future.wait(futures);

    setState(() {
      _orders = results.whereType<Map<String, String>>().toList();
      _loading = false;
    });
  } else {
    throw Exception('Erreur API commandes : ${res.statusCode}');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder( 
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final p = _orders[index];
                return ListTile(
                  title: Text(p['name'] ?? 'Sans nom'),
                  subtitle: Text('ID: ${p['id']}'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () { 
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(
                          id: p['id'] ?? '',
                          name: p['name'] ?? '',
                        ),
                      ),
                    );*/
                  },
                );
              },
            ),
    );
  }
}
