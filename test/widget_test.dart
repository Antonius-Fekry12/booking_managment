import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booking_managment/core/di/service_locator.dart';
import 'package:booking_managment/database/app_database.dart';
import 'package:booking_managment/app/app.dart';

void main() {
  setUp(() {
    if (!sl.isRegistered<AppDatabase>()) {
      setupLocator();
    }
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StudioManagementApp());

    // Verify that the app title or main layout is loaded
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
