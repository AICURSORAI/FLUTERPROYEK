import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/theme_provider.dart';
import 'todo_screen.dart';
import 'notes_screen.dart';
import 'settings_screen.dart';
import 'add_edit_todo_screen.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
      context.read<NotesProvider>().loadNotes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Notes App'),
        actions: [
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              return Consumer<NotesProvider>(
                builder: (context, notesProvider, child) {
                  return IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _showSearchDialog(context),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Consumer<TodoProvider>(
              builder: (context, provider, child) {
                return Tab(
                  icon: const Icon(Icons.check_box),
                  text: 'Todos (${provider.pendingCount})',
                );
              },
            ),
            Consumer<NotesProvider>(
              builder: (context, provider, child) {
                return Tab(
                  icon: const Icon(Icons.note),
                  text: 'Notes (${provider.totalNotesCount})',
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TodoScreen(),
          NotesScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewItem(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNewItem(BuildContext context) {
    if (_currentIndex == 0) {
      // Add Todo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddEditTodoScreen(),
        ),
      );
    } else {
      // Add Note
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddEditNoteScreen(),
        ),
      );
    }
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search todos...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                context.read<TodoProvider>().searchTodos(query);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                context.read<NotesProvider>().searchNotes(query);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<TodoProvider>().searchTodos('');
              context.read<NotesProvider>().searchNotes('');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
