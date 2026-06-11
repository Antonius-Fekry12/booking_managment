// lib/database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/customers_table.dart';
import 'tables/bookings_table.dart';
import 'tables/booking_services_table.dart';
import 'tables/payments_table.dart';
import 'tables/settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  CustomersTable,
  BookingsTable,
  BookingServicesTable,
  PaymentsTable,
  SettingsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          // Insert default settings
          await into(settingsTable).insert(
            SettingsTableCompanion.insert(
              key: 'studio_name',
              value: 'ستوديو التصوير',
            ),
          );
          await into(settingsTable).insert(
            SettingsTableCompanion.insert(
              key: 'allow_duplicate_bookings',
              value: 'false',
            ),
          );
          await into(settingsTable).insert(
            SettingsTableCompanion.insert(
              key: 'currency',
              value: 'ر.س',
            ),
          );
          // Insert sample data for demo
          await _insertSampleData();
        },
      );

  Future<void> _insertSampleData() async {
    // Sample customers
    final c1 = await into(customersTable).insert(
      CustomersTableCompanion.insert(
        name: 'سارة العتيبي',
        phone: '+966 50 111 2222',
        social: const Value('sara_photo@'),
      ),
    );
    final c2 = await into(customersTable).insert(
      CustomersTableCompanion.insert(
        name: 'فهد القحطاني',
        phone: '+966 55 333 4444',
      ),
    );
    final c3 = await into(customersTable).insert(
      CustomersTableCompanion.insert(
        name: 'نورة محمد',
        phone: '+966 54 555 6666',
        social: const Value('noura_m@'),
      ),
    );
    final c4 = await into(customersTable).insert(
      CustomersTableCompanion.insert(
        name: 'خالد الراشد',
        phone: '+966 50 777 8888',
      ),
    );

    final now = DateTime.now();

    // Sample bookings
    final b1 = await into(bookingsTable).insert(
      BookingsTableCompanion.insert(
        bookingNumber: 'BK-1001',
        customerId: c1,
        eventType: 'photography',
        bookingDate: now.copyWith(hour: 16, minute: 0),
        venue: const Value('استوديو الرياض'),
        timeStart: const Value('4:00 م'),
        timeEnd: const Value('6:00 م'),
        totalAmount: const Value(1200),
        paidAmount: const Value(1200),
        remainingAmount: const Value(0),
        status: const Value('confirmed'),
      ),
    );
    await into(bookingServicesTable).insert(
      BookingServicesTableCompanion.insert(bookingId: b1, serviceName: 'تصوير'),
    );
    await into(paymentsTable).insert(
      PaymentsTableCompanion.insert(
        bookingId: b1,
        amount: 1200,
        paymentMethod: const Value('cash'),
      ),
    );

    final b2 = await into(bookingsTable).insert(
      BookingsTableCompanion.insert(
        bookingNumber: 'BK-1002',
        customerId: c2,
        eventType: 'products',
        bookingDate: now.add(const Duration(days: 1)).copyWith(hour: 10, minute: 0),
        timeStart: const Value('10:00 ص'),
        timeEnd: const Value('12:00 م'),
        totalAmount: const Value(3500),
        paidAmount: const Value(1500),
        remainingAmount: const Value(2000),
        status: const Value('pending'),
      ),
    );
    await into(bookingServicesTable).insert(
      BookingServicesTableCompanion.insert(bookingId: b2, serviceName: 'منتجات'),
    );
    await into(paymentsTable).insert(
      PaymentsTableCompanion.insert(
        bookingId: b2,
        amount: 1500,
        paymentMethod: const Value('network'),
      ),
    );

    await into(bookingsTable).insert(
      BookingsTableCompanion.insert(
        bookingNumber: 'BK-1003',
        customerId: c3,
        eventType: 'portrait',
        bookingDate: now.add(const Duration(days: 4)).copyWith(hour: 19, minute: 30),
        timeStart: const Value('7:30 م'),
        totalAmount: const Value(850),
        paidAmount: const Value(425),
        remainingAmount: const Value(425),
        status: const Value('confirmed'),
      ),
    );

    await into(bookingsTable).insert(
      BookingsTableCompanion.insert(
        bookingNumber: 'BK-1004',
        customerId: c4,
        eventType: 'commercial',
        bookingDate: now.add(const Duration(days: 7)).copyWith(hour: 13, minute: 0),
        timeStart: const Value('1:00 م'),
        totalAmount: const Value(5000),
        paidAmount: const Value(2500),
        remainingAmount: const Value(2500),
        status: const Value('confirmed'),
      ),
    );

    // Pending payments customers
    final pendingC1 = await into(customersTable).insert(
      CustomersTableCompanion.insert(
        name: 'ليلى إبراهيم',
        phone: '+966 55 000 1111',
      ),
    );
    final pendingC2 = await into(customersTable).insert(
      CustomersTableCompanion.insert(
        name: 'أحمد فيصل',
        phone: '+966 50 222 3333',
      ),
    );

    await into(bookingsTable).insert(
      BookingsTableCompanion.insert(
        bookingNumber: 'BK-1005',
        customerId: pendingC1,
        eventType: 'wedding',
        bookingDate: now.add(const Duration(days: 14)),
        totalAmount: const Value(5000),
        paidAmount: const Value(2900),
        remainingAmount: const Value(2100),
        status: const Value('confirmed'),
      ),
    );

    await into(bookingsTable).insert(
      BookingsTableCompanion.insert(
        bookingNumber: 'BK-1006',
        customerId: pendingC2,
        eventType: 'engagement',
        bookingDate: now.add(const Duration(days: 21)),
        totalAmount: const Value(7500),
        paidAmount: const Value(3000),
        remainingAmount: const Value(4500),
        status: const Value('confirmed'),
      ),
    );
  }

  // ── Customers ──────────────────────────────────────────────
  Future<List<Customer>> getAllCustomers() =>
      select(customersTable).get();

  Future<Customer?> getCustomerById(int id) =>
      (select(customersTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> insertCustomer(CustomersTableCompanion customer) =>
      into(customersTable).insert(customer);

  Future<bool> updateCustomer(CustomersTableCompanion customer) =>
      update(customersTable).replace(customer);

  // ── Bookings ────────────────────────────────────────────────
  Future<List<Booking>> getAllBookings() =>
      (select(bookingsTable)..where((t) => t.isDeleted.not())).get();

  Stream<List<Booking>> watchAllBookings() =>
      (select(bookingsTable)..where((t) => t.isDeleted.not())).watch();

  Future<Booking?> getBookingById(int id) =>
      (select(bookingsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<Booking>> getBookingsByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(bookingsTable)
          ..where((t) =>
              t.bookingDate.isBiggerOrEqualValue(start) &
              t.bookingDate.isSmallerThanValue(end) &
              t.isDeleted.not()))
        .get();
  }

  Future<List<Booking>> getUpcomingBookings() {
    final now = DateTime.now();
    return (select(bookingsTable)
          ..where((t) =>
              t.bookingDate.isBiggerOrEqualValue(now) &
              t.isDeleted.not())
          ..orderBy([(t) => OrderingTerm.asc(t.bookingDate)])
          ..limit(20))
        .get();
  }

  Future<List<Booking>> getTodayBookings() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(bookingsTable)
          ..where((t) =>
              t.bookingDate.isBiggerOrEqualValue(start) &
              t.bookingDate.isSmallerThanValue(end) &
              t.isDeleted.not()))
        .get();
  }

  Future<int> insertBooking(BookingsTableCompanion booking) =>
      into(bookingsTable).insert(booking);

  Future<bool> updateBooking(BookingsTableCompanion booking) =>
      update(bookingsTable).replace(booking);

  Future<int> softDeleteBooking(int id) =>
      (update(bookingsTable)..where((t) => t.id.equals(id)))
          .write(const BookingsTableCompanion(isDeleted: Value(true)));

  Future<bool> isDateBooked(DateTime date) async {
    final bookings = await getBookingsByDate(date);
    return bookings.isNotEmpty;
  }

  // ── BookingServices ─────────────────────────────────────────
  Future<List<BookingService>> getServicesForBooking(int bookingId) =>
      (select(bookingServicesTable)
            ..where((t) => t.bookingId.equals(bookingId)))
          .get();

  Future<void> replaceServicesForBooking(
      int bookingId, List<String> services) async {
    await (delete(bookingServicesTable)
          ..where((t) => t.bookingId.equals(bookingId)))
        .go();
    for (final s in services) {
      await into(bookingServicesTable).insert(
        BookingServicesTableCompanion.insert(
          bookingId: bookingId,
          serviceName: s,
        ),
      );
    }
  }

  // ── Payments ────────────────────────────────────────────────
  Future<List<Payment>> getPaymentsForBooking(int bookingId) =>
      (select(paymentsTable)
            ..where((t) => t.bookingId.equals(bookingId))
            ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)]))
          .get();

  Stream<List<Payment>> watchPaymentsForBooking(int bookingId) =>
      (select(paymentsTable)
            ..where((t) => t.bookingId.equals(bookingId))
            ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)]))
          .watch();

  Future<int> addPayment(PaymentsTableCompanion payment) =>
      into(paymentsTable).insert(payment);

  // ── Settings ────────────────────────────────────────────────
  Future<String?> getSetting(String key) async {
    final row = await (select(settingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(settingsTable).insertOnConflictUpdate(
      SettingsTableCompanion.insert(key: key, value: value),
    );
  }

  // ── Stats ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDashboardStats() async {
    final all = await getAllBookings();
    final today = await getTodayBookings();
    final upcoming = await getUpcomingBookings();

    double pendingAmount = 0;
    for (final b in all) {
      pendingAmount += b.remainingAmount;
    }

    return {
      'totalBookings': all.length,
      'todayBookings': today.length,
      'upcomingBookings': upcoming.length,
      'pendingPayments': pendingAmount,
    };
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'studio_management.db'));
    return NativeDatabase.createInBackground(file);
  });
}
