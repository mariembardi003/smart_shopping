import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<Map<String, dynamic>> _loadStats() async {
    final totalProducts = await FirestoreService().getProductCount();
    final summary = await FirestoreService().getOrderSummary();
    final cashiers = await FirestoreService().getUsersCountByRole('cashier');
    return {
      'products': totalProducts,
      'orders': summary['orders'] ?? 0,
      'sales': summary['sales'] ?? 0.0,
      'cashiers': cashiers,
    };
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 8),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord admin'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final stats = snapshot.data ?? {};
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _statCard('Produits', '${stats['products'] ?? 0}', Colors.green.shade700, Icons.inventory_2_outlined),
                const SizedBox(height: 12),
                _statCard('Commandes', '${stats['orders'] ?? 0}', Colors.orange.shade700, Icons.receipt_long),
                const SizedBox(height: 12),
                _statCard('Ventes', '${(stats['sales'] ?? 0.0).toStringAsFixed(2)} TND', Colors.purple.shade700, Icons.monetization_on_outlined),
                const SizedBox(height: 12),
                _statCard('Caissiers', '${stats['cashiers'] ?? 0}', Colors.blue.shade700, Icons.person_outline),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _dashboardButton(context, 'Produits', Icons.shopping_bag_outlined, '/admin/products'),
                      _dashboardButton(context, 'Commandes', Icons.receipt_long, '/admin/orders'),
                      _dashboardButton(context, 'Réclamations', Icons.support_agent, '/admin/support'),
                      _dashboardButton(context, 'Caissiers', Icons.person_search_outlined, '/admin/users'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dashboardButton(BuildContext context, String label, IconData icon, String route) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(backgroundColor: Colors.green.shade50, child: Icon(icon, color: Colors.green.shade700)),
            const SizedBox(height: 24),
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
