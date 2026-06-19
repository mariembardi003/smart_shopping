import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/order.dart';
import '../services/pdf_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class CashierInvoiceDetailScreen extends StatelessWidget {
  final Order order;

  const CashierInvoiceDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Facture #${order.id.substring(0, 6)}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppColors.elevatedShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.status.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${order.totalAmount.toStringAsFixed(2)} TND',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${order.items.length} articles • ${order.createdAt.toLocal().toString().split('.').first}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Détails', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(
                                '${item.quantity} × ${item.product.price.toStringAsFixed(2)} TND',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item.totalPrice.toStringAsFixed(2)} TND',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Imprimer facture',
              icon: Icons.print_rounded,
              onPressed: () async {
                final bytes = await PdfService.generateInvoicePdf(order);
                if (!context.mounted) return;
                showModalBottomSheet<void>(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
                  ),
                  builder: (context) => SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Imprimer ou partager', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: 'Imprimer',
                            icon: Icons.print_rounded,
                            onPressed: () {
                              Navigator.pop(context);
                              Printing.layoutPdf(onLayout: (_) => bytes);
                            },
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            text: 'Partager',
                            icon: Icons.share_rounded,
                            outlined: true,
                            onPressed: () {
                              Navigator.pop(context);
                              Printing.sharePdf(bytes: bytes, filename: 'facture_${order.id}.pdf');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
