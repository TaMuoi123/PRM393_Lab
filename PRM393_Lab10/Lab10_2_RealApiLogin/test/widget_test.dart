import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab10_2_realapilogin/main.dart';

void main() {
  testWidgets('Lab 10.2 RealApiLogin Validation and Form Test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RealApiLoginApp());

    // Verify UI components
    expect(find.text('Lab 10.2 - Real API Login'), findsOneWidget);
    expect(find.text('Log In via DummyJSON'), findsOneWidget);

    // Validation when fields are empty
    await tester.tap(find.text('Log In via DummyJSON'));
    await tester.pump();

    expect(find.text('Please enter your DummyJSON username'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    // Test quick fill chip
    await tester.tap(find.text('Emily Johnson'));
    await tester.pump();

    // Verify username and password textfields were populated
    final usernameField = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Username'),
    );
    expect(usernameField.controller?.text, equals('emilys'));

    final passwordField = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Password'),
    );
    expect(passwordField.controller?.text, equals('emilyspass'));
  });
}
