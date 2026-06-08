/// Custom exception classes for the Smart Shopping application.
/// Provides structured error handling for different types of failures.
library;

/// Base exception class for application-specific errors.
/// All custom exceptions should extend this class.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Exception thrown when authentication operations fail.
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);

  /// Creates an AuthException from Firebase Auth error codes.
  factory AuthException.fromFirebaseCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthException('No account found with this email address');
      case 'wrong-password':
        return const AuthException('Incorrect password');
      case 'email-already-in-use':
        return const AuthException('An account with this email already exists');
      case 'weak-password':
        return const AuthException('Password is too weak');
      case 'invalid-email':
        return const AuthException('Invalid email address');
      case 'user-disabled':
        return const AuthException('This account has been disabled');
      case 'too-many-requests':
        return const AuthException('Too many failed attempts. Please try again later');
      case 'operation-not-allowed':
        return const AuthException('This sign-in method is not enabled');
      case 'network-request-failed':
        return const AuthException('Network error. Please check your connection');
      default:
        return AuthException('Authentication error: $code');
    }
  }
}

/// Exception thrown when Firestore database operations fail.
class FirestoreException extends AppException {
  const FirestoreException(super.message, [super.code]);

  /// Creates a FirestoreException from Firebase error codes.
  factory FirestoreException.fromFirebaseCode(String code) {
    switch (code) {
      case 'permission-denied':
        return const FirestoreException('Access denied. Please check your permissions');
      case 'not-found':
        return const FirestoreException('The requested data was not found');
      case 'already-exists':
        return const FirestoreException('This data already exists');
      case 'resource-exhausted':
        return const FirestoreException('Too many requests. Please try again later');
      case 'failed-precondition':
        return const FirestoreException('Operation failed due to current state');
      case 'aborted':
        return const FirestoreException('Operation was aborted');
      case 'out-of-range':
        return const FirestoreException('Requested data is out of range');
      case 'unimplemented':
        return const FirestoreException('This operation is not implemented');
      case 'internal':
        return const FirestoreException('Internal server error. Please try again');
      case 'unavailable':
        return const FirestoreException('Service is currently unavailable');
      case 'data-loss':
        return const FirestoreException('Data loss occurred');
      case 'unauthenticated':
        return const FirestoreException('Authentication required');
      case 'deadline-exceeded':
        return const FirestoreException('Operation timed out');
      default:
        return FirestoreException('Database error: $code');
    }
  }
}

/// Exception thrown when input validation fails.
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// Exception thrown when network operations fail.
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);

  /// Creates a NetworkException for common network issues.
  factory NetworkException.connectionFailed() {
    return const NetworkException('Unable to connect. Please check your internet connection');
  }

  factory NetworkException.timeout() {
    return const NetworkException('Request timed out. Please try again');
  }

  factory NetworkException.noInternet() {
    return const NetworkException('No internet connection available');
  }
}

/// Exception thrown when barcode scanning operations fail.
class ScannerException extends AppException {
  const ScannerException(super.message, [super.code]);

  factory ScannerException.cameraNotAvailable() {
    return const ScannerException('Camera is not available on this device');
  }

  factory ScannerException.permissionDenied() {
    return const ScannerException('Camera permission is required to scan barcodes');
  }

  factory ScannerException.invalidBarcode() {
    return const ScannerException('Invalid barcode format detected');
  }
}

/// Exception thrown when cart operations fail.
class CartException extends AppException {
  const CartException(super.message, [super.code]);

  factory CartException.itemNotFound() {
    return const CartException('Item not found in cart');
  }

  factory CartException.insufficientStock() {
    return const CartException('Insufficient stock for this item');
  }

  factory CartException.invalidQuantity() {
    return const CartException('Invalid quantity specified');
  }
}

/// Exception thrown when order operations fail.
class OrderException extends AppException {
  const OrderException(super.message, [super.code]);

  factory OrderException.creationFailed() {
    return const OrderException('Failed to create order. Please try again');
  }

  factory OrderException.paymentFailed() {
    return const OrderException('Payment processing failed');
  }

  factory OrderException.invalidStatus() {
    return const OrderException('Invalid order status');
  }
}