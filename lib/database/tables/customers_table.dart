// lib/database/tables/customers_table.dart
import 'package:drift/drift.dart';

@DataClassName('Customer')
class CustomersTable extends Table {
  @override
  String get tableName => 'customers';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 100)();
  TextColumn get phone => text().withLength(max: 20)();
  TextColumn get social => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
