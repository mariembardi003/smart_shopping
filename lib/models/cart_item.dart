import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'quantity': quantity,
      'product': {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'barcode': product.barcode,
        'imageUrl': product.imageUrl,
        'category': product.category,
        'stock': product.stock,
        'createdAt': product.createdAt.toIso8601String(),
      },
    };
  }

  factory CartItem.fromFirestore(Map<String, dynamic> data) {
    final productData = data['product'] as Map<String, dynamic>?;
    return CartItem(
      id: data['id'] as String? ?? '',
      product: Product(
        id: productData?['id'] ?? '',
        name: productData?['name'] ?? '',
        description: productData?['description'] ?? '',
        price: (productData?['price'] ?? 0).toDouble(),
        barcode: productData?['barcode'] ?? '',
        imageUrl: productData?['imageUrl'] ?? '',
        category: productData?['category'] ?? '',
        stock: productData?['stock'] ?? 0,
        createdAt: productData?['createdAt'] != null
          ? DateTime.parse(productData!['createdAt'])
          : DateTime.now(),
      ),
      quantity: data['quantity'] as int? ?? 1,
    );
  }

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
