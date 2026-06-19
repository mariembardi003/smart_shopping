import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../providers/app_provider.dart';
import '../services/firestore_service.dart';

class CashierCreateInvoiceScreen extends StatefulWidget {
  const CashierCreateInvoiceScreen({super.key});

  @override
  State<CashierCreateInvoiceScreen> createState() => _CashierCreateInvoiceScreenState();
}

class _CashierCreateInvoiceScreenState extends State<CashierCreateInvoiceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<CartItem> _invoiceItems = [];
  String _searchQuery = '';
  bool _isSaving = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filteredProducts(List<Product> products) {
    if (_searchQuery.isEmpty) return products;
    return products.where((product) {
      return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.barcode.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _addProduct(Product product) {
    final index = _invoiceItems.indexWhere((item) => item.product.id == product.id);
    setState(() {
      if (index != -1) {
        if (_invoiceItems[index].quantity < product.stock) {
          _invoiceItems[index].quantity++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Stock insuffisant pour ${product.name}.'),
              backgroundColor: Colors.orange.shade700,
            ),
          );
        }
      } else {
        if (product.stock > 0) {
          _invoiceItems.add(CartItem(id: DateTime.now().microsecondsSinceEpoch.toString(), product: product, quantity: 1));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ce produit est en rupture de stock.'),
              backgroundColor: Colors.orange.shade700,
            ),
          );
        }
      }
    });
  }

  void _removeInvoiceItem(String itemId) {
    setState(() {
      _invoiceItems.removeWhere((item) => item.id == itemId);
    });
  }

  void _updateQuantity(String itemId, int quantity) {
    setState(() {
      final index = _invoiceItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        if (quantity <= 0) {
          _invoiceItems.removeAt(index);
        } else {
          _invoiceItems[index].quantity = quantity;
        }
      }
    });
  }

  double get _invoiceTotal => _invoiceItems.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> _saveInvoice() async {
    if (_invoiceItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez des produits avant d’enregistrer la facture.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final currentUser = context.read<AppProvider>().currentUser;
    final order = Order(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: currentUser?.id ?? 'cashier-${DateTime.now().millisecondsSinceEpoch}',
      items: List.from(_invoiceItems),
      totalAmount: _invoiceTotal,
      status: OrderStatus.processing,
      createdAt: DateTime.now(),
      shippingAddress: 'Sur place',
      paymentMethod: 'Espèces',
    );

    try {
      await FirestoreService().createOrder(order);
      await FirestoreService().updateProductStock(_invoiceItems);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facture enregistrée avec succès.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’enregistrement: $error'), backgroundColor: Colors.red.shade700),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<AppProvider>().products;
    final filteredProducts = _filteredProducts(products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle facture'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                if (_invoiceItems.isNotEmpty) ...[
                  const Text('Articles de la facture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      itemCount: _invoiceItems.length,
                      separatorBuilder: (context, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = _invoiceItems[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text('${item.product.price.toStringAsFixed(2)} TND'),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () => _updateQuantity(item.id, item.quantity - 1),
                                    ),
                                    Text('${item.quantity}'),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () => _updateQuantity(item.id, item.quantity + 1),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _removeInvoiceItem(item.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text('Produits disponibles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Text(
                      'Aucun produit trouvé',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredProducts.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade50,
                            child: const Icon(Icons.shopping_bag_outlined, color: Colors.green),
                          ),
                          title: Text(product.name),
                          subtitle: Text('${product.price.toStringAsFixed(2)} TND • Stock: ${product.stock}'),
                          trailing: ElevatedButton(
                            onPressed: product.stock <= 0 ? null : () => _addProduct(product),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Ajouter'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${_invoiceTotal.toStringAsFixed(2)} TND', style: TextStyle(color: Colors.green.shade700, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveInvoice,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Enregistrer la facture'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
