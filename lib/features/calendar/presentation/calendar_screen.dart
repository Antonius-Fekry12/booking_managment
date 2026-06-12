// lib/features/calendar/presentation/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/formatters.dart';
import '../../../database/app_database.dart';
import '../../../app/router/app_router.dart';
import '../bloc/calendar_bloc.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _selectedDay;
  List<Booking> _dayBookings = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalendarBloc()..add(LoadMonthBookings(DateTime.now())),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            final currentMonth = state.currentMonth;
            return Row(
              children: [
                // Side panel: shown when a day is selected
                if (_selectedDay != null)
                  _buildSidePanel(context),
                Expanded(
                  child: Column(
                    children: [
                      _buildHeader(context, currentMonth),
                      Expanded(
                        child: state.status == CalendarStatus.loading || state.status == CalendarStatus.initial
                            ? const Center(child: CircularProgressIndicator())
                            : state.status == CalendarStatus.failure
                                ? Center(child: Text('${state.errorMessage}'))
                                : _buildCalendar(context, currentMonth, state.bookings),
                      ),
                      _buildLegend(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDayBookingsDialog(BuildContext context, DateTime date, List<Booking> bookings) async {
    final db = sl<AppDatabase>();
    
    // Resolve all customers first
    final customersList = <Customer>[];
    for (final b in bookings) {
      final c = await db.getCustomerById(b.customerId);
      if (c != null) {
        customersList.add(c);
      }
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.event_note_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'حجوزات يوم ${AppFormatters.formatDateShort(date)}',
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'إجمالي عدد الحجوزات:',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Text(
                          '${bookings.length}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'تفاصيل الجلسات:',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        final customer = customersList.firstWhere(
                          (c) => c.id == booking.customerId,
                          orElse: () => Customer(id: -1, name: '...', phone: '', createdAt: DateTime.now()),
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_rounded, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  customer.name,
                                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  'الوقت: ${booking.timeStart ?? '--'}',
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.photo_camera_rounded, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  'نوع الجلسة: ${AppConstants.getEventLabel(booking.eventType)}',
                                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DateTime month) {
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            'نظام إدارة الحجوزات',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          // Search

          const Spacer(),

          const SizedBox(width: 24),
          // Month navigation
          Row(
            children: [
              IconButton(
                onPressed: () => context.read<CalendarBloc>().add(
                    ChangeMonthEvent(DateTime(month.year, month.month - 1))),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Text(
                '${arabicMonths[month.month - 1]} ${month.year}',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              IconButton(
                onPressed: () => context.read<CalendarBloc>().add(
                    ChangeMonthEvent(DateTime(month.year, month.month + 1))),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(
      BuildContext context, DateTime month, List<Booking> bookings) {
    final daysInMonth =
        DateUtils.getDaysInMonth(month.year, month.month);
    // Saturday = 6, Sunday = 0 in Arabic calendar (week starts Sunday)
    final firstDay = DateTime(month.year, month.month, 1);
    // Arabic week: Sun Mon Tue Wed Thu Fri Sat
    // Dart weekday: Mon=1,...,Sun=7
    // Offset: Sun=0, Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6
    int startOffset = firstDay.weekday % 7; // Sun=0

    // Group bookings by day
    final Map<int, List<Booking>> byDay = {};
    for (final b in bookings) {
      final day = b.bookingDate.day;
      byDay.putIfAbsent(day, () => []).add(b);
    }

    const headers = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Day headers
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: headers
                    .map((h) => Expanded(
                          child: Center(
                            child: Text(
                              h,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            // Calendar grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1.2,
                ),
                itemCount: startOffset + daysInMonth,
                itemBuilder: (context, index) {
                  if (index < startOffset) {
                    return const SizedBox.shrink();
                  }
                  final day = index - startOffset + 1;
                  final date =
                      DateTime(month.year, month.month, day);
                  final dayBookings = byDay[day] ?? [];
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final isSelected = _selectedDay?.day == day &&
                      _selectedDay?.month == month.month;

                  return _CalendarDayCell(
                    day: day,
                    bookings: dayBookings,
                    isToday: isToday,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedDay = date;
                        _dayBookings = dayBookings;
                      });
                      if (dayBookings.isNotEmpty) {
                        _showDayBookingsDialog(context, date, dayBookings);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context) {
    final db = sl<AppDatabase>();

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text('تفاصيل الحجز',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  onPressed: () =>
                      setState(() => _selectedDay = null),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const Divider(),
          if (_dayBookings.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _SidePanelField(label: 'العميل', value: '--'),
                  SizedBox(height: 12),
                  _SidePanelField(label: 'الوقت', value: '--'),
                  SizedBox(height: 12),
                  _SidePanelField(label: 'المناسبة', value: '--'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'هذا اليوم متاح للحجز',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _dayBookings.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final booking = _dayBookings[i];
                  return FutureBuilder<Customer?>(
                    future: db.getCustomerById(booking.customerId),
                    builder: (ctx, snap) {
                      final customer = snap.data;
                      return _SidePanelBookingCard(
                        booking: booking,
                        customer: customer,
                        onTap: () => context.push(
                            '/bookings/${booking.id}'),
                        onEdit: () => context.push(
                            '/bookings/${booking.id}'),
                        onCancel: () async {
                          context.read<CalendarBloc>().add(DeleteCalendarBookingEvent(booking.id));
                          setState(() {
                            _dayBookings.removeAt(i);
                            if (_dayBookings.isEmpty) {
                              _selectedDay = null;
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          if (_dayBookings.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context
                      .push(AppRoutes.createBooking),
                  child: const Text('تعديل الحجز'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'إلغاء الحجز',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
              ),
            ),
          ],
          const Spacer(),
          // Camera image placeholder
          Container(
            height: 130,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2942), Color(0xFF1B4B6B)],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
            child: const Center(
              child: Icon(Icons.camera_alt_rounded,
                  size: 48, color: Colors.white30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          _LegendItem(color: AppColors.primary, label: 'اليوم المحدد'),
          SizedBox(width: 16),
          _LegendItem(color: Color(0xFFFEF08A), label: 'يوجد حجز'),
          SizedBox(width: 16),
          _LegendItem(color: Color(0xFFF1F5F9), label: 'لا يوجد حجز'),
        ],
      ),
    );
  }
}

// ── Calendar Day Cell ─────────────────────────────────────────────────────────
class _CalendarDayCell extends StatelessWidget {
  final int day;
  final List<Booking> bookings;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.day,
    required this.bookings,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    if (isSelected) {
      bgColor = AppColors.primaryLighter;
    } else if (bookings.isNotEmpty) {
      bgColor = const Color(0xFFFEF08A); // Yellow
    } else {
      bgColor = const Color(0xFFF1F5F9); // Grey
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : isToday
                  ? Border.all(color: AppColors.primary, width: 1)
                  : null,
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight:
                    isToday ? FontWeight.w700 : FontWeight.w400,
                color: isToday
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
            if (bookings.isNotEmpty && bookings.first.customerId > 0)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    bookings.length == 1
                        ? 'حجز واحد'
                        : '${bookings.length} حجوزات',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Side panel widgets ────────────────────────────────────────────────────────
class _SidePanelField extends StatelessWidget {
  final String label;
  final String value;

  const _SidePanelField(
      {required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidePanelBookingCard extends StatelessWidget {
  final Booking booking;
  final Customer? customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const _SidePanelBookingCard({
    required this.booking,
    required this.customer,
    required this.onTap,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final name = customer?.name ?? '...';
    final statusColor = booking.status == 'confirmed'
        ? AppColors.success
        : AppColors.warning;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppConstants.getStatusLabel(booking.status),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  booking.bookingNumber,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(name,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              AppConstants.getEventLabel(booking.eventType),
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: AppColors.textSecondary)),
      ],
    );
  }
}
