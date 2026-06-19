import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  Widget _statusChip(String status) {
    final (color, bg) = switch (status) {
      'pending' => (Colors.orange.shade800, Colors.orange.shade100),
      'processing' => (Colors.blue.shade800, Colors.blue.shade100),
      'shipped' => (Colors.purple.shade800, Colors.purple.shade100),
      'delivered' => (AppColors.primaryDark, AppColors.primaryLight.withValues(alpha: 0.3)),
      'cancelled' => (AppColors.error, AppColors.error.withValues(alpha: 0.1)),
      _ => (AppColors.textSecondary, AppColors.background),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mes commandes')),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final orders = provider.orders;
          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Aucune commande',
              subtitle: 'Vos commandes passées apparaîtront ici.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return InkWell(
                onTap: () => Navigator.pushNamed(context, '/order-detail', arguments: order),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Commande #${order.id.substring(0, 6)}',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              Text(
                                order.createdAt.toLocal().toString().split('.').first,
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        _statusChip(order.status.name),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${order.items.length} articles', style: const TextStyle(color: AppColors.textSecondary)),
                        Text(
                          '${order.totalAmount.toStringAsFixed(2)} TND',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
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
