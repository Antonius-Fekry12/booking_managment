// lib/features/dashboard/presentation/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../database/app_database.dart';

// ── Providers ────────────────────────────────────────────────────────────────
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getDashboardStats();
});

final upcomingBookingsProvider = FutureProvider<List<Booking>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getUpcomingBookings();
});

// Bookings with remaining payments
final pendingPaymentsBookingsProvider = FutureProvider<List<Booking>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllBookings().then(
    (all) => all.where((b) => b.remainingAmount > 0).toList()..sort(
          (a, b) => b.remainingAmount.compareTo(a.remainingAmount),
        ),
  );
});

// ── Screen ────────────────────────────────────────────────────────────────────
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref),
              const SizedBox(height: 24),
              _buildStatCards(context, ref),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildUpcomingBookings(context, ref)),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _buildPendingPayments(context, ref)),
                ],
              ),
              const SizedBox(height: 20),
              _buildPromoBanner(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أهلاً بك مجدداً، أحمد 👋',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'لديك 4 جلسات تصوير مقررة لهذا اليوم.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Search bar
        Container(
          width: 280,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
              ),
              const Expanded(
                child: TextField(
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'البحث عن حجز أو عميل...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Icons
        _IconButton(icon: Icons.calendar_today_rounded, onTap: () => context.go(AppRoutes.calendar)),
        const SizedBox(width: 8),
        _IconButton(icon: Icons.notifications_none_rounded, badge: true, onTap: () {}),
        const SizedBox(width: 16),
        // New booking button
        ElevatedButton.icon(
          onPressed: () => context.push(AppRoutes.createBooking),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('ابدأ حجزاً جديداً'),
        ),
      ],
    );
  }

  Widget _buildStatCards(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      loading: () => const _StatCardsLoading(),
      error: (e, _) => Text('خطأ: $e'),
      data: (stats) {
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'الحجوزات القادمة',
                value: stats['upcomingBookings'].toString(),
                badge: '+12%',
                badgeColor: AppColors.success,
                icon: Icons.access_time_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.primaryLighter,
                tag: 'هذا الشهر',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                label: 'حجوزات اليوم',
                value: stats['todayBookings'].toString(),
                icon: Icons.event_available_rounded,
                iconColor: AppColors.info,
                iconBg: AppColors.infoLight,
                tag: 'اليوم',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                label: 'دفعات معلقة',
                value: AppFormatters.formatCurrency(
                    (stats['pendingPayments'] as double)),
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.danger,
                iconBg: AppColors.dangerLight,
                tag: 'مستحق',
                isLarge: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingBookings(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(upcomingBookingsProvider);
    final db = ref.watch(databaseProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Text(
                  'الحجوزات القادمة',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go(AppRoutes.bookings),
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
          ),
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
              color: AppColors.surfaceVariant,
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: _TableHeader('اسم العميل')),
                Expanded(flex: 2, child: _TableHeader('التاريخ والوقت')),
                Expanded(flex: 2, child: _TableHeader('نوع الجلسة')),
                Expanded(flex: 2, child: _TableHeader('المبلغ')),
                Expanded(flex: 2, child: _TableHeader('الحالة')),
              ],
            ),
          ),
          bookingsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(20),
              child: Text('خطأ: $e'),
            ),
            data: (bookings) {
              if (bookings.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'لا توجد حجوزات قادمة',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: bookings.take(6).map((booking) {
                  return FutureBuilder<Customer?>(
                    future: db.getCustomerById(booking.customerId),
                    builder: (context, snapshot) {
                      final customer = snapshot.data;
                      return _BookingRow(
                        booking: booking,
                        customer: customer,
                        onTap: () => context.push('/bookings/${booking.id}'),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPayments(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingPaymentsBookingsProvider);
    final db = ref.watch(databaseProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Text(
                  'دفعات معلقة',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                pending.whenOrNull(
                      data: (list) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.dangerLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${list.length} عملاء',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ) ??
                    const SizedBox.shrink(),
              ],
            ),
          ),
          const Divider(height: 1),
          pending.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('$e'),
            data: (list) {
              return Column(
                children: list.take(5).map((booking) {
                  return FutureBuilder<Customer?>(
                    future: db.getCustomerById(booking.customerId),
                    builder: (context, snapshot) {
                      final customer = snapshot.data;
                      return _PendingPaymentRow(
                        booking: booking,
                        customerName: customer?.name ?? '...',
                        onRemind: () {},
                        onTap: () => context.push('/bookings/${booking.id}'),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('تصدير تقرير المتأخرات'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.dangerLight),
                  backgroundColor: AppColors.dangerLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2942), Color(0xFF1B4B6B)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تطوير الستوديو الخاص بك',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'هل ترغب في أتمتة رسائل التذكير وتحديثات الحجز؟ جرب باقة "برو" الآن واحصل على خصم 20% لفترة محدودة.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'اكتشف المزيد',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  const _IconButton({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.textSecondary),
            ),
          ),
        ),
        if (badge)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String tag;
  final String? badge;
  final Color? badgeColor;
  final bool isLarge;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.tag,
    this.badge,
    this.badgeColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
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
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? AppColors.success).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeColor ?? AppColors.success,
                    ),
                  ),
                ),
                const Spacer(),
              ] else
                const Spacer(),
              if (tag.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: isLarge ? 22 : 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardsLoading extends StatelessWidget {
  const _StatCardsLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i < 2 ? 16 : 0),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

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

class _BookingRow extends StatelessWidget {
  final Booking booking;
  final Customer? customer;
  final VoidCallback onTap;

  const _BookingRow({
    required this.booking,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = customer?.name ?? '...';
    final initials = name.isNotEmpty ? name[0] : '?';
    final statusColor = _statusColor(booking.status);
    final statusLabel = AppConstants.getStatusLabel(booking.status);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderLight)),
        ),
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
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _relativeDate(booking.bookingDate),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    AppFormatters.formatTime(booking.bookingDate),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppConstants.getEventLabel(booking.eventType),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${booking.totalAmount.toStringAsFixed(0)}\nر.س',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
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
          ],
        ),
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

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(today).inDays;
    if (diff == 0) return 'اليوم،';
    if (diff == 1) return 'غداً،';
    if (diff == -1) return 'أمس،';
    return AppFormatters.formatDateShort(date);
  }
}

class _PendingPaymentRow extends StatelessWidget {
  final Booking booking;
  final String customerName;
  final VoidCallback onRemind;
  final VoidCallback onTap;

  const _PendingPaymentRow({
    required this.booking,
    required this.customerName,
    required this.onRemind,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = customerName.isNotEmpty ? customerName[0] : '?';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.surfaceVariant,
              child: Text(
                initials,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'ر.س ${booking.remainingAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onRemind,
              icon: const Icon(Icons.mail_outline_rounded, size: 14),
              label: const Text(
                'تذكير',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
