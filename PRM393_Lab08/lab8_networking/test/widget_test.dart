import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab8_networking/main.dart';
import 'package:lab8_networking/models/post.dart';

void main() {
  test('Post model serialization and deserialization', () {
    final jsonMap = {
      'userId': 1,
      'id': 10,
      'title': 'Test Title',
      'body': 'Test Body Description',
    };

    final post = Post.fromJson(jsonMap);

    expect(post.userId, 1);
    expect(post.id, 10);
    expect(post.title, 'Test Title');
    expect(post.body, 'Test Body Description');

    final exportedJson = post.toJson();
    expect(exportedJson['userId'], 1);
    expect(exportedJson['id'], 10);
    expect(exportedJson['title'], 'Test Title');
    expect(exportedJson['body'], 'Test Body Description');
  });

  testWidgets('App starts and displays AppBar title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Expect the AppBar title to be present
    expect(find.text('API Posts List'), findsOneWidget);

    // Initial state shows loading indicator or text
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
