import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lab10_full/main.dart';
import 'package:lab10_full/screens/home_screen.dart';
import 'package:lab10_full/screens/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Lab10_Full Routing: Empty storage routes to LoginScreen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const Lab10FullApp());
    expect(find.text('PRM393 - Lab 10'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('PRM393 - Lab 10 Full'), findsOneWidget);
    expect(find.text('Sign In via REST API'), findsOneWidget);
  });

  testWidgets('Lab10_Full Auto-Login: Restores session and routes to HomeScreen',
      (WidgetTester tester) async {
    final mockUserJson =
        '{"id":"1","username":"emilys","email":"emily.johnson@x.dummyjson.com","displayName":"Emily Johnson","photoUrl":"","token":"persisted-test-token","authProvider":"DummyJSON REST API","loginTime":"2026-10-22T00:00:00.000"}';

    SharedPreferences.setMockInitialValues({
      'lab10_full_user_session': mockUserJson,
      'lab10_full_auth_token': 'persisted-test-token',
    });

    await tester.pumpWidget(const Lab10FullApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Lab 10 Dashboard'), findsOneWidget);
    expect(find.text('Emily Johnson'), findsOneWidget);
    expect(find.text('Provider: DummyJSON REST API'), findsOneWidget);
    expect(find.text('Auto-Login: Session automatically restored from SharedPreferences without re-authenticating!'),
        findsOneWidget);
  });
}
