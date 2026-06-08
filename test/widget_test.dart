// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_shopping/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: Firebase initialization is skipped in tests
    await tester.pumpWidget(const SmartShoppingApp());
    
    // Verify that the app title is displayed
    expect(find.text('Smart Shopping'), findsOneWidget);
  });
}
