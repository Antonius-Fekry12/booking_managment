// lib/database/tables/bookings_table.dart
import 'package:drift/drift.dart';
import 'customers_table.dart';

@DataClassName('Booking')
class BookingsTable extends Table {
  @override
  String get tableName => 'bookings';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get bookingNumber => text().withLength(max: 20)();
  IntColumn get customerId => integer().references(CustomersTable, #id)();
  TextColumn get eventType => text()();
  DateTimeColumn get bookingDate => dateTime()();
  TextColumn get venue => text().nullable()();
  TextColumn get timeStart => text().nullable()();
  TextColumn get timeEnd => text().nullable()();
  TextColumn get staff => text().nullable()();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  RealColumn get remainingAmount => real().withDefault(const Constant(0.0))();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // confirmed/pending/cancelled
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
