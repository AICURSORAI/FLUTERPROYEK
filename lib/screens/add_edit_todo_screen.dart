import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo? todo;

  const AddEditTodoScreen({super.key, this.todo});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  int _priority = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description ?? '';
      _categoryController.text = widget.todo!.category ?? '';
      _dueDate = widget.todo!.dueDate;
      _dueTime = widget.todo!.dueDate != null 
          ? TimeOfDay.fromDateTime(widget.todo!.dueDate!)
          : null;
      _priority = widget.todo!.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Add Todo' : 'Edit Todo'),
        actions: [
          if (widget.todo != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTodo,
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
                hintText: 'Enter todo title',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter todo description',
              ),
              maxLines: 3,
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
            
            // Priority
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Priority',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 1,
                          label: Text('Low'),
                          icon: Icon(Icons.low_priority),
                        ),
                        ButtonSegment(
                          value: 2,
                          label: Text('Medium'),
                          icon: Icon(Icons.priority_high),
                        ),
                        ButtonSegment(
                          value: 3,
                          label: Text('High'),
                          icon: Icon(Icons.warning),
                        ),
                      ],
                      selected: {_priority},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          _priority = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Due Date
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due Date & Time',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _dueDate == null
                                  ? 'Select Date'
                                  : DateFormat('MMM dd, yyyy').format(_dueDate!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _dueDate == null ? null : _selectTime,
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _dueTime == null
                                  ? 'Select Time'
                                  : _dueTime!.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_dueDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _dueDate = null;
                                  _dueTime = null;
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            FilledButton(
              onPressed: _isLoading ? null : _saveTodo,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.todo == null ? 'Add Todo' : 'Update Todo'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        _dueTime = time;
      });
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      DateTime? finalDueDate;
      if (_dueDate != null) {
        finalDueDate = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime?.hour ?? 23,
          _dueTime?.minute ?? 59,
        );
      }

      final now = DateTime.now();
      final todo = Todo(
        id: widget.todo?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        dueDate: finalDueDate,
        isCompleted: widget.todo?.isCompleted ?? false,
        createdAt: widget.todo?.createdAt ?? now,
        updatedAt: now,
        priority: _priority,
        category: _categoryController.text.trim().isEmpty 
            ? null 
            : _categoryController.text.trim(),
      );

      if (widget.todo == null) {
        await context.read<TodoProvider>().addTodo(todo);
      } else {
        await context.read<TodoProvider>().updateTodo(todo);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.todo == null 
                ? 'Todo added successfully' 
                : 'Todo updated successfully'),
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

  Future<void> _deleteTodo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
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

    if (confirmed == true && widget.todo != null) {
      try {
        await context.read<TodoProvider>().deleteTodo(widget.todo!.id!);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todo deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting todo: \$e')),
          );
        }
      }
    }
  }
}
