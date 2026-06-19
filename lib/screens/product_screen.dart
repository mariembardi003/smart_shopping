import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class ProductScreen extends StatelessWidget {
  final Product product;

  const ProductScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} TND',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        _StockBadge(stock: product.stock),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Description',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.6),
                    ),
                    if (product.barcode.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.qr_code_rounded, size: 18, color: AppColors.textHint),
                          const SizedBox(width: 8),
                          Text('Code: ${product.barcode}', style: const TextStyle(color: AppColors.textHint)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                    CustomButton(
                      text: product.stock > 0 ? 'Ajouter au panier' : 'Rupture de stock',
                      icon: Icons.add_shopping_cart_rounded,
                      onPressed: product.stock > 0
                          ? () {
                              context.read<AppProvider>().addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} ajouté au panier'),
                                  backgroundColor: AppColors.primaryDark,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.primaryLight.withValues(alpha: 0.2),
      child: const Center(
        child: Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.primary),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;

  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final inStock = stock > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: inStock ? AppColors.primaryLight.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: inStock ? AppColors.primary : AppColors.error,
          ),
          const SizedBox(width: 6),
          Text(
            inStock ? '$stock en stock' : 'Rupture',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: inStock ? AppColors.primaryDark : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
