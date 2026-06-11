// lib/features/bookings/presentation/booking_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../database/app_database.dart';
import '../../invoice/invoice_generator.dart';

// ── Providers ─────────────────────────────────────────────────────────────────
final bookingDetailProvider =
    FutureProvider.family<Booking?, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  return db.getBookingById(id);
});

final bookingCustomerProvider =
    FutureProvider.family<Customer?, int>((ref, customerId) async {
  final db = ref.watch(databaseProvider);
  return db.getCustomerById(customerId);
});

final bookingServicesProvider =
    FutureProvider.family<List<BookingService>, int>((ref, bookingId) async {
  final db = ref.watch(databaseProvider);
  return db.getServicesForBooking(bookingId);
});

final bookingPaymentsProvider =
    StreamProvider.family<List<Payment>, int>((ref, bookingId) {
  final db = ref.watch(databaseProvider);
  return db.watchPaymentsForBooking(bookingId);
});

// ── Screen ─────────────────────────────────────────────────────────────────────
class BookingDetailScreen extends ConsumerStatefulWidget {
  final int bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState
    extends ConsumerState<BookingDetailScreen> {
  bool _showAddPayment = false;
  final _paymentAmountCtrl = TextEditingController();
  String _paymentMethod = 'cash';
  final _paymentNotesCtrl = TextEditingController();

  @override
  void dispose() {
    _paymentAmountCtrl.dispose();
    _paymentNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _addPayment(Booking booking) async {
    final amount = double.tryParse(_paymentAmountCtrl.text);
    if (amount == null || amount <= 0) return;
    if (amount > booking.remainingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('المبلغ أكبر من المتبقي',
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    await db.addPayment(
      PaymentsTableCompanion.insert(
        bookingId: booking.id,
        amount: amount,
        paymentMethod: Value(_paymentMethod),
        notes: Value(_paymentNotesCtrl.text.isEmpty
            ? null
            : _paymentNotesCtrl.text),
      ),
    );

    final newPaid = booking.paidAmount + amount;
    final newRemaining = booking.remainingAmount - amount;

    await db.updateBooking(
      BookingsTableCompanion(
        id: Value(booking.id),
        paidAmount: Value(newPaid),
        remainingAmount: Value(newRemaining),
        status: Value(newRemaining <= 0 ? 'confirmed' : booking.status),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Refresh
    ref.invalidate(bookingDetailProvider(widget.bookingId));
    ref.invalidate(bookingPaymentsProvider(widget.bookingId));

    setState(() {
      _showAddPayment = false;
      _paymentAmountCtrl.clear();
      _paymentNotesCtrl.clear();
    });
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء الحجز',
            style: TextStyle(fontFamily: 'Cairo')),
        content: const Text(
            'هل أنت متأكد من إلغاء هذا الحجز؟ لا يمكن التراجع عن هذا الإجراء.',
            style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('تراجع', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger),
            child: const Text('إلغاء الحجز',
                style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final db = ref.read(databaseProvider);
      await db.softDeleteBooking(booking.id);
      if (mounted) context.go('/bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync =
        ref.watch(bookingDetailProvider(widget.bookingId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: bookingAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (booking) {
          if (booking == null) {
            return const Center(child: Text('الحجز غير موجود'));
          }
          return _buildContent(booking);
        },
      ),
    );
  }

  Widget _buildContent(Booking booking) {
    final customerAsync =
        ref.watch(bookingCustomerProvider(booking.customerId));
    final servicesAsync =
        ref.watch(bookingServicesProvider(widget.bookingId));
    final paymentsAsync =
        ref.watch(bookingPaymentsProvider(widget.bookingId));

    return Column(
      children: [
        _buildTopBar(booking),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Financial summary
              _buildFinancialPanel(booking, paymentsAsync),
              // Center: Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Customer + booking number
                      _buildBookingHeader(booking, customerAsync),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer data
                          Expanded(
                            child: _buildCustomerCard(customerAsync),
                          ),
                          const SizedBox(width: 16),
                          // Event + services
                          Expanded(
                            child: _buildEventCard(booking, servicesAsync),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action buttons
                      _buildActionButtons(booking),
                      const SizedBox(height: 16),
                      // Add payment panel
                      if (_showAddPayment)
                        _buildAddPaymentPanel(booking),
                      const SizedBox(height: 16),
                      // Info row at bottom
                      _buildInfoRow(booking),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(Booking booking) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/bookings'),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios_rounded,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'العودة إلى قائمة الحجوزات',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Text(
            'تفاصيل الحجز',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          // PDF button
          ElevatedButton.icon(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              final customer = await db.getCustomerById(booking.customerId);
              final services = await db.getServicesForBooking(booking.id);
              final payments = await db.getPaymentsForBooking(booking.id);
              if (customer != null && mounted) {
                await InvoiceGenerator.generate(
                  context: context,
                  booking: booking,
                  customer: customer,
                  services: services,
                  payments: payments,
                );
              }
            },
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
            label: const Text('إصدار فاتورة PDF'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHeader(
      Booking booking, AsyncValue<Customer?> customerAsync) {
    final name = customerAsync.valueOrNull?.name ?? '...';
    final statusColor = _statusColor(booking.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '#${booking.bookingNumber}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'تم الحجز في ${AppFormatters.formatDate(booking.createdAt)}',
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  AppConstants.getStatusLabel(booking.status),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(AsyncValue<Customer?> customerAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text('بيانات العميل',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          customerAsync.when(
            loading: () =>
                const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (customer) {
              if (customer == null) {
                return const Text('لا توجد بيانات',
                    style: TextStyle(fontFamily: 'Cairo'));
              }
              return Column(
                children: [
                  _InfoRow(
                    icon: Icons.phone_rounded,
                    label: 'رقم الهاتف',
                    value: customer.phone,
                  ),
                  const SizedBox(height: 12),
                  if (customer.social != null)
                    _InfoRow(
                      icon: Icons.alternate_email_rounded,
                      label: 'التواصل الاجتماعي',
                      value: customer.social!,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
      Booking booking, AsyncValue<List<BookingService>> servicesAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.celebration_rounded,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text('نوع المناسبة والخدمات',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Text(
            'المناسبة',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.getEventLabel(booking.eventType),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          servicesAsync.when(
            loading: () =>
                const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (services) {
              if (services.isEmpty) {
                return const Text('لا خدمات',
                    style: TextStyle(
                        fontFamily: 'Cairo', color: AppColors.textSecondary));
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: services.map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppConstants.getServiceLabel(s.serviceName),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialPanel(
      Booking booking, AsyncValue<List<Payment>> paymentsAsync) {
    final paidPercent = booking.totalAmount > 0
        ? (booking.paidAmount / booking.totalAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('الملخص المالي',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Total
            Text('المبلغ الإجمالي',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              booking.totalAmount.toStringAsFixed(0),
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text('ر.س',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            // Payment status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: booking.remainingAmount > 0
                    ? AppColors.warningLight
                    : AppColors.successLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                booking.remainingAmount > 0
                    ? 'مدفوع جزئياً (${(paidPercent * 100).toStringAsFixed(0)}%)'
                    : 'مدفوع بالكامل ✓',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: booking.remainingAmount > 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: paidPercent,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  booking.remainingAmount > 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Paid / Remaining
            Row(
              children: [
                Expanded(
                  child: _AmountBox(
                    label: 'المدفوع',
                    amount: booking.paidAmount,
                    color: AppColors.success,
                    bgColor: AppColors.successLight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AmountBox(
                    label: 'المتبقي',
                    amount: booking.remainingAmount,
                    color: AppColors.danger,
                    bgColor: AppColors.dangerLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text('آخر الدفعات',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            paymentsAsync.when(
              loading: () =>
                  const CircularProgressIndicator(),
              error: (e, _) => Text('$e'),
              data: (payments) {
                if (payments.isEmpty) {
                  return const Text('لا توجد دفعات',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.textSecondary,
                          fontSize: 13));
                }
                return Column(
                  children: payments
                      .take(5)
                      .map((p) => _PaymentItem(payment: p))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            // Camera promo
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2942), Color(0xFF1B4B6B)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.camera_alt_rounded,
                        size: 60, color: Colors.white.withOpacity(0.3)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تجهيز المعدات',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'تم فحص الكاميرات والعدسات المطلوبة لهذا الموعد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Booking booking) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _showAddPayment = !_showAddPayment),
            icon: const Icon(Icons.add_card_rounded, size: 18),
            label: const Text('إضافة دفعة'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('تعديل'),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () => _cancelBooking(booking),
          icon: const Icon(Icons.cancel_outlined, size: 18),
          label: const Text('إلغاء الحجز'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.dangerLight),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPaymentPanel(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLighter),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('إضافة دفعة جديدة',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                onPressed: () =>
                    setState(() => _showAddPayment = false),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('المبلغ (ر.س)',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _paymentAmountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText:
                            'أقصى: ${booking.remainingAmount.toStringAsFixed(0)}',
                        hintStyle: const TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textTertiary),
                        suffixText: 'ر.س',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('طريقة الدفع',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                      ),
                      items: AppConstants.paymentMethods
                          .map((m) => DropdownMenuItem(
                                value: m['key'],
                                child: Text(m['label']!,
                                    style: const TextStyle(
                                        fontFamily: 'Cairo')),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _paymentMethod = v ?? 'cash'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ملاحظة (اختياري)',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _paymentNotesCtrl,
                      style:
                          const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'دفعة أولى...',
                        hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            color: AppColors.textTertiary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _addPayment(booking),
            child: const Text('حفظ الدفعة'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _InfoTile(
              icon: Icons.location_on_rounded,
              label: 'موقع التصوير',
              value: booking.venue ?? '—',
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _InfoTile(
              icon: Icons.access_time_rounded,
              label: 'الوقت المحدد',
              value: booking.timeStart != null && booking.timeEnd != null
                  ? '${booking.timeStart} - ${booking.timeEnd}'
                  : booking.timeStart ?? '—',
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _InfoTile(
              icon: Icons.people_rounded,
              label: 'فاريق العمل',
              value: booking.staff ?? '—',
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _InfoTile(
              icon: Icons.event_rounded,
              label: 'تاريخ التسليم المتوقع',
              value: AppFormatters.formatDate(
                  booking.bookingDate.add(const Duration(days: 14))),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.textTertiary)),
              Text(value,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmountBox extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final Color bgColor;

  const _AmountBox({
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 12, color: color)),
          const SizedBox(height: 4),
          Text(
            amount.toStringAsFixed(0),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text('ر.س',
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 11, color: color)),
        ],
      ),
    );
  }
}

class _PaymentItem extends StatelessWidget {
  final Payment payment;

  const _PaymentItem({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${AppConstants.getPaymentMethodLabel(payment.paymentMethod)} - ${payment.notes ?? ""}',
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${payment.amount.toStringAsFixed(0)} ر.س',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textTertiary)),
                Text(value,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
