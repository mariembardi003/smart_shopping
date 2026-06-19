import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/app_provider.dart';
import '../services/pdf_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/order_qr_codec.dart';
import '../widgets/custom_button.dart';
import '../widgets/order_details_card.dart';
import '../widgets/scanner_overlay.dart';

class CashierQrValidationScreen extends StatefulWidget {
  const CashierQrValidationScreen({super.key});

  @override
  State<CashierQrValidationScreen> createState() => _CashierQrValidationScreenState();
}

class _CashierQrValidationScreenState extends State<CashierQrValidationScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  Order? _scannedOrder;
  bool _isProcessing = false;
  bool _isValidating = false;
  bool _paymentValidated = false;
  String? _lastScannedRaw;
  String? _errorMessage;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleQrScan(String raw) async {
    if (_isProcessing || raw == _lastScannedRaw) return;

    setState(() {
      _isProcessing = true;
      _lastScannedRaw = raw;
      _errorMessage = null;
    });

    final orderId = OrderQrCodec.extractOrderId(raw);
    if (orderId == null) {
      setState(() {
        _errorMessage = 'QR code invalide. Impossible de lire la commande.';
        _isProcessing = false;
      });
      return;
    }

    final order = await context.read<AppProvider>().getOrderById(orderId);
    if (!mounted) return;

    if (order == null) {
      setState(() {
        _errorMessage = 'Commande introuvable (ID: ${orderId.substring(0, 8)}...).';
        _isProcessing = false;
      });
      return;
    }

    setState(() {
      _scannedOrder = order;
      _paymentValidated = order.isPaymentValidated;
      _isProcessing = false;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) _lastScannedRaw = null;
  }

  Future<void> _validatePayment() async {
    final order = _scannedOrder;
    if (order == null || order.isPaymentValidated) return;

    setState(() => _isValidating = true);

    final success = await context.read<AppProvider>().validateOrderPayment(order.id);
    if (!mounted) return;

    if (success) {
      final updated = order.copyWith(
        status: OrderStatus.delivered,
        isPaid: true,
        validatedAt: DateTime.now(),
        validatedBy: context.read<AppProvider>().currentUser?.id,
      );
      setState(() {
        _scannedOrder = updated;
        _paymentValidated = true;
        _isValidating = false;
      });
      _showSuccessDialog(updated);
    } else {
      setState(() => _isValidating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AppProvider>().errorMessage ?? 'Échec de la validation'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessDialog(Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 56),
              const SizedBox(height: 16),
              const Text('Paiement validé !', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                '${order.totalAmount.toStringAsFixed(2)} TND reçus',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continuer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _printInvoice() async {
    final order = _scannedOrder;
    if (order == null) return;
    final bytes = await PdfService.generateInvoicePdf(order);
    if (!mounted) return;
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }

  Future<void> _shareInvoice() async {
    final order = _scannedOrder;
    if (order == null) return;
    final bytes = await PdfService.generateInvoicePdf(order);
    if (!mounted) return;
    await Printing.sharePdf(bytes: bytes, filename: 'facture_${order.id}.pdf');
  }

  void _resetScan() {
    setState(() {
      _scannedOrder = null;
      _paymentValidated = false;
      _errorMessage = null;
      _lastScannedRaw = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Validation QR'),
        actions: [
          if (_scannedOrder != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Nouveau scan',
              onPressed: _resetScan,
            ),
        ],
      ),
      body: _scannedOrder == null ? _buildScanner() : _buildOrderView(),
    );
  }

  Widget _buildScanner() {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.42,
          child: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    _handleQrScan(barcodes.first.rawValue!);
                  }
                },
              ),
              const ScannerOverlay(frameSize: 240),
              if (_isProcessing)
                const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Scanner le QR code client',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Demandez au client de présenter le QR code généré après sa commande.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderView() {
    final order = _scannedOrder!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (order.isPaymentValidated || _paymentValidated)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(child: Text('Cette commande a déjà été payée et validée.', style: TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          OrderDetailsCard(order: order, showQrCode: false),
          const SizedBox(height: 24),
          if (!_paymentValidated && !order.isPaymentValidated)
            CustomButton(
              text: 'Valider le paiement',
              icon: Icons.payment_rounded,
              isLoading: _isValidating,
              onPressed: _validatePayment,
            ),
          if (_paymentValidated || order.isPaymentValidated) ...[
            CustomButton(
              text: 'Imprimer la facture (PDF)',
              icon: Icons.print_rounded,
              onPressed: _printInvoice,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Télécharger / Partager PDF',
              icon: Icons.download_rounded,
              outlined: true,
              onPressed: _shareInvoice,
            ),
          ],
        ],
      ),
    );
  }
}
