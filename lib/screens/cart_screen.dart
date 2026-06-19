import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state.dart';

class CartScreen extends StatelessWidget {
  final bool showBottomNav;

  const CartScreen({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Panier'),
        actions: [
          Consumer<AppProvider>(
            builder: (context, provider, _) {
              if (provider.cartItems.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Vider le panier',
                onPressed: () => _showClearCartDialog(context, provider),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final cartItems = provider.cartItems;

          if (cartItems.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Votre panier est vide',
              subtitle: 'Scannez des produits ou parcourez la boutique pour commencer.',
              actionLabel: 'Continuer vos achats',
              onAction: () {
                if (showBottomNav) {
                  // handled by shell navigation
                } else {
                  Navigator.pushNamed(context, '/home');
                }
              },
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) => _CartItemCard(
                    cartItem: cartItems[index],
                    onIncrement: () => provider.incrementQuantity(cartItems[index].id),
                    onDecrement: () => provider.decrementQuantity(cartItems[index].id),
                    onRemove: () {
                      final name = cartItems[index].product.name;
                      provider.removeFromCart(cartItems[index].id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$name supprimé'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),
              _CartSummary(
                itemCount: provider.cartItemCount,
                total: provider.cartTotal,
                isLoading: provider.isLoading,
                onCheckout: () {
                  if (provider.isLoading) return;
                  Navigator.pushNamed(context, '/checkout');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        title: const Text('Vider le panier ?'),
        content: const Text('Êtes-vous sûr de vouloir supprimer tous les articles ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              provider.clearCart();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = cartItem.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.price.toStringAsFixed(2)} TND',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: onRemove,
                  color: AppColors.textHint,
                  visualDensity: VisualDensity.compact,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QtyButton(icon: Icons.remove_rounded, onTap: onDecrement),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '${cartItem.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                      _QtyButton(icon: Icons.add_rounded, onTap: onIncrement),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${cartItem.totalPrice.toStringAsFixed(2)} TND',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: AppColors.primaryLight.withValues(alpha: 0.2),
      child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int itemCount;
  final double total;
  final bool isLoading;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.itemCount,
    required this.total,
    required this.isLoading,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    Text(
                      '$itemCount article${itemCount > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ),
                Text(
                  '${total.toStringAsFixed(2)} TND',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Passer la commande',
              icon: Icons.arrow_forward_rounded,
              isLoading: isLoading,
              onPressed: onCheckout,
            ),
          ],
        ),
      ),
    );
  }
}
