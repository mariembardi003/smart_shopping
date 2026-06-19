import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/order.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/order_qr_codec.dart';

class OrderDetailsCard extends StatelessWidget {
  final Order order;
  final bool showQrCode;
  final String? customerName;

  const OrderDetailsCard({
    super.key,
    required this.order,
    this.showQrCode = true,
    this.customerName,
  });

  String get _statusLabel {
    if (order.isPaymentValidated) return 'Payée / Validée';
    return switch (order.status) {
      OrderStatus.pending => 'En attente de paiement',
      OrderStatus.processing => 'En traitement',
      OrderStatus.shipped => 'Expédiée',
      OrderStatus.delivered => 'Livrée',
      OrderStatus.cancelled => 'Annulée',
    };
  }

  Color get _statusColor {
    if (order.isPaymentValidated) return AppColors.primary;
    return switch (order.status) {
      OrderStatus.pending => AppColors.warning,
      OrderStatus.processing => Colors.blue,
      OrderStatus.shipped => Colors.purple,
      OrderStatus.delivered => AppColors.primary,
      OrderStatus.cancelled => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
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
                  const Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Text('Détails de la commande', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor),
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              _row('N° commande', order.id),
              _row('Date', order.createdAt.toLocal().toString().split('.').first),
              if (customerName != null && customerName!.isNotEmpty)
                _row('Client', customerName!),
              _row('Paiement', order.paymentMethod ?? 'Espèces'),
              const SizedBox(height: 8),
              const Text('Articles', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 12),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              '${item.quantity} × ${item.product.price.toStringAsFixed(2)} TND',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.totalPrice.toStringAsFixed(2)} TND',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  Text(
                    '${order.totalAmount.toStringAsFixed(2)} TND',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showQrCode) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                const Text(
                  'QR Code de paiement',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Présentez ce code au caissier pour valider votre paiement',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),
                QrImageView(
                  data: OrderQrCodec.encode(order),
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
