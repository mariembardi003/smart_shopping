import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_search_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_banner.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  final bool showBottomNav;

  const HomeScreen({super.key, this.showBottomNav = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query, AppProvider provider) {
    provider.searchClientCatalog(query);
    if (query.trim().length < 2) return;
    final results = provider.clientSearchResults;
    _showSearchResults(context, results, query);
  }

  void _showSearchResults(BuildContext context, List<Product> results, String query) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Résultats pour "$query"',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? EmptyState(
                        icon: Icons.qr_code_scanner_rounded,
                        title: 'Aucun produit trouvé',
                        subtitle: 'Scannez le code-barres du produit pour l\'ajouter à votre panier.',
                        actionLabel: 'Ouvrir le scanner',
                        onAction: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/scanner');
                        },
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: results.length + 1,
                        itemBuilder: (context, index) {
                          if (index == results.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/scanner');
                                },
                                icon: const Icon(Icons.qr_code_scanner_rounded),
                                label: const Text('Scanner un autre produit'),
                              ),
                            );
                          }
                          final product = results[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
                              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                            ),
                            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${product.price.toStringAsFixed(2)} TND'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/product', arguments: product);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productSection(String title, List<Product> products) {
    if (products.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 175,
                child: ProductCard(
                  product: product,
                  onAddToCart: () => _addToCart(context, product),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final featured = provider.featuredProducts;
            final promotional = provider.promotionalProducts;
            final user = provider.currentUser;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, user?.name ?? 'Client', provider.cartItemCount)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: AppSearchBar(
                      controller: _searchController,
                      hintText: 'Rechercher un produit vedette...',
                      onChanged: (q) => provider.searchClientCatalog(q),
                      onSubmitted: (q) => _onSearch(q, provider),
                      onClear: () {
                        _searchController.clear();
                        provider.searchClientCatalog('');
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: PromoBanner(onTap: () => Navigator.pushNamed(context, '/scanner')),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(child: _productSection('Produits vedettes', featured)),
                SliverToBoxAdapter(child: _productSection('Produits en promotion', promotional)),
                if (featured.isEmpty && promotional.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: EmptyState(
                        icon: Icons.star_outline_rounded,
                        title: 'Aucun produit en vedette',
                        subtitle: 'Parcourez le catalogue en scannant les codes-barres des produits en magasin.',
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, size: 48, color: AppColors.primary.withValues(alpha: 0.8)),
                          const SizedBox(height: 16),
                          const Text(
                            'Découvrez nos produits en scannant',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Smart Shopping est conçu pour le scan & go. Scannez les codes-barres pour ajouter des produits à votre panier.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/scanner'),
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                            label: const Text('Scanner un produit'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName, int cartCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusXl),
          bottomRight: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, $userName 👋',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Scannez, payez, partez !',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            icon: Icons.shopping_bag_outlined,
            badge: cartCount,
            onTap: () => Navigator.pushNamed(context, '/cart'),
          ),
          const SizedBox(width: 8),
          _HeaderIconButton(
            icon: Icons.receipt_long_outlined,
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context, Product product) {
    context.read<AppProvider>().addToCart(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ajouté au panier'),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final int badge;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, this.badge = 0, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            if (badge > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
