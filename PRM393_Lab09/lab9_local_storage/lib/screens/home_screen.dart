import 'package:flutter/material.dart';
import 'lab9_1_assets_screen.dart';
import 'lab9_2_storage_screen.dart';
import 'lab9_3_crud_screen.dart';
import '../services/file_storage_service.dart';

class HomeScreen extends StatefulWidget {
  final FileStorageService? storageService;

  const HomeScreen({super.key, this.storageService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const Lab91AssetsScreen(),
      Lab92StorageScreen(storageService: widget.storageService),
      Lab93CrudScreen(storageService: widget.storageService),
    ];
  }

  void _showLabOverviewDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.indigo),
            SizedBox(width: 8),
            Text('PRM393 - Lab 9 Overview'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Working With Local JSON Storage',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '• Lab 9.1 - Read Assets JSON:\n'
                '  Loads JSON from assets/data/products.json via rootBundle.loadString() and renders with ListView.\n\n'
                '• Lab 9.2 - Save & Load Device Storage:\n'
                '  Uses path_provider (getApplicationDocumentsDirectory) to persist notes across app restarts with manual & auto save.\n\n'
                '• Lab 9.3 - Local JSON CRUD + Search:\n'
                '  Full mini-database with Create, Read, Update, Delete with confirmation, real-time Search & Filter, and automatic disk sync.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder_open),
            label: 'Lab 9.1 Assets',
          ),
          NavigationDestination(
            icon: Icon(Icons.save_outlined),
            selectedIcon: Icon(Icons.save),
            label: 'Lab 9.2 Storage',
          ),
          NavigationDestination(
            icon: Icon(Icons.dataset_outlined),
            selectedIcon: Icon(Icons.dataset),
            label: 'Lab 9.3 CRUD',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.small(
              heroTag: 'info_button',
              onPressed: _showLabOverviewDialog,
              child: const Icon(Icons.help_outline),
            )
          : null,
    );
  }
}
