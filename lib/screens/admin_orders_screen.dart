import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/firestore_service.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  Widget _statusChip(OrderStatus status) {
    final color = switch (status) {
      OrderStatus.pending => Colors.orange.shade200,
      OrderStatus.processing => Colors.blue.shade200,
      OrderStatus.shipped => Colors.purple.shade200,
      OrderStatus.delivered => Colors.green.shade200,
      OrderStatus.cancelled => Colors.red.shade200,
    };
    return Chip(
      label: Text(status.name.toUpperCase()),
      backgroundColor: color,
    );
  }

  Future<void> _updateOrderStatus(BuildContext context, Order order) async {
    final selectedStatus = await showDialog<OrderStatus>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Changer le statut'),
          children: OrderStatus.values.map((status) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, status),
              child: Text(status.name.toUpperCase()),
            );
          }).toList(),
        );
      },
    );

    if (selectedStatus != null) {
      await FirestoreService().updateOrderStatus(order.id, selectedStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les commandes'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Order>>(
        stream: FirestoreService().getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Aucune commande enregistrée'),
                ],
              ),
            );
          }

          final orders = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Commande ${order.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          _statusChip(order.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Client: ${order.userId}'),
                      const SizedBox(height: 8),
                      Text('Total: ${order.totalAmount.toStringAsFixed(2)} TND', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                      const SizedBox(height: 8),
                      Text('Articles: ${order.items.length}'),
                      const SizedBox(height: 8),
                      Text('Paiement: ${order.paymentMethod ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      Text('Livraison: ${order.shippingAddress ?? 'Non renseignée'}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _updateOrderStatus(context, order),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                        child: const Text('Changer statut'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
