// lib/features/bookings/presentation/bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../database/app_database.dart';
import '../bloc/bookings_bloc.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<BookingsBloc, BookingsState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status ||
                  previous.bookings != current.bookings ||
                  previous.customers != current.customers ||
                  previous.searchQuery != current.searchQuery ||
                  previous.filterStatus != current.filterStatus ||
                  previous.sortColumn != current.sortColumn ||
                  previous.sortAscending != current.sortAscending ||
                  previous.currentPage != current.currentPage,
              builder: (context, state) {
                if (state.status == BookingsStatus.loading || state.status == BookingsStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == BookingsStatus.failure) {
                  return Center(child: Text('خطأ: ${state.errorMessage}'));
                }

                return Column(
                  children: [
                    _buildFilters(context, state),
                    Expanded(child: _buildTable(context, state)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
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
                        context.read<BookingsBloc>().add(UpdateSearchQuery(v)),
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

  Widget _buildFilters(BuildContext context, BookingsState state) {
    final filterStatus = state.filterStatus;
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
            isSelected: filterStatus == null,
            onTap: () => context.read<BookingsBloc>().add(const UpdateFilterStatus(null)),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'مؤكد',
            isSelected: filterStatus == 'confirmed',
            color: AppColors.success,
            onTap: () => context.read<BookingsBloc>().add(UpdateFilterStatus(
                filterStatus == 'confirmed' ? null : 'confirmed')),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'قيد الانتظار',
            isSelected: filterStatus == 'pending',
            color: AppColors.warning,
            onTap: () => context.read<BookingsBloc>().add(UpdateFilterStatus(
                filterStatus == 'pending' ? null : 'pending')),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'ملغي',
            isSelected: filterStatus == 'cancelled',
            color: AppColors.danger,
            onTap: () => context.read<BookingsBloc>().add(UpdateFilterStatus(
                filterStatus == 'cancelled' ? null : 'cancelled')),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, BookingsState state) {
    final bookings = state.paginatedBookings;

    if (state.filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded,
                size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              state.searchQuery.isNotEmpty ? 'لا توجد نتائج مطابقة' : 'لا توجد حجوزات',
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  color: AppColors.textSecondary),
            ),
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
            child: Row(
              children: [
                Expanded(flex: 3, child: _SortableTableHeader('العميل', 'customerName', state)),
                Expanded(flex: 2, child: _SortableTableHeader('رقم الحجز', 'bookingNumber', state)),
                Expanded(flex: 2, child: _SortableTableHeader('تاريخ المناسبة', 'date', state)),
                Expanded(flex: 2, child: _SortableTableHeader('نوع المناسبة', 'eventType', state)),
                Expanded(flex: 2, child: _SortableTableHeader('الإجمالي', 'price', state)),
                Expanded(flex: 2, child: _SortableTableHeader('المتبقي', 'remaining', state)),
                Expanded(flex: 2, child: _SortableTableHeader('الحالة', 'status', state)),
                const SizedBox(width: 60),
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
                final customer = state.customers[booking.customerId];
                return _BookingTableRow(
                  booking: booking,
                  customer: customer,
                  onTap: () =>
                      context.push('/bookings/${booking.id}'),
                );
              },
            ),
          ),
          // Pagination Controls
          if (state.filteredBookings.length > 20)
            _buildPaginationControls(context, state),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context, BookingsState state) {
    final totalPages = state.totalPages;
    final currentPage = state.currentPage;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'عرض ${(currentPage - 1) * state.pageSize + 1} - ${(currentPage * state.pageSize).clamp(0, state.filteredBookings.length)} من أصل ${state.filteredBookings.length}',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
                onPressed: currentPage > 1
                    ? () => context.read<BookingsBloc>().add(UpdatePage(currentPage - 1))
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'صفحة $currentPage من $totalPages',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onPressed: currentPage < totalPages
                    ? () => context.read<BookingsBloc>().add(UpdatePage(currentPage + 1))
                    : null,
              ),
            ],
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
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                '${booking.totalAmount.toStringAsFixed(0)} ج.م',
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${booking.remainingAmount.toStringAsFixed(0)} ج.م',
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

class _SortableTableHeader extends StatelessWidget {
  final String label;
  final String column;
  final BookingsState state;

  const _SortableTableHeader(this.label, this.column, this.state);

  @override
  Widget build(BuildContext context) {
    final isSelected = state.sortColumn == column;
    final arrow = isSelected ? (state.sortAscending ? ' ↑' : ' ↓') : '';
    return InkWell(
      onTap: () => context.read<BookingsBloc>().add(UpdateSorting(column)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          Text(
            arrow,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
