import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/note.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();
  
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _categoryController.text = widget.note!.category ?? '';
      _tagsController.text = widget.note!.tags?.join(', ') ?? '';
      _isFavorite = widget.note!.isFavorite;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
          ),
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNote,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter note title',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Content
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content *',
                hintText: 'Enter note content',
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Category
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'Enter category (optional)',
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'Enter tags separated by commas',
                helperText: 'Example: work, important, ideas',
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Favorite toggle
            Card(
              child: SwitchListTile(
                title: const Text('Mark as Favorite'),
                subtitle: const Text('Add this note to your favorites'),
                value: _isFavorite,
                onChanged: (value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
                secondary: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : null,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            FilledButton(
              onPressed: _isLoading ? null : _saveNote,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.note == null ? 'Add Note' : 'Update Note'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      
      // Parse tags
      List<String>? tags;
      if (_tagsController.text.trim().isNotEmpty) {
        tags = _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
      }

      final note = Note(
        id: widget.note?.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: widget.note?.createdAt ?? now,
        updatedAt: now,
        category: _categoryController.text.trim().isEmpty 
            ? null 
            : _categoryController.text.trim(),
        tags: tags,
        isFavorite: _isFavorite,
      );

      if (widget.note == null) {
        await context.read<NotesProvider>().addNote(note);
      } else {
        await context.read<NotesProvider>().updateNote(note);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.note == null 
                ? 'Note added successfully' 
                : 'Note updated successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.note != null) {
      try {
        await context.read<NotesProvider>().deleteNote(widget.note!.id!);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting note: \$e')),
          );
        }
      }
    }
  }
}
