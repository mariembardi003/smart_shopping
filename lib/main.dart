import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';
import 'providers/app_provider.dart';
import 'models/product.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/register_screen.dart';
import 'screens/product_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_products_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_orders_screen.dart';
import 'screens/admin_support_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/cashier_screen.dart';
import 'screens/support_screen.dart';
import 'models/app_user.dart';

/// Main entry point for the Smart Shopping application.
/// Initializes Firebase with secure configuration and runs the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with secure configuration from environment variables
  await Firebase.initializeApp(
    options: FirebaseConfig.options,
  );

  runApp(const SmartShoppingApp());
}

class SmartShoppingApp extends StatelessWidget {
  const SmartShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..initAuth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Shopping',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.green.shade700,
          scaffoldBackgroundColor: Colors.grey.shade50,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade700, width: 2),
            ),
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            primary: Colors.green.shade700,
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/scanner': (context) => const ScannerScreen(),
          '/register': (context) => const RegisterScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/orders': (context) => const OrderHistoryScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/admin': (context) => const AdminDashboardScreen(),
          '/admin/products': (context) => const AdminProductsScreen(),
          '/admin/orders': (context) => const AdminOrdersScreen(),
          '/admin/support': (context) => const AdminSupportScreen(),
          '/admin/users': (context) => const AdminUsersScreen(),
          '/cashier': (context) => const CashierScreen(),
          '/support': (context) => const SupportScreen(),
          '/dashboard': (context) => const AuthWrapper(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product' && settings.arguments is Product) {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (context) => ProductScreen(product: product),
            );
          }
          return null;
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.currentUser == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.isAuthenticated) {
          final userRole = provider.currentUser?.role;
          if (userRole == null || userRole == UserRole.client) {
            return const HomeScreen();
          }
          if (userRole == UserRole.admin) {
            return const AdminDashboardScreen();
          }
          if (userRole == UserRole.cashier) {
            return const CashierScreen();
          }
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
