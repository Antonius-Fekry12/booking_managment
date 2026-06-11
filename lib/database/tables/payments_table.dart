// lib/database/tables/payments_table.dart
import 'package:drift/drift.dart';
import 'bookings_table.dart';

@DataClassName('Payment')
class PaymentsTable extends Table {
  @override
  String get tableName => 'payments';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookingId =>
      integer().references(BookingsTable, #id)();
  RealColumn get amount => real()();
  TextColumn get paymentMethod =>
      text().withDefault(const Constant('cash'))();
  DateTimeColumn get paymentDate =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
}
