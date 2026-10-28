import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab10_1_mocklogin/main.dart';
import 'package:lab10_1_mocklogin/screens/home_screen.dart';

void main() {
  testWidgets('Lab 10.1 MockLogin Form Validation & Navigation Test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MockLoginApp());

    // Verify UI components exist
    expect(find.text('Lab 10.1 - Mock Login'), findsOneWidget);
    expect(find.text('Sign In (Mock)'), findsOneWidget);

    // Tap login button without inputs to trigger validation errors
    await tester.tap(find.text('Sign In (Mock)'));
    await tester.pump();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    // Enter invalid email format
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'), 'invalid-email');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), '123');
    await tester.tap(find.text('Sign In (Mock)'));
    await tester.pump();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);

    // Enter valid credentials
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'), 'student@fpt.edu.vn');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.text('Sign In (Mock)'));

    // Wait for the mock delay and navigation animation
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify navigation to HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Dashboard (Mock)'), findsOneWidget);
    expect(find.text('FPT Student'), findsOneWidget);
  });
}
