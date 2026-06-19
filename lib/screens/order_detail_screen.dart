import 'package:flutter/material.dart';

import '../models/order.dart';
import '../theme/app_colors.dart';
import '../widgets/order_details_card.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  final String? customerName;

  const OrderDetailScreen({
    super.key,
    required this.order,
    this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Commande #${order.id.substring(0, 8)}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: OrderDetailsCard(
          order: order,
          showQrCode: !order.isPaymentValidated,
          customerName: customerName,
        ),
      ),
    );
  }
}
