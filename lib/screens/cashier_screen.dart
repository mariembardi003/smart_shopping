import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../providers/app_provider.dart';
import '../services/firestore_service.dart';

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key});

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  final List<CartItem> _saleItems = [];
  bool _isProcessing = false;
  String? _lastScannedCode;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _addScannedProduct(String barcode) async {
    if (_isProcessing || barcode == _lastScannedCode) return;
    setState(() {
      _isProcessing = true;
      _lastScannedCode = barcode;
    });

    final product = await context.read<AppProvider>().getProductByBarcode(barcode);
    if (!mounted) return;

    if (product != null) {
      final index = _saleItems.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        _saleItems[index].quantity++;
      } else {
        _saleItems.add(CartItem(id: DateTime.now().microsecondsSinceEpoch.toString(), product: product, quantity: 1));
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} ajouté à la vente'), backgroundColor: Colors.green.shade700),
      );
    } else {
      _showQrDialog(barcode);
    }

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _lastScannedCode = null;
      });
    }
  }

  double get _saleTotal => _saleItems.fold(0, (sum, item) => sum + item.totalPrice);

  void _removeSaleItem(String id) {
    setState(() {
      _saleItems.removeWhere((item) => item.id == id);
    });
  }

  Future<void> _confirmPayment() async {
    if (_saleItems.isEmpty) return;
    final order = Order(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: 'cashier-${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(_saleItems),
      totalAmount: _saleTotal,
      status: OrderStatus.processing,
      createdAt: DateTime.now(),
      shippingAddress: 'A emporter',
      paymentMethod: 'Espèces',
    );
    await FirestoreService().createOrder(order);
    await FirestoreService().updateProductStock(_saleItems);
    setState(() {
      _saleItems.clear();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paiement validé, vente enregistrée'), backgroundColor: Colors.green),
    );
  }

  void _showQrDialog(String data) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code détecté'),
        content: Text('Contenu : $data'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Caissier'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    final barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                      _addScannedProduct(barcodes.first.rawValue!);
                    }
                  },
                ),
                Container(
                  decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.35)),
                  child: Center(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green.shade700, width: 3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                if (_isProcessing)
                  const Positioned(
                    right: 16,
                    top: 16,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Vente en cours', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _saleItems.isEmpty
                        ? Center(
                            child: Text('Scannez des produits pour commencer', style: TextStyle(color: Colors.grey.shade600)),
                          )
                        : ListView.separated(
                            itemCount: _saleItems.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = _saleItems[index];
                              return ListTile(
                                tileColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                title: Text(item.product.name),
                                subtitle: Text('${item.quantity} x ${item.product.price.toStringAsFixed(2)} TND'),
                                trailing: Text('${item.totalPrice.toStringAsFixed(2)} TND'),
                                leading: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _removeSaleItem(item.id),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text('Total: ${_saleTotal.toStringAsFixed(2)} TND', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saleItems.isEmpty ? null : _confirmPayment,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                      child: const Text('Valider le paiement'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
