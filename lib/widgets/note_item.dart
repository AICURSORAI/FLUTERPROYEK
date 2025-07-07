import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  const NoteItem({
    super.key,
    required this.note,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Favorite button
                  IconButton(
                    icon: Icon(
                      note.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: note.isFavorite ? Colors.red : null,
                    ),
                    onPressed: onFavorite,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: Theme.of(context).colorScheme.error,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(left: 8.0),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Content preview
              Text(
                note.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Bottom row with metadata
              Row(
                children: [
                  // Category
                  if (note.category != null && note.category!.isNotEmpty)
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
                        note.category!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  
                  if (note.category != null && note.category!.isNotEmpty)
                    const SizedBox(width: 8),
                  
                  // Tags
                  if (note.tags != null && note.tags!.isNotEmpty)
                    Expanded(
                      child: Wrap(
                        spacing: 4.0,
                        children: note.tags!.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#$tag',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Updated date
                  Text(
                    _formatDate(note.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
              
              // Show more tags indicator
              if (note.tags != null && note.tags!.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    '+${note.tags!.length - 3} more tags',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}
