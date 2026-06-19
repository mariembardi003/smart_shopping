import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final order = await provider.createOrder(paymentMethod: 'Espèces');
    if (!mounted) return;
    if (order != null) {
      Navigator.pushReplacementNamed(context, '/order-confirmation', arguments: order);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Erreur lors de la commande'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.cartItems.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Panier vide',
              subtitle: 'Ajoutez des produits avant de passer commande.',
              actionLabel: 'Retour à la boutique',
              onAction: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
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
                        const Text(
                          'Résumé de commande',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${provider.cartTotal.toStringAsFixed(2)} TND',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${provider.cartItemCount} article${provider.cartItemCount > 1 ? 's' : ''}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...provider.cartItems.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          Text('×${item.quantity}'),
                          const SizedBox(width: 16),
                          Text(
                            '${item.totalPrice.toStringAsFixed(2)} TND',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Paiement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.payments_outlined, color: AppColors.primary),
                            SizedBox(width: 12),
                            Text('Espèces à la livraison', style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Confirmer la commande',
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: provider.isLoading,
                    onPressed: _submitOrder,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
