import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/order.dart' as models;
import '../models/cart_item.dart';
import '../models/app_user.dart';
import '../models/complaint.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Products
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Product.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toFirestore());
  }

  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toFirestore());
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  Future<void> updateProductStock(List<CartItem> items) async {
    if (items.isEmpty) return;

    final batch = _firestore.batch();

    for (final item in items) {
      final productRef = _firestore.collection('products').doc(item.product.id);
      batch.update(productRef, {'stock': FieldValue.increment(-item.quantity)});
    }

    await batch.commit();
  }

  // Cart
  Future<List<CartItem>> getCart(String userId) async {
    final doc = await _firestore.collection('cart').doc(userId).get();
    if (!doc.exists || doc.data() == null) {
      return [];
    }

    final data = doc.data() as Map<String, dynamic>;
    final itemsData = data['items'] as List<dynamic>? ?? [];
    return itemsData
        .map((item) => CartItem.fromFirestore(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCart(String userId, List<CartItem> items) async {
    await _firestore.collection('cart').doc(userId).set({
      'userId': userId,
      'updatedAt': DateTime.now().toIso8601String(),
      'items': items.map((item) => item.toFirestore()).toList(),
    });
  }

  Future<void> clearCart(String userId) async {
    await _firestore.collection('cart').doc(userId).delete();
  }

  // Orders
  Stream<List<models.Order>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return models.Order.fromFirestore(doc.id, data);
          }).toList();
        });
  }

  Future<void> createOrder(models.Order order) async {
    await _firestore
        .collection('orders')
        .doc(order.id)
        .set(order.toFirestore());
  }

  Future<void> updateOrderStatus(
    String orderId,
    models.OrderStatus status,
  ) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.name,
    });
  }

  Future<models.Order?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists || doc.data() == null) return null;
    return models.Order.fromFirestore(doc.id, doc.data()!);
  }

  Future<void> validateOrderPayment({
    required String orderId,
    required String cashierId,
  }) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': models.OrderStatus.delivered.name,
      'isPaid': true,
      'validatedAt': DateTime.now().toIso8601String(),
      'validatedBy': cashierId,
    });
  }

  Future<void> updateUserData(
    String uid,
    Map<String, dynamic> updateData,
  ) async {
    await _firestore.collection('users').doc(uid).update(updateData);
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({'role': role});
  }

  Stream<List<models.Order>> getOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return models.Order.fromFirestore(doc.id, data);
          }).toList();
        });
  }

  Stream<List<AppUser>> getUsers({String? role, List<String>? roles}) {
    Query<Map<String, dynamic>> query = _firestore.collection('users');
    if (roles != null && roles.isNotEmpty) {
      query = query.where('role', whereIn: roles);
    } else if (role != null) {
      query = query.where('role', isEqualTo: role);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  Stream<List<AppUser>> getCashiers() {
    return getUsers(role: 'cashier');
  }

  Future<void> deleteUserProfile(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  Future<int> getProductCount() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.size;
  }

  Future<int> getUsersCountByRole(String role) async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .get();
    return snapshot.size;
  }

  Future<Map<String, dynamic>> getOrderSummary() async {
    final querySnapshot = await _firestore.collection('orders').get();
    final orders = querySnapshot.docs.map((doc) {
      return models.Order.fromFirestore(doc.id, doc.data());
    }).toList();
    final totalSales = orders.fold(
      0.0,
      (total, order) => total + order.totalAmount,
    );
    return {'orders': orders.length, 'sales': totalSales};
  }

  Future<void> createComplaint(Complaint complaint) async {
    await _firestore
        .collection('complaints')
        .doc(complaint.id)
        .set(complaint.toFirestore());
  }

  Stream<List<Complaint>> getComplaints() {
    return _firestore
        .collection('complaints')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Complaint.fromFirestore(doc.id, doc.data()))
              .toList();
        });
  }

  Future<void> respondToComplaint(
    String complaintId,
    String response,
    ComplaintStatus status,
  ) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      'response': response,
      'status': status.name,
    });
  }

  // Initialize demo products
  Future<void> initializeDemoProducts() async {
    final products = [
      {
        'name': 'Lait',
        'description': 'Lait frais 1L',
        'price': 2.5,
        'barcode': '5000159407236',
        'imageUrl': '',
        'category': 'Produits laitiers',
        'stock': 100,
        'isFeatured': true,
        'isPromotional': false,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Pain',
        'description': 'Pain frais 500g',
        'price': 1.2,
        'barcode': '5000159407237',
        'imageUrl': '',
        'category': 'Boulangerie',
        'stock': 50,
        'isFeatured': true,
        'isPromotional': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Jus d\'orange',
        'description': 'Jus naturel 1L',
        'price': 3.0,
        'barcode': '5000159407238',
        'imageUrl': '',
        'category': 'Boissons',
        'stock': 30,
        'isFeatured': true,
        'isPromotional': false,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Chocolat',
        'description': 'Tablette de chocolat 100g',
        'price': 4.5,
        'barcode': '5000159407239',
        'imageUrl': '',
        'category': 'Confiseries',
        'stock': 25,
        'isFeatured': true,
        'isPromotional': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Eau minérale',
        'description': 'Eau 1.5L',
        'price': 0.8,
        'barcode': '5000159407240',
        'imageUrl': '',
        'category': 'Boissons',
        'stock': 200,
        'isFeatured': false,
        'isPromotional': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Pâtes',
        'description': 'Pâtes italiennes 500g',
        'price': 2.0,
        'barcode': '5000159407241',
        'imageUrl': '',
        'category': 'Épicerie',
        'stock': 80,
        'isFeatured': false,
        'isPromotional': true,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Riz',
        'description': 'Riz basmati 1kg',
        'price': 3.5,
        'barcode': '5000159407242',
        'imageUrl': '',
        'category': 'Épicerie',
        'stock': 60,
        'isFeatured': false,
        'isPromotional': false,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Huiles d\'olive',
        'description': 'Huile d\'olive extra vierge 500ml',
        'price': 8.0,
        'barcode': '5000159407243',
        'imageUrl': '',
        'category': 'Huiles',
        'stock': 20,
        'isFeatured': false,
        'isPromotional': false,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    for (final product in products) {
      await _firestore.collection('products').add(product);
    }
  }
}
