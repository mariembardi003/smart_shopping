import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class CashierScreen extends StatelessWidget {
  const CashierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Espace Caissier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await context.read<AppProvider>().signOut();
              if (context.mounted) navigator.pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Smart Shopping Caissier',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Validez les paiements clients via QR code',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _ActionCard(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Scanner QR client',
              subtitle: 'Valider le paiement d\'une commande client',
              color: AppColors.primary,
              isPrimary: true,
              onTap: () => Navigator.pushNamed(context, '/cashier/validate-qr'),
            ),
            const SizedBox(height: 14),
            _ActionCard(
              icon: Icons.receipt_long_outlined,
              title: 'Gestion des factures',
              subtitle: 'Consulter et imprimer les factures',
              color: Colors.blue.shade600,
              onTap: () => Navigator.pushNamed(context, '/cashier/invoices'),
            ),
            const SizedBox(height: 14),
            _ActionCard(
              icon: Icons.add_shopping_cart_outlined,
              title: 'Nouvelle facture',
              subtitle: 'Créer une facture manuelle',
              color: Colors.orange.shade700,
              onTap: () => Navigator.pushNamed(context, '/cashier/create-invoice'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: isPrimary ? AppColors.elevatedShadow : AppColors.cardShadow,
            border: isPrimary ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2) : null,
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
