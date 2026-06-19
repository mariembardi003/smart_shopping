import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<Map<String, dynamic>> _loadStats() async {
    final firestore = FirestoreService();
    final totalProducts = await firestore.getProductCount();
    final summary = await firestore.getOrderSummary();
    final cashiers = await firestore.getUsersCountByRole('cashier');
    final clients = await firestore.getUsersCountByRole('client');
    final admins = await firestore.getUsersCountByRole('admin');
    final complaints = await firestore.getComplaints().first;
    return {
      'products': totalProducts,
      'orders': summary['orders'] ?? 0,
      'sales': summary['sales'] ?? 0.0,
      'cashiers': cashiers,
      'users': clients + cashiers + admins,
      'complaints': complaints.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppTheme.radiusXl),
                    bottomRight: Radius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tableau de bord',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gestion Smart Shopping',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await context.read<AppProvider>().signOut();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _loadStats(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    }
                    final stats = snapshot.data ?? {};
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isWide ? 2 : 1,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: isWide ? 2.8 : 2.4,
                          children: [
                            StatCard(
                              title: 'Produits',
                              value: '${stats['products'] ?? 0}',
                              icon: Icons.inventory_2_rounded,
                              color: AppColors.primary,
                            ),
                            StatCard(
                              title: 'Commandes',
                              value: '${stats['orders'] ?? 0}',
                              icon: Icons.receipt_long_rounded,
                              color: Colors.orange.shade700,
                            ),
                            StatCard(
                              title: 'Ventes totales',
                              value: '${(stats['sales'] ?? 0.0).toStringAsFixed(0)} TND',
                              icon: Icons.trending_up_rounded,
                              color: Colors.purple.shade600,
                            ),
                            StatCard(
                              title: 'Utilisateurs',
                              value: '${stats['users'] ?? 0}',
                              icon: Icons.people_rounded,
                              color: Colors.blue.shade600,
                              subtitle: '${stats['cashiers'] ?? 0} caissiers',
                            ),
                            StatCard(
                              title: 'Réclamations',
                              value: '${stats['complaints'] ?? 0}',
                              icon: Icons.support_agent_rounded,
                              color: Colors.red.shade400,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Gestion',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isWide ? 4 : 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.95,
                          children: [
                            DashboardActionCard(
                              label: 'Produits',
                              icon: Icons.inventory_2_outlined,
                              color: AppColors.primary,
                              onTap: () => Navigator.pushNamed(context, '/admin/products'),
                            ),
                            DashboardActionCard(
                              label: 'Utilisateurs',
                              icon: Icons.people_outline,
                              color: Colors.blue.shade600,
                              onTap: () => Navigator.pushNamed(context, '/admin/users'),
                            ),
                            DashboardActionCard(
                              label: 'Caissiers',
                              icon: Icons.storefront_outlined,
                              color: Colors.orange.shade700,
                              onTap: () => Navigator.pushNamed(context, '/admin/cashiers'),
                            ),
                            DashboardActionCard(
                              label: 'Réclamations',
                              icon: Icons.mail_outline,
                              color: Colors.red.shade400,
                              onTap: () => Navigator.pushNamed(context, '/admin/complaints'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
