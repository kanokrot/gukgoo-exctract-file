import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gukgoo/main.dart'; // Import the file where MyApp is defined

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build the MyApp widget
    await tester.pumpWidget(MyApp());

    // Verify that the initial counter value is 0
    expect(find.text('0'), findsOneWidget);

    // Tap the '+' icon to increment the counter
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(); // Rebuild the widget after the state has changed

    // Verify that the counter value has incremented to 1
    expect(find.text('1'), findsOneWidget);
  });
}
