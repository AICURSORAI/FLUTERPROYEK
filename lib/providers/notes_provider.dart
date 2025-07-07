import 'package:flutter/foundation.dart';

class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
}

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    
    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 500));
    
    _notes = [
      Note(
        id: 1,
        title: 'Welcome Note',
        content: 'This is your first note in the Todo Notes App!',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    notifyListeners();
  }

  Future<void> deleteNote(int id) async {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}
