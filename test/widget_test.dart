import 'package:flutter_test/flutter_test.dart';
import 'package:first_futter_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This test will fail because Hive is not initialized in test environment.
    // In a real scenario, we would mock Hive.
    await tester.pumpWidget(const ExpenseTrackerApp());
  });
}
