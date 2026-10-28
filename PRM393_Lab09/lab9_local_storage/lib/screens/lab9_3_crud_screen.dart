import 'package:flutter/material.dart';
import '../models/student_item.dart';
import '../services/file_storage_service.dart';

class Lab93CrudScreen extends StatefulWidget {
  final FileStorageService? storageService;

  const Lab93CrudScreen({super.key, this.storageService});

  @override
  State<Lab93CrudScreen> createState() => _Lab93CrudScreenState();
}

class _Lab93CrudScreenState extends State<Lab93CrudScreen> {
  static const String _fileName = 'students_database.json';

  static final List<Map<String, dynamic>> _defaultStudents = [
    {
      'id': 1,
      'studentCode': 'SE1946-JV',
      'fullName': 'Ta Tuong Muoi',
      'major': 'Software Engineering',
      'gpa': 3.85,
      'email': 'muoitthe182380@fpt.edu.vn',
      'phone': '0901234567',
    },
    {
      'id': 2,
      'studentCode': 'SE1946-JV',
      'fullName': 'Le Hoai Nam',
      'major': 'Artificial Intelligence',
      'gpa': 3.92,
      'email': 'namlhhe181671@fpt.edu.vn',
      'phone': '0912345678',
    },
    {
      'id': 3,
      'studentCode': 'SE1946-JV',
      'fullName': 'Le Hoang Cuong',
      'major': 'Information Assurance',
      'gpa': 3.65,
      'email': 'cuonglhse160105@fpt.edu.vn',
      'phone': '0923456789',
    },
    {
      'id': 4,
      'studentCode': 'SE1946-JV',
      'fullName': 'Pham Minh Duc',
      'major': 'Software Engineering',
      'gpa': 3.40,
      'email': 'ducpmse160210@fpt.edu.vn',
      'phone': '0934567890',
    },
    {
      'id': 5,
      'studentCode': 'SE1946-JV',
      'fullName': 'Vo Thi Mai',
      'major': 'Information Systems',
      'gpa': 3.78,
      'email': 'maivtse160350@fpt.edu.vn',
      'phone': '0945678901',
    },
  ];

  late final FileStorageService _storage;
  List<StudentItem> _students = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedMajorFilter = 'All';
  String _dbPath = '';

  final List<String> _majorsList = [
    'All',
    'Software Engineering',
    'Artificial Intelligence',
    'Information Assurance',
    'Information Systems',
  ];

  @override
  void initState() {
    super.initState();
    _storage = widget.storageService ?? FileStorageService();
    _loadDatabase();
  }

  Future<void> _loadDatabase() async {
    setState(() => _isLoading = true);
    final path = await _storage.getFullPath(_fileName);
    final rawList = await _storage.readJsonList(
      _fileName,
      defaultData: _defaultStudents,
    );

    final list = rawList.map((e) => StudentItem.fromJson(e)).toList();

    setState(() {
      _students = list;
      _dbPath = path;
      _isLoading = false;
    });
  }

  // Step 4: Auto-Save JSON after every CRUD action
  Future<void> _autoSaveDatabase() async {
    final raw = _students.map((e) => e.toJson()).toList();
    await _storage.writeJsonList(_fileName, raw);
  }

  // Step 3: Add / Edit / Delete
  void _openStudentDialog({StudentItem? existing}) {
    final isEditing = existing != null;
    final codeCtrl = TextEditingController(text: existing?.studentCode ?? '');
    final nameCtrl = TextEditingController(text: existing?.fullName ?? '');
    final gpaCtrl = TextEditingController(
      text: existing != null ? existing.gpa.toString() : '3.50',
    );
    final emailCtrl = TextEditingController(text: existing?.email ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    String selectedMajor = existing?.major ?? 'Software Engineering';

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.person_add,
                    color: Colors.indigo,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(isEditing ? 'Edit Student' : 'Add New Student'),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: codeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Student Code *',
                            hintText: 'e.g. SE160999',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (val) =>
                              val == null || val.trim().isEmpty
                                  ? 'Code is required'
                                  : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Full Name *',
                            hintText: 'e.g. Nguyen Van B',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) =>
                              val == null || val.trim().isEmpty
                                  ? 'Name is required'
                                  : null,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: selectedMajor,
                          decoration: const InputDecoration(
                            labelText: 'Major *',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                          items: _majorsList
                              .where((m) => m != 'All')
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedMajor = val);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: gpaCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'GPA (0.00 - 4.00) *',
                            hintText: '3.80',
                            prefixIcon: Icon(Icons.grade_outlined),
                          ),
                          validator: (val) {
                            final g = double.tryParse(val ?? '');
                            if (g == null || g < 0 || g > 4.0) {
                              return 'Enter valid GPA (0 - 4.0)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'student@fpt.edu.vn',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            hintText: '0901234567',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final gpaVal = double.tryParse(gpaCtrl.text.trim()) ?? 0.0;

                    if (isEditing) {
                      // Update existing
                      final updated = existing.copyWith(
                        studentCode: codeCtrl.text.trim(),
                        fullName: nameCtrl.text.trim(),
                        major: selectedMajor,
                        gpa: gpaVal,
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                      );
                      final index =
                          _students.indexWhere((s) => s.id == existing.id);
                      if (index != -1) {
                        setState(() {
                          _students[index] = updated;
                        });
                        await _autoSaveDatabase();
                      }
                    } else {
                      // Create new with incremental ID
                      final nextId = _students.isEmpty
                          ? 1
                          : (_students.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1);

                      final newStudent = StudentItem(
                        id: nextId,
                        studentCode: codeCtrl.text.trim(),
                        fullName: nameCtrl.text.trim(),
                        major: selectedMajor,
                        gpa: gpaVal,
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                      );

                      setState(() {
                        _students.insert(0, newStudent);
                      });
                      await _autoSaveDatabase();
                    }

                    if (context.mounted) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Updated and auto-saved "${nameCtrl.text}"!'
                                : 'Created and auto-saved "${nameCtrl.text}"!',
                          ),
                          backgroundColor: Colors.green.shade700,
                        ),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Create Student'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Delete with confirmation dialog
  void _confirmDelete(StudentItem student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirm Deletion'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${student.fullName} (${student.studentCode}) from the JSON database? This change will be auto-saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() {
                _students.removeWhere((s) => s.id == student.id);
              });
              await _autoSaveDatabase();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Deleted ${student.fullName} and updated database.'),
                    backgroundColor: Colors.black87,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _viewRawDatabaseJson() async {
    final rawJson = await _storage.readRawString(_fileName);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.storage_rounded, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Local JSON Database Content'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              rawJson,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _resetToDefault() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Database?'),
        content: const Text(
          'This will overwrite local database file with the initial sample students.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _storage.resetFile(_fileName, _defaultStudents);
              await _loadDatabase();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database reset to default seed data.')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filtered = _students.where((s) {
      if (_selectedMajorFilter != 'All' && s.major != _selectedMajorFilter) {
        return false;
      }
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return s.fullName.toLowerCase().contains(q) ||
          s.studentCode.toLowerCase().contains(q) ||
          s.major.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 9.3: JSON CRUD Database'),
        actions: [
          IconButton(
            tooltip: 'Inspect JSON Database',
            icon: const Icon(Icons.code),
            onPressed: _viewRawDatabaseJson,
          ),
          IconButton(
            tooltip: 'Reset to Default',
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetToDefault,
          ),
          IconButton(
            tooltip: 'Reload Database',
            icon: const Icon(Icons.refresh),
            onPressed: _loadDatabase,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openStudentDialog(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Database info bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  color: Colors.indigo.shade50,
                  child: Row(
                    children: [
                      const Icon(Icons.auto_mode, color: Colors.indigo, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto-Save Active • Stored at $_fileName (${_students.length} records)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.indigo.shade900,
                              ),
                            ),
                            Text(
                              'Path: $_dbPath',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _viewRawDatabaseJson,
                        child: const Text('Inspect DB', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),

                // Step 2: Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by name, student code, major, email...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  ),
                ),

                // Filter chips by major
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _majorsList.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final major = _majorsList[idx];
                      final isSelected = _selectedMajorFilter == major;
                      return ChoiceChip(
                        label: Text(
                          major,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedMajorFilter = major);
                          }
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 4),

                // Items list
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search_off, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isNotEmpty || _selectedMajorFilter != 'All'
                                    ? 'No students found matching your filters.'
                                    : 'Database is empty. Click "+ Add Student" to create one!',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadDatabase,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final student = filtered[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.indigo.shade100,
                                            child: Text(
                                              student.studentCode.isNotEmpty
                                                  ? student.studentCode.substring(
                                                      student.studentCode.length >= 2
                                                          ? student.studentCode.length - 2
                                                          : 0,
                                                    )
                                                  : '${student.id}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.indigo.shade900,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  student.fullName,
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  student.studentCode,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade700,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // GPA Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: student.gpa >= 3.6
                                                  ? Colors.green.shade100
                                                  : Colors.amber.shade100,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 14,
                                                  color: student.gpa >= 3.6
                                                      ? Colors.green.shade800
                                                      : Colors.amber.shade900,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  student.gpa.toStringAsFixed(2),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: student.gpa >= 3.6
                                                      ? Colors.green.shade900
                                                      : Colors.amber.shade900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.indigo.shade50,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              student.major,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.indigo.shade800,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              student.email,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 16),
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        runSpacing: 4,
                                        children: [
                                          if (student.phone.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: Text(
                                                '📞 ${student.phone}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Edit Button
                                              OutlinedButton.icon(
                                                onPressed: () => _openStudentDialog(existing: student),
                                                icon: const Icon(Icons.edit, size: 14),
                                                label: const Text('Edit'),
                                                style: OutlinedButton.styleFrom(
                                                  visualDensity: VisualDensity.compact,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Delete Button
                                              OutlinedButton.icon(
                                                onPressed: () => _confirmDelete(student),
                                                icon: const Icon(Icons.delete_outline, size: 14),
                                                label: const Text('Delete'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.red,
                                                  visualDensity: VisualDensity.compact,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
