import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // SECTION : Résumé chiffres
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _summaryCard(Icons.shopping_cart, 'Commandes', '152', Colors.blue),
                _summaryCard(Icons.inventory_2_outlined, 'Produits', '340', Colors.orange),
                _summaryCard(Icons.group, 'Clients', '97', Colors.green),
                _summaryCard(Icons.warning_amber_rounded, 'Tâches', '6', Colors.red),
              ],
            ),
            const SizedBox(height: 24),

            // SECTION : Accès rapide
            _quickAccessTile(context, Icons.receipt_long, 'Commandes', '/orders'),
            _quickAccessTile(context, Icons.category, 'Produits', '/products'),
            _quickAccessTile(context, Icons.people, 'Clients', '/clients'),
            _quickAccessTile(context, Icons.task, 'Tâches à faire', '/tasks'),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(IconData icon, String label, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.black54)),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _quickAccessTile(BuildContext context, IconData icon, String title, String route) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}


