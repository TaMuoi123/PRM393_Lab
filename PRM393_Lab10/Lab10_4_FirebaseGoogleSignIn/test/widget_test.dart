import 'package:flutter_test/flutter_test.dart';
import 'package:lab10_4_firebasegooglesignin/main.dart';
import 'package:lab10_4_firebasegooglesignin/screens/profile_screen.dart';

void main() {
  testWidgets('Lab 10.4 Google Sign-In UI and Demo Mode Navigation Test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FirebaseGoogleSignInApp());

    // Verify UI components exist
    expect(find.text('Lab 10.4 - Google Sign-In'), findsOneWidget);
    expect(find.text('Sign in with Google (Firebase)'), findsOneWidget);
    expect(find.text('Demo Google Sign-In (Simulator Mode)'), findsOneWidget);

    // Tap demo mode button
    await tester.tap(find.text('Demo Google Sign-In (Simulator Mode)'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Verify navigation to ProfileScreen
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Google User Profile'), findsOneWidget);
    expect(find.text('Nguyen Van A (Google User)'), findsOneWidget);
    expect(find.text('anguyen.prm393@gmail.com'), findsOneWidget);
    expect(find.text('Sign Out from Google'), findsOneWidget);
  });
}
