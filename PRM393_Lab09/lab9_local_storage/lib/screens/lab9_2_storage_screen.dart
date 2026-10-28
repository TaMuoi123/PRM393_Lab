import 'package:flutter/material.dart';
import '../models/note_item.dart';
import '../services/file_storage_service.dart';

class Lab92StorageScreen extends StatefulWidget {
  final FileStorageService? storageService;

  const Lab92StorageScreen({super.key, this.storageService});

  @override
  State<Lab92StorageScreen> createState() => _Lab92StorageScreenState();
}

class _Lab92StorageScreenState extends State<Lab92StorageScreen> {
  static const String _fileName = 'local_notes.json';

  static final List<Map<String, dynamic>> _initialNotes = [
    {
      'id': 1,
      'title': 'Module 9 Lab Preparation',
      'content': 'Study rootBundle.loadString() and path_provider for persistence.',
      'timestamp': '2026-10-21 08:30',
    },
    {
      'id': 2,
      'title': 'Local Storage Testing',
      'content': 'Use getApplicationDocumentsDirectory() to store persistent JSON.',
      'timestamp': '2026-10-21 09:15',
    },
  ];

  late final FileStorageService _storage;
  List<NoteItem> _notes = [];
  bool _isLoading = true;
  String _filePath = '';
  bool _hasUnsavedChanges = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _storage = widget.storageService ?? FileStorageService();
    // Step 3: Load Data at Startup during initState
    _loadDataFromStorage();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadDataFromStorage() async {
    setState(() => _isLoading = true);
    final path = await _storage.getFullPath(_fileName);
    final rawList = await _storage.readJsonList(
      _fileName,
      defaultData: _initialNotes,
    );

    final parsedNotes = rawList.map((e) => NoteItem.fromJson(e)).toList();

    setState(() {
      _notes = parsedNotes;
      _filePath = path;
      _isLoading = false;
      _hasUnsavedChanges = false;
    });
  }

  // Step 4: UI for Adding Items
  void _addItem() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a note title!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final formattedTime =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final nextId = _notes.isEmpty
        ? 1
        : (_notes.map((n) => n.id).reduce((a, b) => a > b ? a : b) + 1);

    final newNote = NoteItem(
      id: nextId,
      title: title,
      content: content.isEmpty ? 'No description' : content,
      timestamp: formattedTime,
    );

    setState(() {
      _notes.insert(0, newNote);
      _hasUnsavedChanges = true;
    });

    _titleController.clear();
    _contentController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${newNote.title}" to memory list. Press SAVE to persist.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Step 5: Save Button writes list to JSON file and shows confirmation message
  Future<void> _saveToStorage() async {
    try {
      final jsonList = _notes.map((n) => n.toJson()).toList();
      await _storage.writeJsonList(_fileName, jsonList);

      setState(() {
        _hasUnsavedChanges = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Successfully persisted ${_notes.length} notes to $_fileName!'),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save notes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeItem(int id) {
    setState(() {
      _notes.removeWhere((item) => item.id == id);
      _hasUnsavedChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from in-memory list. Remember to Save!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewRawJson() async {
    final rawJson = await _storage.readRawString(_fileName);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.storage, color: Colors.teal),
            SizedBox(width: 8),
            Text('Saved JSON File'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 9.2: Local Storage Persistence'),
        actions: [
          IconButton(
            tooltip: 'View Stored JSON File',
            icon: const Icon(Icons.description),
            onPressed: _viewRawJson,
          ),
          IconButton(
            tooltip: 'Reload from Storage',
            icon: const Icon(Icons.refresh),
            onPressed: _loadDataFromStorage,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // File Path and Status Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: _hasUnsavedChanges
                      ? Colors.amber.shade100
                      : Colors.teal.shade50,
                  child: Row(
                    children: [
                      Icon(
                        _hasUnsavedChanges
                            ? Icons.warning_amber
                            : Icons.check_circle_outline,
                        color: _hasUnsavedChanges
                            ? Colors.amber.shade900
                            : Colors.teal.shade800,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _hasUnsavedChanges
                                  ? 'Unsaved changes pending save to disk!'
                                  : 'Synced with device local storage.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _hasUnsavedChanges
                                    ? Colors.amber.shade900
                                    : Colors.teal.shade900,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'File: $_filePath',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Form to add items (Step 4)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.note_add, color: Colors.teal),
                              const SizedBox(width: 8),
                              Text(
                                'Add New Note / Item',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Note Title *',
                              hintText: 'e.g. Flutter JSON Storage',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _contentController,
                            decoration: const InputDecoration(
                              labelText: 'Content / Details',
                              hintText: 'e.g. Implement path_provider helpers',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _addItem,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('Add to List'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Step 5: Save Button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _saveToStorage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  icon: const Icon(Icons.save, size: 18),
                                  label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text('Save to Storage'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // List Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Stored Notes (${_notes.length})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _saveToStorage,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text('Persist Now'),
                      ),
                    ],
                  ),
                ),

                // Show List
                Expanded(
                  child: _notes.isEmpty
                      ? const Center(
                          child: Text('No notes stored. Add your first note above!'),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadDataFromStorage,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _notes.length,
                            itemBuilder: (context, index) {
                              final item = _notes[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.teal.shade100,
                                    foregroundColor: Colors.teal.shade900,
                                    child: Text('${item.id}'),
                                  ),
                                  title: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(item.content),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Saved: ${item.timestamp}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    tooltip: 'Delete item',
                                    onPressed: () => _removeItem(item.id),
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
