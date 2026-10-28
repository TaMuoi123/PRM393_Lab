import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab9_local_storage/models/product.dart';
import 'package:lab9_local_storage/models/note_item.dart';
import 'package:lab9_local_storage/models/student_item.dart';
import 'package:lab9_local_storage/services/file_storage_service.dart';

void main() {
  group('Model Serialization & Deserialization Tests', () {
    test('Product.fromJson and toJson work correctly', () {
      final json = {
        'id': 101,
        'name': 'Wireless Mouse',
        'category': 'Peripherals',
        'price': 49.99,
        'description': 'Ergonomic mouse',
        'rating': 4.5,
        'inStock': true,
      };

      final product = Product.fromJson(json);
      expect(product.id, 101);
      expect(product.name, 'Wireless Mouse');
      expect(product.category, 'Peripherals');
      expect(product.price, 49.99);
      expect(product.description, 'Ergonomic mouse');
      expect(product.rating, 4.5);
      expect(product.inStock, true);

      final encoded = product.toJson();
      expect(encoded['id'], 101);
      expect(encoded['name'], 'Wireless Mouse');
      expect(encoded['price'], 49.99);
    });

    test('NoteItem.fromJson and toJson work correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Note',
        'content': 'Test Content',
        'timestamp': '2026-10-21 10:00',
      };

      final note = NoteItem.fromJson(json);
      expect(note.id, 1);
      expect(note.title, 'Test Note');
      expect(note.content, 'Test Content');
      expect(note.timestamp, '2026-10-21 10:00');

      final encoded = note.toJson();
      expect(encoded['title'], 'Test Note');
    });

    test('StudentItem.fromJson and copyWith work correctly', () {
      final json = {
        'id': 1,
        'studentCode': 'SE123456',
        'fullName': 'Nguyen Van A',
        'major': 'Software Engineering',
        'gpa': 3.9,
        'email': 'an@fpt.edu.vn',
        'phone': '0901234567',
      };

      final student = StudentItem.fromJson(json);
      expect(student.studentCode, 'SE123456');
      expect(student.gpa, 3.9);

      final updated = student.copyWith(gpa: 4.0, fullName: 'Nguyen Van A+');
      expect(updated.gpa, 4.0);
      expect(updated.fullName, 'Nguyen Van A+');
      expect(updated.studentCode, 'SE123456'); // Kept unchanged
    });
  });

  group('FileStorageService Tests', () {
    late Directory tempDir;
    late FileStorageService storageService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('flutter_lab9_test_');
      storageService = FileStorageService(customDirectoryPath: tempDir.path);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('readJsonList returns defaultData if file does not exist', () async {
      final defaultData = [
        {'id': 1, 'title': 'Initial'}
      ];
      final result = await storageService.readJsonList(
        'test_notes.json',
        defaultData: defaultData,
      );
      expect(result.length, 1);
      expect(result.first['title'], 'Initial');
    });

    test('writeJsonList persists data and can be read back', () async {
      const fileName = 'test_crud.json';
      final testData = [
        {'id': 1, 'name': 'Item 1'},
        {'id': 2, 'name': 'Item 2'},
      ];

      await storageService.writeJsonList(fileName, testData);

      final readBack = await storageService.readJsonList(fileName);
      expect(readBack.length, 2);
      expect(readBack[0]['name'], 'Item 1');
      expect(readBack[1]['name'], 'Item 2');

      final raw = await storageService.readRawString(fileName);
      expect(raw, contains('Item 1'));
    });

    test('resetFile restores default data', () async {
      const fileName = 'test_reset.json';
      await storageService.writeJsonList(fileName, [
        {'id': 99, 'name': 'Modified'}
      ]);

      await storageService.resetFile(fileName, [
        {'id': 1, 'name': 'Default'}
      ]);

      final readBack = await storageService.readJsonList(fileName);
      expect(readBack.length, 1);
      expect(readBack.first['name'], 'Default');
    });
  });
}
