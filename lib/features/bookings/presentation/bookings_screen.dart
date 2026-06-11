// lib/features/bookings/presentation/bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/router/app_router.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../database/app_database.dart';

final allBookingsProvider = StreamProvider<List<Booking>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllBookings();
});

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String _searchQuery = '';
  String? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(allBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(
            child: bookingsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
              data: (bookings) {
                final filtered = _applyFilters(bookings);
                return Column(
                  children: [
                    _buildFilters(),
                    Expanded(child: _buildTable(context, filtered)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Booking> _applyFilters(List<Booking> all) {
    return all.where((b) {
      final matchStatus =
          _filterStatus == null || b.status == _filterStatus;
      final matchSearch = _searchQuery.isEmpty ||
          b.bookingNumber
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchStatus && matchSearch;
    }).toList()
      ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text('الحجوزات',
              style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          // Search
          Container(
            width: 240,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.search_rounded,
                      size: 18, color: AppColors.textTertiary),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (v) =>
                        setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'بحث في الحجوزات...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textTertiary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.createBooking),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('حجز جديد'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          const Text('تصفية:',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'الكل',
            isSelected: _filterStatus == null,
            onTap: () => setState(() => _filterStatus = null),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'مؤكد',
            isSelected: _filterStatus == 'confirmed',
            color: AppColors.success,
            onTap: () => setState(() =>
                _filterStatus = _filterStatus == 'confirmed'
                    ? null
                    : 'confirmed'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'قيد الانتظار',
            isSelected: _filterStatus == 'pending',
            color: AppColors.warning,
            onTap: () => setState(() =>
                _filterStatus =
                    _filterStatus == 'pending' ? null : 'pending'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'ملغي',
            isSelected: _filterStatus == 'cancelled',
            color: AppColors.danger,
            onTap: () => setState(() =>
                _filterStatus =
                    _filterStatus == 'cancelled' ? null : 'cancelled'),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<Booking> bookings) {
    final db = ref.watch(databaseProvider);

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded,
                size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('لا توجد حجوزات',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.createBooking),
              child: const Text('إنشاء حجز جديد'),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _TH('العميل')),
                Expanded(flex: 2, child: _TH('رقم الحجز')),
                Expanded(flex: 2, child: _TH('تاريخ المناسبة')),
                Expanded(flex: 2, child: _TH('نوع المناسبة')),
                Expanded(flex: 2, child: _TH('الإجمالي')),
                Expanded(flex: 2, child: _TH('المتبقي')),
                Expanded(flex: 2, child: _TH('الحالة')),
                SizedBox(width: 60),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: bookings.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return FutureBuilder<Customer?>(
                  future: db.getCustomerById(booking.customerId),
                  builder: (ctx, snap) {
                    final customer = snap.data;
                    return _BookingTableRow(
                      booking: booking,
                      customer: customer,
                      onTap: () =>
                          context.push('/bookings/${booking.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? c.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? c : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? c : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _BookingTableRow extends StatelessWidget {
  final Booking booking;
  final Customer? customer;
  final VoidCallback onTap;

  const _BookingTableRow({
    required this.booking,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = customer?.name ?? '...';
    final initials = name.isNotEmpty ? name[0] : '?';
    final statusColor = _sc(booking.status);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryLighter,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(name,
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                booking.bookingNumber,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: AppColors.primaryLight),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                AppFormatters.formatDateShort(booking.bookingDate),
                style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 13),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppConstants.getEventLabel(booking.eventType),
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.primary),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${booking.totalAmount.toStringAsFixed(0)} ر.س',
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${booking.remainingAmount.toStringAsFixed(0)} ر.س',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: booking.remainingAmount > 0
                      ? AppColors.danger
                      : AppColors.success,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppConstants.getStatusLabel(booking.status),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _sc(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.danger;
    }
  }
}
