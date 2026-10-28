import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lab10_3_autologin_logout/main.dart';
import 'package:lab10_3_autologin_logout/screens/home_screen.dart';
import 'package:lab10_3_autologin_logout/screens/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Routing: Empty session redirects to LoginScreen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const AutoLoginApp());
    expect(find.text('Checking existing credentials...'), findsOneWidget);

    // Wait for splash timer and transition
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Lab 10.3 - Auto Login'), findsOneWidget);
  });

  testWidgets('AutoLogin: Persisted session redirects to HomeScreen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'user_session_data':
          '{"id":1,"username":"emilys","email":"emily.johnson@x.dummyjson.com","firstName":"Emily","lastName":"Johnson","gender":"female","image":"","token":"persisted-jwt-test-token","loginTime":"2026-10-21T00:00:00.000"}',
      'auth_token': 'persisted-jwt-test-token',
    });

    await tester.pumpWidget(const AutoLoginApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Session Dashboard'), findsOneWidget);
    expect(find.text('Emily Johnson'), findsOneWidget);
    expect(find.text('Auto-Login Active: Session successfully restored from SharedPreferences without prompting for credentials!'), findsOneWidget);
  });
}
