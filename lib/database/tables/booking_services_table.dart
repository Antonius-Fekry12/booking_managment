// lib/database/tables/booking_services_table.dart
import 'package:drift/drift.dart';
import 'bookings_table.dart';

@DataClassName('BookingService')
class BookingServicesTable extends Table {
  @override
  String get tableName => 'booking_services';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookingId =>
      integer().references(BookingsTable, #id)();
  TextColumn get serviceName => text()();
}
