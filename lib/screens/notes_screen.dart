import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notes_provider.dart';
import '../models/note.dart';
import '../widgets/note_item.dart';
import 'add_edit_note_screen.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        return Column(
          children: [
            // Filter chips
            Container(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: NotesFilter.values.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FilterChip(
                        label: Text(_getFilterLabel(filter)),
                        selected: notesProvider.currentFilter == filter,
                        onSelected: (selected) {
                          if (selected) {
                            notesProvider.setFilter(filter);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // Statistics
            if (notesProvider.notes.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      'Total',
                      notesProvider.totalNotesCount.toString(),
                      Icons.note,
                      Colors.blue,
                    ),
                    _buildStatItem(
                      context,
                      'Favorites',
                      notesProvider.favoriteNotesCount.toString(),
                      Icons.favorite,
                      Colors.red,
                    ),
                    _buildStatItem(
                      context,
                      'Categories',
                      notesProvider.allCategories.length.toString(),
                      Icons.category,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Notes list
            Expanded(
              child: notesProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : notesProvider.notes.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: notesProvider.notes.length,
                          itemBuilder: (context, index) {
                            final note = notesProvider.notes[index];
                            return NoteItem(
                              note: note,
                              onTap: () => _editNote(context, note),
                              onFavorite: () => notesProvider.toggleNoteFavorite(note),
                              onDelete: () => _deleteNote(context, note),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first note',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _addNote(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Note'),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(NotesFilter filter) {
    switch (filter) {
      case NotesFilter.all:
        return 'All';
      case NotesFilter.favorites:
        return 'Favorites';
      case NotesFilter.category:
        return 'Categorized';
    }
  }

  void _addNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditNoteScreen(),
      ),
    );
  }

  void _editNote(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(note: note),
      ),
    );
  }

  void _deleteNote(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "\${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<NotesProvider>().deleteNote(note.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
