import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/order_details_card.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final customerName = context.watch<AppProvider>().currentUser?.name;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Confirmation de commande')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Commande confirmée !',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Consultez les détails ci-dessous puis présentez le QR code au caissier.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      OrderDetailsCard(
                        order: order,
                        showQrCode: true,
                        customerName: customerName,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Retour à l\'accueil',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
