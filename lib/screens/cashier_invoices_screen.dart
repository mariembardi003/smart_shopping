import 'package:flutter/material.dart';

import '../models/order.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'cashier_invoice_detail_screen.dart';

class CashierInvoicesScreen extends StatelessWidget {
  const CashierInvoicesScreen({super.key});

  Widget _statusChip(OrderStatus status) {
    final (color, bg) = switch (status) {
      OrderStatus.pending => (Colors.orange.shade800, Colors.orange.shade100),
      OrderStatus.processing => (Colors.blue.shade800, Colors.blue.shade100),
      OrderStatus.shipped => (Colors.purple.shade800, Colors.purple.shade100),
      OrderStatus.delivered => (AppColors.primaryDark, AppColors.primaryLight.withValues(alpha: 0.3)),
      OrderStatus.cancelled => (AppColors.error, AppColors.error.withValues(alpha: 0.1)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Factures')),
      body: StreamBuilder<List<Order>>(
        stream: FirestoreService().getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Aucune facture',
              subtitle: 'Les factures apparaîtront ici après validation des paiements.',
              actionLabel: 'Nouvelle facture',
              onAction: () => Navigator.pushNamed(context, '/cashier/create-invoice'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CashierInvoiceDetailScreen(order: order)),
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: AppColors.cardShadow,
                    ),
                    padding: const EdgeInsets.all(18),
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
                              child: const Icon(Icons.receipt_rounded, color: AppColors.primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Facture #${order.id.substring(0, 6)}',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                  Text(
                                    order.createdAt.toLocal().toString().split('.').first,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            _statusChip(order.status),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${order.items.length} articles', style: const TextStyle(color: AppColors.textSecondary)),
                            Text(
                              '${order.totalAmount.toStringAsFixed(2)} TND',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/cashier/create-invoice'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle facture'),
      ),
    );
  }
}
