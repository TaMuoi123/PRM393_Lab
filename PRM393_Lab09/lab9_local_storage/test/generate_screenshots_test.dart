import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab9_local_storage/models/product.dart';
import 'package:lab9_local_storage/screens/lab9_1_assets_screen.dart';
import 'package:lab9_local_storage/screens/lab9_2_storage_screen.dart';
import 'package:lab9_local_storage/screens/lab9_3_crud_screen.dart';
import 'package:lab9_local_storage/services/asset_json_service.dart';
import 'package:lab9_local_storage/services/file_storage_service.dart';

class MockAssetService extends AssetJsonService {
  @override
  Future<List<Product>> loadProducts() async {
    return [
      const Product(
        id: 1,
        name: 'MacBook Pro M3 Max',
        category: 'Laptops',
        price: 3199.99,
        description: '16-inch Liquid Retina XDR display, 36GB unified memory, 1TB SSD storage.',
        rating: 4.9,
        inStock: true,
      ),
      const Product(
        id: 2,
        name: 'Sony WH-1000XM5',
        category: 'Audio',
        price: 398.00,
        description: 'Industry-leading noise canceling wireless headphones with Auto NC Optimizer.',
        rating: 4.7,
        inStock: true,
      ),
      const Product(
        id: 3,
        name: 'Dell UltraSharp 27 4K',
        category: 'Monitors',
        price: 579.50,
        description: 'U2723QE 4K UHD IPS Black monitor with 98% DCI-P3 color gamut and USB-C hub.',
        rating: 4.8,
        inStock: false,
      ),
      const Product(
        id: 4,
        name: 'Keychron Q1 Pro Wireless',
        category: 'Keyboards',
        price: 199.00,
        description: '75% QMK/VIA custom mechanical keyboard with CNC aluminum body and hot-swap switches.',
        rating: 4.6,
        inStock: true,
      ),
    ];
  }

  @override
  Future<String> loadRawString() async {
    return '[\n  {\n    "id": 1,\n    "name": "MacBook Pro M3 Max"\n  }\n]';
  }
}

Future<void> saveBoundary(WidgetTester tester, GlobalKey repaintKey, String fileName) async {
  await tester.runAsync(() async {
    final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    const rootDir = 'D:/PRM393_Lab/PRM393_Lab09/screenshots';
    const projDir = 'D:/PRM393_Lab/PRM393_Lab09/lab9_local_storage/screenshots';

    File('$rootDir/$fileName')
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(bytes);

    File('$projDir/$fileName')
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(bytes);
  });
}

void main() {
  testWidgets('Capture 1: Lab 9.1 Assets Loaded', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
          home: Lab91AssetsScreen(service: MockAssetService()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await saveBoundary(tester, key, 'lab9_1_assets_loaded.png');
  });

  testWidgets('Capture 2: Lab 9.2 Local Storage Persistence', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final key = GlobalKey();
    final storage = FileStorageService(inMemory: true);
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
          home: Lab92StorageScreen(storageService: storage),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await saveBoundary(tester, key, 'lab9_2_storage_persistence.png');
  });

  testWidgets('Capture 3: Lab 9.3 CRUD Database', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final key = GlobalKey();
    final storage = FileStorageService(inMemory: true);
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
          home: Lab93CrudScreen(storageService: storage),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await saveBoundary(tester, key, 'lab9_3_crud_database.png');
  });

  testWidgets('Capture 4: Lab 9.3 Search Filtered', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final key = GlobalKey();
    final storage = FileStorageService(inMemory: true);
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
          home: Lab93CrudScreen(storageService: storage),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final searchField = find.widgetWithText(TextField, 'Search by name, student code, major, email...');
    await tester.enterText(searchField, 'Tran Thi Bich');
    await tester.pump(const Duration(milliseconds: 100));

    await saveBoundary(tester, key, 'lab9_3_search_filter.png');
  });

  testWidgets('Capture 5: Lab 9.3 Add Student Dialog', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final key = GlobalKey();
    final storage = FileStorageService(inMemory: true);
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
          home: Lab93CrudScreen(storageService: storage),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Add Student'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await saveBoundary(tester, key, 'lab9_3_add_dialog.png');
  });
}
