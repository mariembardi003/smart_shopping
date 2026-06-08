/// Input validation utilities for the Smart Shopping application.
/// Provides comprehensive validation for user inputs including email, password,
/// phone numbers, addresses, and product information.
library;

/// Validates email format using RFC 5322 compliant regex.
/// Returns null if valid, error message if invalid.
String? validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return 'Email is required';
  }

  // RFC 5322 compliant email regex (simplified but robust)
  final emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
  );

  if (!emailRegex.hasMatch(email)) {
    return 'Please enter a valid email address';
  }

  return null; // Valid
}

/// Validates password strength requirements.
/// Requires minimum 8 characters with uppercase, lowercase, and number.
/// Returns null if valid, error message if invalid.
String? validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return 'Password is required';
  }

  if (password.length < 8) {
    return 'Password must be at least 8 characters long';
  }

  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return 'Password must contain at least one uppercase letter';
  }

  if (!RegExp(r'[a-z]').hasMatch(password)) {
    return 'Password must contain at least one lowercase letter';
  }

  if (!RegExp(r'[0-9]').hasMatch(password)) {
    return 'Password must contain at least one number';
  }

  return null; // Valid
}

/// Validates password confirmation matches the original password.
/// Returns null if valid, error message if invalid.
String? validatePasswordConfirmation(String? password, String? confirmPassword) {
  if (confirmPassword == null || confirmPassword.isEmpty) {
    return 'Please confirm your password';
  }

  if (password != confirmPassword) {
    return 'Passwords do not match';
  }

  return null; // Valid
}

/// Validates phone number format.
/// Supports international format (+216XXXXXXXX) and local format (0XXXXXXXX).
/// Returns null if valid, error message if invalid.
String? validatePhone(String? phone) {
  if (phone == null || phone.isEmpty) {
    return 'Phone number is required';
  }

  // Remove all spaces and hyphens for validation
  final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');

  // Support international format (+216XXXXXXXX) or local format (0XXXXXXXX)
  final phoneRegex = RegExp(r'^(\+216|0)[1-9]\d{7}$');

  if (!phoneRegex.hasMatch(cleanPhone)) {
    return 'Please enter a valid phone number (e.g., +216 12 345 678 or 012345678)';
  }

  return null; // Valid
}

/// Validates delivery address.
/// Requires minimum length and basic format validation.
/// Returns null if valid, error message if invalid.
String? validateAddress(String? address) {
  if (address == null || address.isEmpty) {
    return 'Delivery address is required';
  }

  if (address.length < 10) {
    return 'Please provide a complete delivery address';
  }

  // Check for potentially problematic characters
  if (RegExp(r'[<>]').hasMatch(address)) {
    return 'Address contains invalid characters';
  }

  return null; // Valid
}

/// Validates product name.
/// Allows alphanumeric characters, spaces, and basic punctuation.
/// Returns null if valid, error message if invalid.
String? validateProductName(String? name) {
  if (name == null || name.isEmpty) {
    return 'Product name is required';
  }

  if (name.length < 2) {
    return 'Product name must be at least 2 characters long';
  }

  if (name.length > 100) {
    return 'Product name must be less than 100 characters';
  }

  // Allow letters, numbers, spaces, and basic punctuation
  final nameRegex = RegExp(r'^[a-zA-Z0-9\s\-\.\,\(\)]+$');

  if (!nameRegex.hasMatch(name)) {
    return 'Product name contains invalid characters';
  }

  return null; // Valid
}

/// Validates quantity for cart items.
/// Must be positive integer between 1 and 99.
/// Returns null if valid, error message if invalid.
String? validateQuantity(String? quantity) {
  if (quantity == null || quantity.isEmpty) {
    return 'Quantity is required';
  }

  final quantityInt = int.tryParse(quantity);
  if (quantityInt == null) {
    return 'Please enter a valid number';
  }

  if (quantityInt < 1) {
    return 'Quantity must be at least 1';
  }

  if (quantityInt > 99) {
    return 'Quantity cannot exceed 99';
  }

  return null; // Valid
}

/// Validates price format.
/// Must be positive decimal number with up to 2 decimal places.
/// Returns null if valid, error message if invalid.
String? validatePrice(String? price) {
  if (price == null || price.isEmpty) {
    return 'Price is required';
  }

  final priceDouble = double.tryParse(price);
  if (priceDouble == null) {
    return 'Please enter a valid price';
  }

  if (priceDouble <= 0) {
    return 'Price must be greater than 0';
  }

  if (priceDouble > 99999.99) {
    return 'Price cannot exceed 99,999.99';
  }

  // Check decimal places (max 2)
  final decimalRegex = RegExp(r'^\d+(\.\d{1,2})?$');
  if (!decimalRegex.hasMatch(price)) {
    return 'Price can have at most 2 decimal places';
  }

  return null; // Valid
}

/// Validates barcode format.
/// Accepts various barcode formats (EAN-13, UPC-A, etc.).
/// Returns null if valid, error message if invalid.
String? validateBarcode(String? barcode) {
  if (barcode == null || barcode.isEmpty) {
    return 'Barcode is required';
  }

  // Remove spaces and hyphens
  final cleanBarcode = barcode.replaceAll(RegExp(r'[\s\-]'), '');

  // Basic validation: 8-18 digits (covers most barcode formats)
  final barcodeRegex = RegExp(r'^\d{8,18}$');

  if (!barcodeRegex.hasMatch(cleanBarcode)) {
    return 'Please enter a valid barcode (8-18 digits)';
  }

  return null; // Valid
}

/// Validates name field (first name, last name, etc.).
/// Allows letters, spaces, hyphens, and apostrophes.
/// Returns null if valid, error message if invalid.
String? validateName(String? name) {
  if (name == null || name.isEmpty) {
    return 'Name is required';
  }

  if (name.length < 2) {
    return 'Name must be at least 2 characters long';
  }

  if (name.length > 50) {
    return 'Name must be less than 50 characters';
  }

  // Allow letters, spaces, hyphens, and apostrophes
  final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");

  if (!nameRegex.hasMatch(name)) {
    return 'Name contains invalid characters';
  }

  return null; // Valid
}