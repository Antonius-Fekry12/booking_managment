// lib/app/router/app_router.dart
import 'package:go_router/go_router.dart';
import '../../core/widgets/app_shell.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/bookings/presentation/bookings_screen.dart';
import '../../features/bookings/presentation/create_booking_screen.dart';
import '../../features/bookings/presentation/booking_detail_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String bookings = '/bookings';
  static const String createBooking = '/bookings/create';
  static const String bookingDetail = '/bookings/:id';
  static const String calendar = '/calendar';
  static const String customers = '/customers';
  static const String settings = '/settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.bookings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BookingsScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.createBooking,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CreateBookingScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.bookingDetail,
          pageBuilder: (context, state) {
            final id = int.parse(state.pathParameters['id'] ?? '0');
            return NoTransitionPage(
              child: BookingDetailScreen(bookingId: id),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.calendar,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CalendarScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.customers,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CustomersScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
