import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = todo.dueDate != null && 
                     todo.dueDate!.isBefore(DateTime.now()) && 
                     !todo.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Checkbox
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) => onToggle(),
                  ),
                  
                  // Title and priority
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                todo.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  decoration: todo.isCompleted 
                                      ? TextDecoration.lineThrough 
                                      : null,
                                  color: todo.isCompleted 
                                      ? Theme.of(context).colorScheme.outline
                                      : null,
                                ),
                              ),
                            ),
                            _buildPriorityChip(context),
                          ],
                        ),
                        
                        // Description
                        if (todo.description != null && todo.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              todo.description!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                                decoration: todo.isCompleted 
                                    ? TextDecoration.lineThrough 
                                    : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ],
              ),
              
              // Bottom row with date, category, and status
              if (todo.dueDate != null || todo.category != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      // Due date
                      if (todo.dueDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue 
                                ? Theme.of(context).colorScheme.errorContainer
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: isOverdue 
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd, HH:mm').format(todo.dueDate!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isOverdue 
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      if (todo.dueDate != null && todo.category != null)
                        const SizedBox(width: 8),
                      
                      // Category
                      if (todo.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            todo.category!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      
                      const Spacer(),
                      
                      // Overdue indicator
                      if (isOverdue)
                        Icon(
                          Icons.warning,
                          size: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (todo.priority) {
      case 3:
        color = Colors.red;
        icon = Icons.priority_high;
        label = 'High';
        break;
      case 2:
        color = Colors.orange;
        icon = Icons.remove;
        label = 'Medium';
        break;
      case 1:
      default:
        color = Colors.green;
        icon = Icons.low_priority;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
