import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/firestore_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late MobileScannerController _scannerController;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Création du contrôleur avec la caméra arrière par défaut
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    // Demander la permission
    final permission = await _scannerController.requestPermission();
    if (permission != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission caméra refusée')),
        );
      }
      return;
    }

    // Tenter de démarrer la caméra
    try {
      await _scannerController.start();
    } catch (e) {
      // Si la caméra arrière n'existe pas, tenter la caméra avant
      if (e.toString().contains('NotFoundError')) {
        try {
          await _scannerController.dispose();
          _scannerController = MobileScannerController(
            detectionSpeed: DetectionSpeed.normal,
            facing: CameraFacing.front,
            torchEnabled: false,
          );
          await _scannerController.start();
          if (mounted) setState(() {});
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Aucune caméra trouvée : $e')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur caméra : $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(String barcode) async {
    // Éviter les doubles traitements
    if (_isProcessing || barcode == _lastScannedCode) return;

    setState(() {
      _isProcessing = true;
      _lastScannedCode = barcode;
    });

    try {
      // Appel Firestore
      final product = await _firestoreService.getProductByBarcode(barcode);

      if (!mounted) return;

      if (product != null) {
        // Ajout au panier
        context.read<AppProvider>().addToCart(product);
        _showProductFoundDialog(product.name, product.price);
      } else {
        _showProductNotFoundDialog(barcode);
      }

      // Délai pour éviter les scans multiples trop rapides
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la recherche : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Réinitialiser l'état du scanner
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _lastScannedCode = null;
        });
      }
    }
  }

  void _showProductFoundDialog(String productName, double price) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Produit trouvé!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              productName,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${price.toStringAsFixed(2)} TND',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ajouté au panier',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/cart');
            },
            child: const Text('Voir le panier'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _showProductNotFoundDialog(String barcode) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Produit non trouvé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Code: $barcode',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ce produit n\'existe pas dans la base de données.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scanner produit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner ou message d'erreur
          ValueListenableBuilder(
            valueListenable: _scannerController,
            builder: (context, state, child) {
              // Si une erreur est détectée par le contrôleur
              if (state.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.no_photography, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Caméra indisponible',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.error!.errorMessage ?? 'Erreur inconnue',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeCamera,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                );
              }

              // Sinon afficher le scanner
              return MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    _handleBarcode(barcodes.first.rawValue!);
                  }
                },
              );
            },
          ),

          // Overlay (cadre vert)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade700, width: 3),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.transparent,
                ),
              ),
            ),
          ),

          // Instructions et indicateur de chargement
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Positionnez le code-barres dans le cadre',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (_isProcessing) ...[
                  const SizedBox(height: 16),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                  ),
                ],
              ],
            ),
          ),

          // Bouton retour
          Positioned(
            bottom: 32,
            left: 24,
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back, color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    );
  }
}