import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert' show utf8, base64;
import 'package:provider/provider.dart';
import '../models/api_config.dart';
import 'customer_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  bool _loading = true;
  List<Map<String, String>> _customers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCustomers());
  }

  Future<void> _fetchCustomers() async {
    final apiConfig = Provider.of<ApiConfig>(context, listen: false);
    final auth = 'Basic ${base64.encode(utf8.encode('${apiConfig.apiKey}:'))}';
    final apiUrl = '${apiConfig.apiUrl}/customers';

    try {
      final res = await http.get(Uri.parse(apiUrl), headers: {'Authorization': auth});
      if (res.statusCode != 200) throw Exception("Erreur chargement clients");

      final doc = XmlDocument.parse(res.body);
      final elements = doc.findAllElements('customer');

      // Récupérer détails clients
      final futures = elements.map((e) async {
        final id = e.getAttribute('id') ?? '';
        final detailUrl = '$apiUrl/$id';

        final detailRes = await http.get(Uri.parse(detailUrl), headers: {'Authorization': auth});
        if (detailRes.statusCode != 200) return null;

        final detailDoc = XmlDocument.parse(detailRes.body);
        final customer = detailDoc.findAllElements('customer').first;
        final firstName = customer.findElements('firstname').first.text;
        final lastName = customer.findElements('lastname').first.text;

        return {'id': id, 'firstname': firstName, 'lastname': lastName};
      });

      final results = await Future.wait(futures);
      setState(() {
        _customers = results.whereType<Map<String, String>>().toList();
        _loading = false;
      });
    } catch (e) {
      print("Erreur : $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clients')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final c = _customers[index];
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text('${c['firstname']} ${c['lastname']}'),
                  subtitle: Text('ID: ${c['id']}'),
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerDetailScreen(id: c['id']!),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
