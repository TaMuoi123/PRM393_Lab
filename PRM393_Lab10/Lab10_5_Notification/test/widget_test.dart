import 'package:flutter_test/flutter_test.dart';
import 'package:lab10_5_notification/main.dart';
import 'package:lab10_5_notification/screens/notification_screen.dart';

void main() {
  testWidgets('Lab 10.5 Local Notification UI and Interaction Test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NotificationApp());

    // Verify UI components exist
    expect(find.byType(NotificationScreen), findsOneWidget);
    expect(find.text('Lab 10.5 - Local Notifications'), findsOneWidget);
    expect(find.text('Notification Permission (LO7)'), findsOneWidget);
    expect(find.text('Instant Alert'), findsOneWidget);
    expect(find.text('Login Success (LO7)'), findsOneWidget);

    // Tap the Instant Alert demo trigger
    await tester.tap(find.text('Instant Alert'));
    await tester.pump();

    // Verify notification was added to trigger history list
    expect(find.text('Instant Alert 🔔'), findsOneWidget);
    expect(find.text('Notification History (1)'), findsOneWidget);

    // Tap Login Success trigger
    await tester.tap(find.text('Login Success (LO7)'));
    await tester.pump();

    expect(find.text('Login Successful! 🎉'), findsOneWidget);
    expect(find.text('Notification History (2)'), findsOneWidget);
  });
}
