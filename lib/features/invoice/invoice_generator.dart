// lib/features/invoice/invoice_generator.dart
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/utils/formatters.dart';
import '../../database/app_database.dart';

class InvoiceGenerator {
  static Future<void> generate({
    required BuildContext context,
    required Booking booking,
    required Customer customer,
    required List<BookingService> services,
    required List<Payment> payments,
  }) async {
    final pdf = pw.Document();

    // Build the PDF page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) => _buildInvoicePage(
          context,
          booking: booking,
          customer: customer,
          services: services,
          payments: payments,
        ),
      ),
    );

    // Show print preview / save dialog
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'فاتورة_${booking.bookingNumber}',
    );
  }

  static pw.Widget _buildInvoicePage(
    pw.Context context, {
    required Booking booking,
    required Customer customer,
    required List<BookingService> services,
    required List<Payment> payments,
  }) {
    const primaryColor = PdfColor.fromInt(0xFF1B4B6B);
    const lightBg = PdfColor.fromInt(0xFFF8FAFC);
    const borderColor = PdfColor.fromInt(0xFFE2E8F0);
    const successColor = PdfColor.fromInt(0xFF22C55E);
    const dangerColor = PdfColor.fromInt(0xFFEF4444);
    const white70 = PdfColor.fromInt(0xB0FFFFFF);

    final serviceNames = services
        .map((s) => AppConstants.getServiceLabel(s.serviceName))
        .join(' • ');

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Container(
          padding: const pw.EdgeInsets.all(24),
          decoration: const pw.BoxDecoration(
            color: primaryColor,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'فاتورة حجز',
                    style: const pw.TextStyle(
                      color: white70,
                      fontSize: 14,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    booking.bookingNumber,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'تاريخ الفاتورة: ${AppFormatters.formatDateShort(DateTime.now())}',
                    style: const pw.TextStyle(
                      color: white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'ستوديو التصوير',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'مدير النظام',
                    style: const pw.TextStyle(
                      color: white70,
                      fontSize: 12,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'ahmed.k@studio.com',
                    style: const pw.TextStyle(
                      color: white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 24),

        // Customer + Booking info row
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Customer
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('بيانات العميل',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 13)),
                    pw.SizedBox(height: 8),
                    _infoRow('الاسم', customer.name),
                    pw.SizedBox(height: 4),
                    _infoRow('الهاتف', customer.phone),
                    if (customer.social != null) ...[
                      pw.SizedBox(height: 4),
                      _infoRow('التواصل', customer.social!),
                    ],
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 12),
            // Booking info
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('تفاصيل الحجز',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 13)),
                    pw.SizedBox(height: 8),
                    _infoRow('تاريخ المناسبة',
                        AppFormatters.formatDate(booking.bookingDate)),
                    pw.SizedBox(height: 4),
                    _infoRow('نوع المناسبة',
                        AppConstants.getEventLabel(booking.eventType)),
                    if (booking.venue != null) ...[
                      pw.SizedBox(height: 4),
                      _infoRow('الموقع', booking.venue!),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        // Services
        if (serviceNames.isNotEmpty) ...[
          pw.Text('الخدمات المختارة',
              style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, fontSize: 13)),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: lightBg,
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: borderColor),
            ),
            child: pw.Text(serviceNames, style: const pw.TextStyle(fontSize: 12)),
          ),
          pw.SizedBox(height: 20),
        ],

        // Payments table
        pw.Text('سجل الدفعات',
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 13)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: borderColor, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(3),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: primaryColor),
              children: [
                _tableCell('المبلغ', isHeader: true),
                _tableCell('طريقة الدفع', isHeader: true),
                _tableCell('التاريخ', isHeader: true),
              ],
            ),
            // Rows
            ...payments.map(
              (p) => pw.TableRow(
                decoration: const pw.BoxDecoration(color: lightBg),
                children: [
                  _tableCell(
                      '${p.amount.toStringAsFixed(0)} ج.م'),
                  _tableCell(AppConstants.getPaymentMethodLabel(
                      p.paymentMethod)),
                  _tableCell(AppFormatters.formatDateShort(
                      p.paymentDate)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        // Financial summary
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Container(
              width: 260,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: borderColor),
              ),
              child: pw.Column(
                children: [
                  _summaryRow('الإجمالي',
                      '${booking.totalAmount.toStringAsFixed(0)} ج.م'),
                  pw.Divider(color: borderColor),
                  _summaryRow('المدفوع',
                      '${booking.paidAmount.toStringAsFixed(0)} ج.م',
                      valueColor: successColor),
                  pw.Divider(color: borderColor),
                  _summaryRow('المتبقي',
                      '${booking.remainingAmount.toStringAsFixed(0)} ج.م',
                      valueColor: dangerColor,
                      isBold: true),
                ],
              ),
            ),
          ],
        ),
        pw.Spacer(),

        // Footer
        pw.Divider(color: borderColor),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text(
            'شكراً لاختياركم ستوديو التصوير • هذه الفاتورة صادرة إلكترونياً',
            style: const pw.TextStyle(
                color: PdfColors.grey600, fontSize: 10),
          ),
        ),
      ],
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text('$label: ',
            style: const pw.TextStyle(
                color: PdfColors.grey700, fontSize: 11)),
        pw.Text(value,
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 11)),
      ],
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: isHeader ? PdfColors.white : PdfColors.black,
          fontSize: 11,
          fontWeight:
              isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _summaryRow(
    String label,
    String value, {
    PdfColor? valueColor,
    bool isBold = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: const pw.TextStyle(
                color: PdfColors.grey700, fontSize: 12)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight:
                isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: valueColor ?? PdfColors.black,
          ),
        ),
      ],
    );
  }
}
