import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';
import 'providers/app_provider.dart';
import 'models/product.dart';
import 'models/order.dart';
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
import 'screens/admin_add_cashier_screen.dart';
import 'screens/admin_cashier_management_screen.dart';
import 'screens/admin_complaints_management_screen.dart';
import 'screens/cashier_screen.dart';
import 'screens/cashier_invoices_screen.dart';
import 'screens/cashier_create_invoice_screen.dart';
import 'screens/cashier_qr_validation_screen.dart';
import 'screens/order_confirmation_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/support_screen.dart';
import 'models/app_user.dart';
import 'theme/app_theme.dart';
import 'widgets/client_shell.dart';

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
        theme: AppTheme.light,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const ClientShell(),
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
          '/admin/users/add': (context) => const AdminAddCashierScreen(),
          '/admin/cashiers': (context) => const AdminCashierManagementScreen(),
          '/admin/complaints': (context) => const AdminComplaintsManagementScreen(),
          '/cashier': (context) => const CashierScreen(),
          '/cashier/invoices': (context) => const CashierInvoicesScreen(),
          '/cashier/create-invoice': (context) => const CashierCreateInvoiceScreen(),
          '/cashier/validate-qr': (context) => const CashierQrValidationScreen(),
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
          if (settings.name == '/order-confirmation' && settings.arguments is Order) {
            final order = settings.arguments as Order;
            return MaterialPageRoute(
              builder: (context) => OrderConfirmationScreen(order: order),
            );
          }
          if (settings.name == '/order-detail' && settings.arguments is Order) {
            final order = settings.arguments as Order;
            return MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
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
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.isAuthenticated) {
          final userRole = provider.currentUser?.role;
          if (userRole == null || userRole == UserRole.client) {
            return const ClientShell();
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
