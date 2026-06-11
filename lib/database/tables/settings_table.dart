// lib/database/tables/settings_table.dart
import 'package:drift/drift.dart';

@DataClassName('Setting')
class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
