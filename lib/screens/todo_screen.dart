import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';
import 'add_edit_todo_screen.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return Column(
          children: [
            // Filter chips
            Container(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TodoFilter.values.map((filter) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FilterChip(
                        label: Text(_getFilterLabel(filter)),
                        selected: todoProvider.currentFilter == filter,
                        onSelected: (selected) {
                          if (selected) {
                            todoProvider.setFilter(filter);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // Statistics
            if (todoProvider.todos.isNotEmpty)
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
                      'Completed',
                      todoProvider.completedCount.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                    _buildStatItem(
                      context,
                      'Pending',
                      todoProvider.pendingCount.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                    _buildStatItem(
                      context,
                      'Overdue',
                      todoProvider.overdueCount.toString(),
                      Icons.warning,
                      Colors.red,
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 8),
            
            // Todo list
            Expanded(
              child: todoProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : todoProvider.todos.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: todoProvider.todos.length,
                          itemBuilder: (context, index) {
                            final todo = todoProvider.todos[index];
                            return TodoItem(
                              todo: todo,
                              onTap: () => _editTodo(context, todo),
                              onToggle: () => todoProvider.toggleTodoStatus(todo),
                              onDelete: () => _deleteTodo(context, todo),
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
            Icons.check_box_outline_blank,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No todos yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first todo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _addTodo(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Todo'),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return 'All';
      case TodoFilter.completed:
        return 'Completed';
      case TodoFilter.pending:
        return 'Pending';
      case TodoFilter.overdue:
        return 'Overdue';
      case TodoFilter.today:
        return 'Today';
    }
  }

  void _addTodo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditTodoScreen(),
      ),
    );
  }

  void _editTodo(BuildContext context, Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTodoScreen(todo: todo),
      ),
    );
  }

  void _deleteTodo(BuildContext context, Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "\${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TodoProvider>().deleteTodo(todo.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todo deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
