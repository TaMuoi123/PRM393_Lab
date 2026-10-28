import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab9_local_storage/services/file_storage_service.dart';
import 'package:lab9_local_storage/screens/home_screen.dart';
import 'package:lab9_local_storage/screens/lab9_2_storage_screen.dart';
import 'package:lab9_local_storage/screens/lab9_3_crud_screen.dart';

void main() {
  late FileStorageService storageService;

  setUp(() {
    storageService = FileStorageService(inMemory: true);
  });

  Future<void> pumpUntilLoaded(WidgetTester tester) async {
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        break;
      }
    }
  }

  testWidgets('HomeScreen renders navigation destinations', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(storageService: storageService),
      ),
    );
    await tester.pump();

    expect(find.text('Lab 9.1 Assets'), findsOneWidget);
    expect(find.text('Lab 9.2 Storage'), findsOneWidget);
    expect(find.text('Lab 9.3 CRUD'), findsOneWidget);
  });

  testWidgets('Lab92StorageScreen adds note and persists to storage', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Lab92StorageScreen(storageService: storageService),
      ),
    );
    await pumpUntilLoaded(tester);

    expect(find.text('Lab 9.2: Local Storage Persistence'), findsOneWidget);
    expect(find.text('Add New Note / Item'), findsOneWidget);

    // Enter note title and content
    final titleField = find.widgetWithText(TextField, 'Note Title *');
    final contentField = find.widgetWithText(TextField, 'Content / Details');

    await tester.enterText(titleField, 'Integration Test Note');
    await tester.enterText(contentField, 'Verifying file save');

    // Click 'Add to List'
    await tester.tap(find.text('Add to List'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Integration Test Note'), findsOneWidget);

    // Click 'Save to Storage'
    await tester.tap(find.text('Save to Storage'));
    await tester.pump(const Duration(milliseconds: 200));

    // Verify file persisted in storage service
    final savedNotes = await storageService.readJsonList('local_notes.json');
    expect(savedNotes.any((n) => n['title'] == 'Integration Test Note'), isTrue);
  });

  testWidgets('Lab93CrudScreen renders and filters students by search query', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Lab93CrudScreen(storageService: storageService),
      ),
    );
    await pumpUntilLoaded(tester);

    expect(find.text('Lab 9.3: JSON CRUD Database'), findsOneWidget);
    expect(find.text('Add Student'), findsOneWidget);

    // Filter by search bar
    final searchField = find.widgetWithText(TextField, 'Search by name, student code, major, email...');
    await tester.enterText(searchField, 'Nguyen Van An');
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.widgetWithText(Card, 'Nguyen Van An'), findsOneWidget);

    // Filter non-matching query
    await tester.enterText(searchField, 'XYZ999Unknown');
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.widgetWithText(Card, 'Nguyen Van An'), findsNothing);
    expect(find.text('No students found matching your filters.'), findsOneWidget);

    // Clear search
    await tester.enterText(searchField, '');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.widgetWithText(Card, 'Nguyen Van An'), findsOneWidget);
  });
}
