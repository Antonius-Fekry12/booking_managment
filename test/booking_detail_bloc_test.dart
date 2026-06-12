import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:booking_managment/core/di/service_locator.dart';
import 'package:booking_managment/database/app_database.dart';
import 'package:booking_managment/features/bookings/bloc/booking_detail_bloc.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
    if (sl.isRegistered<AppDatabase>()) {
      sl.unregister<AppDatabase>();
    }
    sl.registerSingleton<AppDatabase>(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Add payment recalculates booking amounts', () async {
    // 1. Create a customer
    final customerId = await db.insertCustomer(
      CustomersTableCompanion.insert(
        name: 'John Doe',
        phone: '123456789',
      ),
    );

    // 2. Create a booking with total amount 1000, paid 200, remaining 800
    final bookingId = await db.insertBooking(
      BookingsTableCompanion.insert(
        bookingNumber: 'BK-TEST',
        customerId: customerId,
        eventType: 'wedding',
        bookingDate: DateTime.now(),
        totalAmount: const Value(1000.0),
        paidAmount: const Value(200.0),
        remainingAmount: const Value(800.0),
      ),
    );

    // Insert the initial payment of 200 to match
    await db.addPayment(
      PaymentsTableCompanion.insert(
        bookingId: bookingId,
        amount: 200.0,
      ),
    );

    final bloc = BookingDetailBloc();

    // Load detail
    bloc.add(LoadBookingDetail(bookingId));
    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate((BookingDetailState state) {
          return state.status == BookingDetailStatus.success &&
              state.booking != null &&
              state.booking!.remainingAmount == 800.0;
        }),
      ),
    );

    // Add another payment of 300
    bloc.add(AddPaymentEvent(
      PaymentsTableCompanion.insert(
        bookingId: bookingId,
        amount: 300.0,
      ),
    ));

    await expectLater(
      bloc.stream,
      emitsThrough(
        predicate((BookingDetailState state) {
          final b = state.booking;
          if (b == null) return false;
          return b.remainingAmount == 500.0 && b.paidAmount == 500.0;
        }),
      ),
    );
  });
}
