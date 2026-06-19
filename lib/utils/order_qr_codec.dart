import 'dart:convert';

import '../models/order.dart';

/// Encodes and decodes order QR payloads for cashier payment validation.
abstract final class OrderQrCodec {
  static String encode(Order order) {
    final payload = {
      'orderId': order.id,
      'date': order.createdAt.toIso8601String(),
      'totalAmount': order.totalAmount,
      'status': order.status.name,
      'items': order.items
          .map(
            (item) => {
              'product': item.product.name,
              'productId': item.product.id,
              'qty': item.quantity,
              'price': item.product.price,
            },
          )
          .toList(),
    };
    return jsonEncode(payload);
  }

  /// Extracts order ID from a scanned QR value (JSON or plain ID).
  static String? extractOrderId(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        final orderId = decoded['orderId'];
        if (orderId is String && orderId.isNotEmpty) return orderId;
      }
    } catch (_) {
      // Not JSON — try plain order id.
    }

    if (trimmed.length >= 8) return trimmed;
    return null;
  }
}
