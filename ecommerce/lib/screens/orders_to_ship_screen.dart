import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../models/api_config.dart';
import 'order_detail_screen.dart';

class OrdersToShipScreen extends StatefulWidget {
  const OrdersToShipScreen({super.key});

  @override
  State<OrdersToShipScreen> createState() => _OrdersToShipScreenState();
}

class _OrdersToShipScreenState extends State<OrdersToShipScreen> {
  List<Map<String, String>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final api = Provider.of<ApiConfig>(context, listen: false);
      final auth = 'Basic ${base64.encode(utf8.encode('${api.apiKey}:'))}';
      final url = '${api.apiUrl}/orders';

      final res = await http.get(Uri.parse('$url?display=[id,date_add,total_paid,id_customer,current_state]'), headers: {
        'Authorization': auth,
      });

      if (res.statusCode != 200) throw Exception("Erreur chargement commandes");

      final doc = XmlDocument.parse(res.body);
      final orders = doc.findAllElements('order');

      final futures = orders.map((e) async {
        final id = e.getElement('id')?.text ?? '';
        final date = e.getElement('date_add')?.text ?? '';
        final total = e.getElement('total_paid')?.text ?? '';
        final state = e.getElement('current_state')?.text ?? '';
        final customerId = e.getElement('id_customer')?.text ?? '';

        if (state != '3') return null; // Statut à expédier

        final customerRes = await http.get(Uri.parse('${api.apiUrl}/customers/$customerId'),
            headers: {'Authorization': auth});
        if (customerRes.statusCode != 200) return null;

        final customerDoc = XmlDocument.parse(customerRes.body);
        final first = customerDoc.findAllElements('firstname').first.text;
        final last = customerDoc.findAllElements('lastname').first.text;

        return {
          'id': id,
          'date': date.split(' ')[0],
          'total': total,
          'customer': '$first $last',
        };
      });

      final results = await Future.wait(futures);
      setState(() {
        _orders = results.whereType<Map<String, String>>().toList();
        _loading = false;
      });
    } catch (e) {
      print("Erreur API: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Commandes à expédier")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _orders.length,
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderDetailScreen(id: order['id'] ?? ''),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Commande #${order['id']}",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("Client: ${order['customer']}"),
                          Text("Date: ${order['date']}"),
                          Text("Total: ${order['total']} €"),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
