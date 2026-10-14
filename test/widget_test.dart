import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('Basic widget smoke test', (WidgetTester tester) async {
    // A simple test to ensure the test environment is working
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Text('Test Passed'),
          ),
        ),
      ),
    );

    expect(find.text('Test Passed'), findsOneWidget);
  });
}
