import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  static IconData iconForCategory(String category) {
    final key = category.toLowerCase();
    if (key.contains('fruit') || key.contains('légume')) return Icons.eco_rounded;
    if (key.contains('boisson') || key.contains('drink')) return Icons.local_drink_rounded;
    if (key.contains('lait') || key.contains('dairy')) return Icons.egg_rounded;
    if (key.contains('viande') || key.contains('meat')) return Icons.set_meal_rounded;
    if (key.contains('pain') || key.contains('boulanger')) return Icons.bakery_dining_rounded;
    if (key.contains('snack') || key.contains('grignot')) return Icons.cookie_rounded;
    if (key.contains('hygiène') || key.contains('beaut')) return Icons.spa_rounded;
    if (key.contains('ménage') || key.contains('clean')) return Icons.cleaning_services_rounded;
    return Icons.category_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 88,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : AppColors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                boxShadow: isSelected ? AppColors.elevatedShadow : AppColors.cardShadow,
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade100),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
