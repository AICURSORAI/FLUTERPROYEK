import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/todo.dart';
import '../models/note.dart';
import 'database_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final DatabaseService _databaseService = DatabaseService();

  Future<String> exportToJson() async {
    try {
      final todos = await _databaseService.getAllTodos();
      final notes = await _databaseService.getAllNotes();

      final backupData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'todos': todos.map((todo) => todo.toJson()).toList(),
        'notes': notes.map((note) => note.toJson()).toList(),
      };

      final jsonString = jsonEncode(backupData);
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('\${directory.path}/backup_\${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      
      return file.path;
    } catch (e) {
      throw Exception('Failed to export data: \$e');
    }
  }

  Future<void> importFromJson(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString);

      // Validate backup format
      if (!backupData.containsKey('todos') || !backupData.containsKey('notes')) {
        throw Exception('Invalid backup file format');
      }

      // Clear existing data (optional - you might want to merge instead)
      // await _clearAllData();

      // Import todos
      final todosData = backupData['todos'] as List;
      for (final todoData in todosData) {
        final todo = Todo.fromJson(todoData);
        // Create new todo without ID to avoid conflicts
        final newTodo = todo.copyWith(id: null);
        await _databaseService.insertTodo(newTodo);
      }

      // Import notes
      final notesData = backupData['notes'] as List;
      for (final noteData in notesData) {
        final note = Note.fromJson(noteData);
        // Create new note without ID to avoid conflicts
        final newNote = note.copyWith(id: null);
        await _databaseService.insertNote(newNote);
      }
    } catch (e) {
      throw Exception('Failed to import data: \$e');
    }
  }

  Future<void> _clearAllData() async {
    // Get all todos and notes
    final todos = await _databaseService.getAllTodos();
    final notes = await _databaseService.getAllNotes();

    // Delete all todos
    for (final todo in todos) {
      if (todo.id != null) {
        await _databaseService.deleteTodo(todo.id!);
      }
    }

    // Delete all notes
    for (final note in notes) {
      if (note.id != null) {
        await _databaseService.deleteNote(note.id!);
      }
    }
  }

  Future<List<String>> getBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync()
          .where((file) => file.path.contains('backup_') && file.path.endsWith('.json'))
          .map((file) => file.path)
          .toList();
      
      // Sort by creation date (newest first)
      files.sort((a, b) => b.compareTo(a));
      return files;
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete backup file: \$e');
    }
  }

  Future<Map<String, dynamic>> getBackupInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString);

      return {
        'version': backupData['version'] ?? 'Unknown',
        'exportDate': backupData['exportDate'] ?? 'Unknown',
        'todosCount': (backupData['todos'] as List?)?.length ?? 0,
        'notesCount': (backupData['notes'] as List?)?.length ?? 0,
        'fileSize': await file.length(),
      };
    } catch (e) {
      throw Exception('Failed to read backup info: \$e');
    }
  }
}
