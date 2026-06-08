import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  final List<CartItem> _cartItems = [];
  final List<Order> _orders = [];
  bool _demoProductsCreated = false;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Product>>? _productsSubscription;
  StreamSubscription<List<Order>>? _ordersSubscription;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  List<Product> get products => _searchQuery.isEmpty ? _products : _filteredProducts;
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  List<Order> get orders => List.unmodifiable(_orders);
  double get cartTotal => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void initAuth() {
    _setLoading(true);
    _authSubscription = _authService.authStateChanges.listen(
      (User? user) async {
        if (user != null) {
          _currentUser = await _authService.getUserData(user.uid);
          await _loadCartForCurrentUser();
          _subscribeToOrders();
        } else {
          _currentUser = null;
          _cartItems.clear();
          _orders.clear();
          _ordersSubscription?.cancel();
        }
        _setLoading(false);
      },
      onError: (error) {
        _setError(error.toString());
        _setLoading(false);
      },
    );
    _subscribeToProducts();
  }

  void _subscribeToProducts() {
    _productsSubscription?.cancel();
    _productsSubscription = _firestoreService.getProducts().listen(
      (products) async {
        _products = products;
        if (!_demoProductsCreated && products.isEmpty) {
          _demoProductsCreated = true;
          try {
            await _firestoreService.initializeDemoProducts();
          } catch (e) {
            _setError(e.toString());
          }
        }
        _filterProducts();
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  Future<void> _loadCartForCurrentUser() async {
    if (_currentUser == null) return;
    try {
      final savedCart = await _firestoreService.getCart(_currentUser!.id);
      _cartItems
        ..clear()
        ..addAll(savedCart);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _subscribeToOrders() {
    _ordersSubscription?.cancel();
    if (_currentUser == null) return;

    _ordersSubscription = _firestoreService.getUserOrders(_currentUser!.id).listen(
      (orders) {
        _orders
          ..clear()
          ..addAll(orders);
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
      },
    );
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.signIn(email, password);
      if (_currentUser == null) {
        throw 'Impossible de récupérer les données utilisateur.';
      }
      await _loadCartForCurrentUser();
      _subscribeToOrders();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authService.signUp(email, password, name);
      if (_currentUser == null) {
        throw 'Impossible de créer l\'utilisateur.';
      }
      await _loadCartForCurrentUser();
      _subscribeToOrders();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _currentUser = null;
    _cartItems.clear();
    _orders.clear();
    _ordersSubscription?.cancel();
    _setLoading(false);
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _authService.updateUserProfile(
        uid: _currentUser!.id,
        name: name,
        phone: phone,
        address: address,
      );
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Products methods
  void loadProducts(List<Product> products) {
    _products = products;
    _filterProducts();
    notifyListeners();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _filterProducts();
    notifyListeners();
  }

  void _filterProducts() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = _products;
    } else {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    return await _firestoreService.getProductByBarcode(barcode);
  }

  // Cart methods
  void addToCart(Product product) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItem(
        id: _uuid.v4(),
        product: product,
        quantity: 1,
      ));
    }

    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String cartItemId) {
    _cartItems.removeWhere((item) => item.id == cartItemId);
    _saveCart();
    notifyListeners();
  }

  void updateCartItemQuantity(String cartItemId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
      _saveCart();
      notifyListeners();
    }
  }

  void incrementQuantity(String cartItemId) {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      _cartItems[index].quantity++;
      _saveCart();
      notifyListeners();
    }
  }

  void decrementQuantity(String cartItemId) {
    final index = _cartItems.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
      _saveCart();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    if (_currentUser != null) {
      await _firestoreService.clearCart(_currentUser!.id);
    }
    notifyListeners();
  }

  Future<bool> addProduct(Product product) async {
    try {
      await _firestoreService.addProduct(product);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      await _firestoreService.updateProduct(product);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await _firestoreService.deleteProduct(id);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> _saveCart() async {
    if (_currentUser == null) return;
    try {
      await _firestoreService.saveCart(_currentUser!.id, _cartItems);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Order methods
  Future<bool> createOrder({
    required String shippingAddress,
    required String phone,
    required String paymentMethod,
  }) async {
    if (_currentUser == null || _cartItems.isEmpty) return false;
    if (shippingAddress.isEmpty || phone.isEmpty || paymentMethod.isEmpty) return false;

    _setLoading(true);
    _clearError();

    try {
      final order = Order(
        id: _uuid.v4(),
        userId: _currentUser!.id,
        items: List.from(_cartItems),
        totalAmount: cartTotal,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
      );

      await _firestoreService.createOrder(order);
      await _firestoreService.updateProductStock(_cartItems);
      await _firestoreService.clearCart(_currentUser!.id);
      _cartItems.clear();
      notifyListeners();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _productsSubscription?.cancel();
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
