import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/order.dart';

class PdfService {
  static Future<Uint8List> generateInvoicePdf(
    Order order, {
    String? customerName,
  }) async {
    final pdf = pw.Document();
    final paymentStatus = order.isPaymentValidated ? 'Payée / Validée' : 'En attente';
    final validatedDate = order.validatedAt?.toLocal().toString().split('.').first ?? '—';

    pdf.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(pageFormat: PdfPageFormat.a4),
        build: (context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Smart Shopping', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text('Facture', style: const pw.TextStyle(fontSize: 18)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('N° ${order.id.substring(0, 12)}', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('Date : ${order.createdAt.toLocal().toString().split('.').first}', style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (customerName != null && customerName.isNotEmpty)
                    pw.Text('Client : $customerName', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text('Statut paiement : $paymentStatus', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  if (order.isPaymentValidated)
                    pw.Text('Validée le : $validatedDate', style: const pw.TextStyle(fontSize: 11)),
                  pw.Text('Mode de paiement : ${order.paymentMethod ?? 'Espèces'}', style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Détails des produits', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: ['Produit', 'Qté', 'Prix unit.', 'Total'],
              data: order.items.map((item) {
                return [
                  item.product.name,
                  item.quantity.toString(),
                  '${item.product.price.toStringAsFixed(2)} TND',
                  '${item.totalPrice.toStringAsFixed(2)} TND',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
              cellStyle: const pw.TextStyle(fontSize: 10),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 26,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
              },
            ),
            pw.Divider(height: 28),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  '${order.totalAmount.toStringAsFixed(2)} TND',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.SizedBox(height: 32),
            pw.Text('Merci pour votre achat !', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          ];
        },
      ),
    );

    return pdf.save();
  }
}
