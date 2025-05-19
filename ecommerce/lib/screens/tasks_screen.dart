import 'package:ecommerce/screens/orders_to_prepare_screen.dart';
import 'package:ecommerce/screens/orders_to_ship_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert' show base64, utf8;
import 'package:provider/provider.dart';
import '../models/api_config.dart';
import 'low_stock_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  int? lowStockCount;
  int? ordersToPrepareCount;
  int? ordersToShipCount;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchLowStockCount(),
      _fetchOrdersToPrepareCount(),
      _fetchOrdersToShipCount(),
    ]);
    setState(() => _loading = false);
  }

  Future<void> _fetchLowStockCount() async {
    try {
      final apiConfig = Provider.of<ApiConfig>(context, listen: false);
      final auth = 'Basic ${base64.encode(utf8.encode('${apiConfig.apiKey}:'))}';
      final apiUrl = '${apiConfig.apiUrl}/products';

      final res = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': auth,
      });

      if (res.statusCode != 200) throw Exception('Erreur chargement produits');

      final doc = XmlDocument.parse(res.body);
      final productIds = doc.findAllElements('product').map((e) => e.getAttribute('id')).whereType<String>().toList();

      int count = 0;

      final futures = productIds.map((id) async {
        final detailUrl = '$apiUrl/$id';
        final detailRes = await http.get(Uri.parse(detailUrl), headers: {'Authorization': auth});
        if (detailRes.statusCode != 200) return;

        final detailDoc = XmlDocument.parse(detailRes.body);
        final stock = detailDoc.findAllElements('quantity').first.text;

        if (int.tryParse(stock) != null && int.parse(stock) < 15) {
          count++;
        }
      });

      await Future.wait(futures);

      setState(() => lowStockCount = count);
    } catch (e) {
      print('Erreur produits : $e');
      setState(() => lowStockCount = 0);
    }
  }

  Future<void> _fetchOrdersToPrepareCount() async {
    try {
      final api = Provider.of<ApiConfig>(context, listen: false);
      final auth = 'Basic ${base64.encode(utf8.encode('${api.apiKey}:'))}';
      final res = await http.get(
        Uri.parse('${api.apiUrl}/orders?display=[id,current_state]'),
        headers: {'Authorization': auth},
      );

      if (res.statusCode != 200) throw Exception('Erreur chargement commandes');

      final doc = XmlDocument.parse(res.body);
      final orders = doc.findAllElements('order');

      int count = 0;
      for (var order in orders) {
        final state = order.getElement('current_state')?.text;
        if (state == '2') count++; // Paiement accepté
      }

      setState(() => ordersToPrepareCount = count);
    } catch (e) {
      print('Erreur commandes à préparer : $e');
      setState(() => ordersToPrepareCount = 0);
    }
  }

  Future<void> _fetchOrdersToShipCount() async {
    try {
      final api = Provider.of<ApiConfig>(context, listen: false);
      final auth = 'Basic ${base64.encode(utf8.encode('${api.apiKey}:'))}';
      final res = await http.get(
        Uri.parse('${api.apiUrl}/orders?display=[id,current_state]'),
        headers: {'Authorization': auth},
      );

      if (res.statusCode != 200) throw Exception('Erreur chargement commandes');

      final doc = XmlDocument.parse(res.body);
      final orders = doc.findAllElements('order');

      int count = 0;
      for (var order in orders) {
        final state = order.getElement('current_state')?.text;
        if (state == '3') count++; // Statut expédition
      }

      setState(() => ordersToShipCount = count);
    } catch (e) {
      print('Erreur commandes à expédier : $e');
      setState(() => ordersToShipCount = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Liste des tâches")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TaskItem(
                  title: 'Préparer les commandes',
                  subtitle: 'Préparez les commandes payées pour un retrait ou une expédition.',
                  badgeCount: ordersToPrepareCount ?? 0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersToPrepareScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TaskItem(
                  title: 'Commandes à expédier',
                  subtitle: 'Expédiez les commandes préparées',
                  badgeCount: ordersToShipCount ?? 0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersToShipScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TaskItem(
                  title: 'Produits à réapprovisionner',
                  subtitle: 'Consultez les produits à faible stock et réapprovisionnez-les si nécessaire.',
                  badgeCount: lowStockCount ?? 0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LowStockScreen()),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badgeCount;

  const TaskItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.badgeCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Theme.of(context).primaryColor.withOpacity(0.2),
        highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(subtitle, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
