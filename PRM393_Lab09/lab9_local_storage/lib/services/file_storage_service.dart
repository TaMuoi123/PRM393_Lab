import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service to handle reading and writing JSON files to device local storage
class FileStorageService {
  final Map<String, String> _inMemoryFallback = {};
  final String? customDirectoryPath;
  final bool inMemory;

  FileStorageService({
    this.customDirectoryPath,
    this.inMemory = false,
  });

  /// Get the directory path for application documents
  Future<String> get localPath async {
    if (inMemory) {
      return 'in_memory_storage';
    }
    if (customDirectoryPath != null) {
      return customDirectoryPath!;
    }
    if (kIsWeb) {
      return 'web_in_memory_storage';
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      // Fallback for tests or unsupported environments
      return Directory.systemTemp.path;
    }
  }

  /// Get a reference to the local file
  Future<File?> getLocalFile(String fileName) async {
    if (inMemory || kIsWeb) return null;
    try {
      final path = await localPath;
      return File('$path/$fileName');
    } catch (_) {
      return null;
    }
  }

  /// Returns the full file path string for display
  Future<String> getFullPath(String fileName) async {
    final path = await localPath;
    return '$path/$fileName';
  }

  /// Reads a JSON file and parses it as `List<Map<String, dynamic>>`
  /// If file doesn't exist, it initializes it with [defaultData]
  Future<List<Map<String, dynamic>>> readJsonList(
    String fileName, {
    List<Map<String, dynamic>> defaultData = const [],
  }) async {
    try {
      if (inMemory || kIsWeb) {
        if (!_inMemoryFallback.containsKey(fileName)) {
          final defaultJson = jsonEncode(defaultData);
          _inMemoryFallback[fileName] = defaultJson;
          return List<Map<String, dynamic>>.from(defaultData);
        }
        final content = _inMemoryFallback[fileName]!;
        final decoded = jsonDecode(content) as List<dynamic>;
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      final file = await getLocalFile(fileName);
      if (file == null) {
        return List<Map<String, dynamic>>.from(defaultData);
      }

      if (!await file.exists()) {
        // Initialize file with default data if provided
        await writeJsonList(fileName, defaultData);
        return List<Map<String, dynamic>>.from(defaultData);
      }

      final contents = await file.readAsString();
      if (contents.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(contents) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Error reading $fileName: $e');
      return List<Map<String, dynamic>>.from(defaultData);
    }
  }

  /// Writes a list of maps to the local JSON file with indentation
  Future<void> writeJsonList(
    String fileName,
    List<Map<String, dynamic>> data,
  ) async {
    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(data);

    if (inMemory || kIsWeb) {
      _inMemoryFallback[fileName] = jsonString;
      return;
    }

    try {
      final file = await getLocalFile(fileName);
      if (file != null) {
        // Ensure parent directory exists
        final parent = file.parent;
        if (!await parent.exists()) {
          await parent.create(recursive: true);
        }
        await file.writeAsString(jsonString, flush: true);
      }
    } catch (e) {
      // In-memory fallback if file system write fails
      _inMemoryFallback[fileName] = jsonString;
      debugPrint('Error writing to file, using in-memory: $e');
    }
  }

  /// Reads the raw JSON string from the file
  Future<String> readRawString(String fileName) async {
    if (inMemory || kIsWeb || _inMemoryFallback.containsKey(fileName)) {
      return _inMemoryFallback[fileName] ?? '[]';
    }
    try {
      final file = await getLocalFile(fileName);
      if (file != null && await file.exists()) {
        return await file.readAsString();
      }
      return 'File does not exist yet.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Resets file content back to default
  Future<void> resetFile(
    String fileName,
    List<Map<String, dynamic>> defaultData,
  ) async {
    await writeJsonList(fileName, defaultData);
  }
}
