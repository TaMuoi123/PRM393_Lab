import 'package:flutter_test/flutter_test.dart';
import 'package:weather_companion/main.dart';

void main() {
  testWidgets('WeatherCompanionApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherCompanionApp());
    // Initial pump should show the loading indicator or app structure
    expect(find.byType(WeatherCompanionApp), findsOneWidget);
  });
}
