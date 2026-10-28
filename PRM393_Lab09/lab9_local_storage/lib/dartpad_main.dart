import 'dart:convert';
import 'package:flutter/material.dart';

// ============================================================================
// PRM393 - LAB 9: WORKING WITH LOCAL JSON STORAGE
// All-in-One Standalone File for DartPad (https://dartpad.dev)
// ============================================================================

void main() {
  runApp(const DartPadApp());
}

// ----------------------------------------------------------------------------
// 1. DATA MODELS
// ----------------------------------------------------------------------------
class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String description;
  final double rating;
  final bool inStock;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.rating,
    required this.inStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      inStock: json['inStock'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'description': description,
    'rating': rating,
    'inStock': inStock,
  };
}

class NoteItem {
  final int id;
  final String title;
  final String content;
  final String timestamp;

  const NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'timestamp': timestamp,
  };
}

class StudentItem {
  final int id;
  final String studentCode;
  final String fullName;
  final String major;
  final double gpa;
  final String email;
  final String phone;

  const StudentItem({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.major,
    required this.gpa,
    required this.email,
    required this.phone,
  });

  factory StudentItem.fromJson(Map<String, dynamic> json) {
    return StudentItem(
      id: json['id'] as int? ?? 0,
      studentCode: json['studentCode'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      major: json['major'] as String? ?? 'General',
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0.0,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentCode': studentCode,
    'fullName': fullName,
    'major': major,
    'gpa': gpa,
    'email': email,
    'phone': phone,
  };

  StudentItem copyWith({
    int? id,
    String? studentCode,
    String? fullName,
    String? major,
    double? gpa,
    String? email,
    String? phone,
  }) {
    return StudentItem(
      id: id ?? this.id,
      studentCode: studentCode ?? this.studentCode,
      fullName: fullName ?? this.fullName,
      major: major ?? this.major,
      gpa: gpa ?? this.gpa,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }
}

// ----------------------------------------------------------------------------
// 2. MOCK PERSISTENCE STORAGE (Web/DartPad compatible)
// ----------------------------------------------------------------------------
class MockStorageService {
  static final Map<String, String> _files = {
    'products_asset.json': '''
[
  {
    "id": 1,
    "name": "MacBook Pro M3 Max",
    "category": "Laptops",
    "price": 3199.99,
    "description": "16-inch Liquid Retina XDR display, 36GB memory, 1TB SSD.",
    "rating": 4.9,
    "inStock": true
  },
  {
    "id": 2,
    "name": "Sony WH-1000XM5",
    "category": "Audio",
    "price": 398.00,
    "description": "Noise canceling headphones with Auto NC Optimizer.",
    "rating": 4.7,
    "inStock": true
  },
  {
    "id": 3,
    "name": "Dell UltraSharp 27 4K",
    "category": "Monitors",
    "price": 579.50,
    "description": "4K UHD IPS Black monitor with 98% DCI-P3 color gamut.",
    "rating": 4.8,
    "inStock": false
  },
  {
    "id": 4,
    "name": "Keychron Q1 Pro Wireless",
    "category": "Keyboards",
    "price": 199.00,
    "description": "Custom mechanical keyboard with CNC aluminum body.",
    "rating": 4.6,
    "inStock": true
  }
]
''',
    'local_notes.json': '''
[
  {
    "id": 1,
    "title": "Module 9 Lab Preparation",
    "content": "Study rootBundle and path_provider for persistence.",
    "timestamp": "2026-10-21 08:30"
  },
  {
    "id": 2,
    "title": "DartPad JSON Storage",
    "content": "Emulating document directory persistence in browser.",
    "timestamp": "2026-10-21 09:15"
  }
]
''',
    'students_database.json': '''
[
  {
    "id": 1,
    "studentCode": "SE160001",
    "fullName": "Nguyen Van An",
    "major": "Software Engineering",
    "gpa": 3.85,
    "email": "annvse160001@fpt.edu.vn",
    "phone": "0901234567"
  },
  {
    "id": 2,
    "studentCode": "SE160042",
    "fullName": "Tran Thi Bich",
    "major": "Artificial Intelligence",
    "gpa": 3.92,
    "email": "bicttse160042@fpt.edu.vn",
    "phone": "0912345678"
  },
  {
    "id": 3,
    "studentCode": "SE160105",
    "fullName": "Le Hoang Cuong",
    "major": "Information Assurance",
    "gpa": 3.65,
    "email": "cuonglhse160105@fpt.edu.vn",
    "phone": "0923456789"
  }
]
'''
  };

  static Future<String> readRawString(String fileName) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _files[fileName] ?? '[]';
  }

  static Future<List<Map<String, dynamic>>> readJsonList(String fileName) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final str = _files[fileName] ?? '[]';
    final List<dynamic> list = jsonDecode(str);
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> writeJsonList(String fileName, List<Map<String, dynamic>> data) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _files[fileName] = const JsonEncoder.withIndent('  ').convert(data);
  }
}

// ----------------------------------------------------------------------------
// 3. MAIN DARTPAD APP
// ----------------------------------------------------------------------------
class DartPadApp extends StatelessWidget {
  const DartPadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 9 - DartPad Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const DartPadHomeScreen(),
    );
  }
}

class DartPadHomeScreen extends StatefulWidget {
  const DartPadHomeScreen({super.key});

  @override
  State<DartPadHomeScreen> createState() => _DartPadHomeScreenState();
}

class _DartPadHomeScreenState extends State<DartPadHomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DartPadLab91Screen(),
    DartPadLab92Screen(),
    DartPadLab93Screen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_open),
            label: 'Lab 9.1 Assets',
          ),
          NavigationDestination(
            icon: Icon(Icons.save),
            label: 'Lab 9.2 Storage',
          ),
          NavigationDestination(
            icon: Icon(Icons.dataset),
            label: 'Lab 9.3 CRUD',
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// SCREEN 1: LAB 9.1 (READ ASSETS JSON)
// ----------------------------------------------------------------------------
class DartPadLab91Screen extends StatefulWidget {
  const DartPadLab91Screen({super.key});

  @override
  State<DartPadLab91Screen> createState() => _DartPadLab91ScreenState();
}

class _DartPadLab91ScreenState extends State<DartPadLab91Screen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssetJson();
  }

  Future<void> _loadAssetJson() async {
    setState(() => _isLoading = true);
    final raw = await MockStorageService.readJsonList('products_asset.json');
    setState(() {
      _products = raw.map((e) => Product.fromJson(e)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 9.1: Read JSON Assets (DartPad)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAssetJson,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _products.length,
              itemBuilder: (ctx, i) {
                final p = _products[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${p.id}')),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${p.category} • ${p.description}'),
                    trailing: Text(
                      '\$${p.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ----------------------------------------------------------------------------
// SCREEN 2: LAB 9.2 (SAVE & LOAD LOCAL STORAGE)
// ----------------------------------------------------------------------------
class DartPadLab92Screen extends StatefulWidget {
  const DartPadLab92Screen({super.key});

  @override
  State<DartPadLab92Screen> createState() => _DartPadLab92ScreenState();
}

class _DartPadLab92ScreenState extends State<DartPadLab92Screen> {
  List<NoteItem> _notes = [];
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final raw = await MockStorageService.readJsonList('local_notes.json');
    setState(() {
      _notes = raw.map((e) => NoteItem.fromJson(e)).toList();
    });
  }

  void _addNote() {
    if (_titleController.text.trim().isEmpty) return;
    final nextId = _notes.isEmpty ? 1 : (_notes.map((n) => n.id).reduce((a, b) => a > b ? a : b) + 1);
    final note = NoteItem(
      id: nextId,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      timestamp: DateTime.now().toString().substring(0, 16),
    );
    setState(() {
      _notes.insert(0, note);
    });
    _titleController.clear();
    _contentController.clear();
  }

  Future<void> _saveNotes() async {
    await MockStorageService.writeJsonList('local_notes.json', _notes.map((e) => e.toJson()).toList());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notes saved to local storage!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 9.2: Save & Load (DartPad)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadNotes),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
                    TextField(controller: _contentController, decoration: const InputDecoration(labelText: 'Content')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addNote,
                            icon: const Icon(Icons.add),
                            label: const Text('Add to List'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                            onPressed: _saveNotes,
                            icon: const Icon(Icons.save),
                            label: const Text('Save to Storage'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (ctx, i) {
                final note = _notes[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${note.id}')),
                  title: Text(note.title),
                  subtitle: Text(note.content),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => _notes.removeAt(i)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// SCREEN 3: LAB 9.3 (CRUD MINI DATABASE + SEARCH)
// ----------------------------------------------------------------------------
class DartPadLab93Screen extends StatefulWidget {
  const DartPadLab93Screen({super.key});

  @override
  State<DartPadLab93Screen> createState() => _DartPadLab93ScreenState();
}

class _DartPadLab93ScreenState extends State<DartPadLab93Screen> {
  List<StudentItem> _students = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDatabase();
  }

  Future<void> _loadDatabase() async {
    final raw = await MockStorageService.readJsonList('students_database.json');
    setState(() {
      _students = raw.map((e) => StudentItem.fromJson(e)).toList();
    });
  }

  Future<void> _autoSave() async {
    await MockStorageService.writeJsonList('students_database.json', _students.map((e) => e.toJson()).toList());
  }

  void _addOrEditStudent({StudentItem? existing}) {
    final codeCtrl = TextEditingController(text: existing?.studentCode ?? '');
    final nameCtrl = TextEditingController(text: existing?.fullName ?? '');
    final gpaCtrl = TextEditingController(text: existing?.gpa.toString() ?? '3.50');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Student' : 'Edit Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code')),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: gpaCtrl, decoration: const InputDecoration(labelText: 'GPA')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (existing != null) {
                final idx = _students.indexWhere((s) => s.id == existing.id);
                if (idx != -1) {
                  setState(() {
                    _students[idx] = existing.copyWith(
                      studentCode: codeCtrl.text,
                      fullName: nameCtrl.text,
                      gpa: double.tryParse(gpaCtrl.text) ?? 3.0,
                    );
                  });
                }
              } else {
                final nextId = _students.isEmpty ? 1 : (_students.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1);
                setState(() {
                  _students.insert(
                    0,
                    StudentItem(
                      id: nextId,
                      studentCode: codeCtrl.text,
                      fullName: nameCtrl.text,
                      major: 'Software Engineering',
                      gpa: double.tryParse(gpaCtrl.text) ?? 3.0,
                      email: '${codeCtrl.text.toLowerCase()}@fpt.edu.vn',
                      phone: '0901234567',
                    ),
                  );
                });
              }
              await _autoSave();
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(StudentItem s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${s.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              setState(() => _students.removeWhere((item) => item.id == s.id));
              await _autoSave();
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _students.where((s) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.fullName.toLowerCase().contains(q) || s.studentCode.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 9.3: Mini JSON DB (DartPad)'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditStudent(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search student...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final s = filtered[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${s.id}')),
                    title: Text(s.fullName),
                    subtitle: Text('${s.studentCode} • GPA: ${s.gpa}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _addOrEditStudent(existing: s),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteStudent(s),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
