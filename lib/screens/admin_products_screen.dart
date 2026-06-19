
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/product.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _searchController = TextEditingController();
  bool _isProcessing = false;
  String? _selectedProductId;
  String? _uploadedImageUrl;
  String _searchTerm = '';
  bool _isFeatured = false;
  bool _isPromotional = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(Product product) {
    final term = _searchTerm.toLowerCase();
    if (term.isEmpty) return true;
    return product.name.toLowerCase().contains(term) ||
        product.category.toLowerCase().contains(term) ||
        product.barcode.toLowerCase().contains(term);
  }

  Future<void> _openProductForm([Product? product]) async {
    _selectedProductId = product?.id;
    _nameController.text = product?.name ?? '';
    _descriptionController.text = product?.description ?? '';
    _priceController.text = product != null ? product.price.toStringAsFixed(2) : '';
    _barcodeController.text = product?.barcode ?? '';
    _categoryController.text = product?.category ?? '';
    _stockController.text = product != null ? product.stock.toString() : '10';
    _imageUrlController.text = product?.imageUrl ?? '';
    _uploadedImageUrl = product?.imageUrl;
    _isFeatured = product?.isFeatured ?? false;
    _isPromotional = product?.isPromotional ?? false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
          title: Text(product == null ? 'Ajouter un produit' : 'Modifier le produit'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nom du produit'),
                    validator: (value) => (value == null || value.isEmpty) ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (value) => (value == null || value.isEmpty) ? 'Description requise' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Prix (TND)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Prix requis';
                      if (double.tryParse(value.replaceAll(',', '.')) == null) {
                        return 'Prix invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _barcodeController,
                    decoration: const InputDecoration(labelText: 'Code-barres'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Catégorie'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Stock requis';
                      if (int.tryParse(value) == null) return 'Stock invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: 'URL de l’image'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _uploadImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Télécharger une image'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                  ),
                  if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 130,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _uploadedImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade100,
                              child: const Center(child: Icon(Icons.broken_image)),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Produit vedette'),
                    subtitle: const Text('Visible dans la section vedettes (client)'),
                    value: _isFeatured,
                    onChanged: (v) => setDialogState(() => _isFeatured = v),
                  ),
                  SwitchListTile(
                    title: const Text('Produit en promotion'),
                    subtitle: const Text('Visible dans la section promotions (client)'),
                    value: _isPromotional,
                    onChanged: (v) => setDialogState(() => _isPromotional = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: _isProcessing ? null : () async {
                if (!_formKey.currentState!.validate()) return;
                final navigator = Navigator.of(dialogContext);
                await _saveProduct();
                if (mounted) navigator.pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
              child: _isProcessing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Text('Enregistrer'),
            ),
          ],
            );
          },
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isProcessing = true;
    });

    final url = await StorageService().uploadProductImage();
    if (url != null) {
      _uploadedImageUrl = url;
      _imageUrlController.text = url;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image téléchargée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucune image sélectionnée'), backgroundColor: Colors.orange),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _saveProduct() async {
    final provider = context.read<AppProvider>();
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final price = double.parse(_priceController.text.replaceAll(',', '.'));
    final barcode = _barcodeController.text.trim();
    final category = _categoryController.text.trim();
    final stock = int.parse(_stockController.text.trim());
    final imageUrl = _imageUrlController.text.trim();

    final product = Product(
      id: _selectedProductId ?? const Uuid().v4(),
      name: name,
      description: description,
      price: price,
      barcode: barcode,
      imageUrl: imageUrl,
      category: category.isEmpty ? 'Autre' : category,
      stock: stock,
      createdAt: DateTime.now(),
      isFeatured: _isFeatured,
      isPromotional: _isPromotional,
    );

    setState(() {
      _isProcessing = true;
    });

    final success = _selectedProductId == null
        ? await provider.addProduct(product)
        : await provider.updateProduct(product);

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Produit enregistré' : 'Erreur lors de l’enregistrement'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete(Product product) async {
    final provider = context.read<AppProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le produit?'),
          content: Text('Voulez-vous vraiment supprimer ${product.name}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await provider.deleteProduct(product.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Produit supprimé' : 'Impossible de supprimer le produit'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration produits'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProductForm(),
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final products = provider.products.where(_matchesSearch).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchTerm = value),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Rechercher par nom, catégorie ou code-barres',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: _searchTerm.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchTerm = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 72, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(_searchTerm.isEmpty
                                ? 'Aucun produit disponible pour le moment.'
                                : 'Aucun produit ne correspond à votre recherche.'),
                            if (_searchTerm.isEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Ajoutez un produit pour commencer.'),
                            ],
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 3 : MediaQuery.of(context).size.width > 650 ? 2 : 1,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: product.imageUrl.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: Colors.grey.shade100,
                                            child: const Icon(Icons.broken_image, size: 42),
                                          ),
                                        )
                                      : Container(
                                          color: Colors.green.shade50,
                                          child: const Center(
                                            child: Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.green),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(product.category.isEmpty ? 'Sans catégorie' : product.category, style: TextStyle(color: Colors.grey.shade600)),
                              const SizedBox(height: 8),
                              Text('${product.price.toStringAsFixed(2)} TND', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                              const SizedBox(height: 8),
                              Text('Stock: ${product.stock}', style: const TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _openProductForm(product),
                                      child: const Text('Modifier'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _confirmDelete(product),
                                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text('Supprimer'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ),
            ],
          );
        },
      ),
    );
  }
}