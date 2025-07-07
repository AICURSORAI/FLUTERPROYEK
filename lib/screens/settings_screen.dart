import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupService _backupService = BackupService();
  final NotificationService _notificationService = NotificationService();
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Settings
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Appearance'),
                  subtitle: const Text('Customize app theme'),
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Use dark theme'),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      secondary: Icon(
                        themeProvider.isDarkMode 
                            ? Icons.dark_mode 
                            : Icons.light_mode,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Backup & Restore
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Backup & Restore'),
                  subtitle: const Text('Export and import your data'),
                ),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('Export Data'),
                  subtitle: const Text('Create a backup of your todos and notes'),
                  trailing: _isExporting 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isExporting ? null : _exportData,
                ),
                ListTile(
                  leading: const Icon(Icons.file_upload),
                  title: const Text('Import Data'),
                  subtitle: const Text('Restore from a backup file'),
                  trailing: _isImporting 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isImporting ? null : _importData,
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Backup History'),
                  subtitle: const Text('View and manage backup files'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showBackupHistory,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notifications
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  subtitle: const Text('Manage notification settings'),
                ),
                ListTile(
                  leading: const Icon(Icons.notification_important),
                  title: const Text('Test Notification'),
                  subtitle: const Text('Send a test notification'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _testNotification,
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_off),
                  title: const Text('Clear All Notifications'),
                  subtitle: const Text('Cancel all pending notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _clearAllNotifications,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // About
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  subtitle: const Text('App information'),
                ),
                ListTile(
                  leading: const Icon(Icons.apps),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Developer'),
                  subtitle: const Text('Todo Notes App Team'),
                  trailing: const Icon(Icons.chevron_right),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Report Issue'),
                  subtitle: const Text('Send feedback or report bugs'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _reportIssue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final filePath = await _backupService.exportToJson();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully to: \$filePath'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () {
                // TODO: Implement share functionality
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: \$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _importData() async {
    // Show file picker dialog (simplified version)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text(
          'This feature would normally open a file picker to select a backup file. '
          'For this demo, you can use the backup history to restore from previous exports.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBackupHistory() async {
    final backupFiles = await _backupService.getBackupFiles();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup History'),
        content: SizedBox(
          width: double.maxFinite,
          child: backupFiles.isEmpty
              ? const Text('No backup files found')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: backupFiles.length,
                  itemBuilder: (context, index) {
                    final filePath = backupFiles[index];
                    final fileName = filePath.split('/').last;
                    
                    return ListTile(
                      title: Text(fileName),
                      subtitle: FutureBuilder<Map<String, dynamic>>(
                        future: _backupService.getBackupInfo(filePath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final info = snapshot.data!;
                            return Text(
                              'Todos: \${info['todosCount']}, Notes: \${info['notesCount']}\n'
                              'Date: \${info['exportDate']}',
                            );
                          }
                          return const Text('Loading...');
                        },
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'restore',
                            child: const Text('Restore'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: const Text('Delete'),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'restore') {
                            await _restoreFromBackup(filePath);
                          } else if (value == 'delete') {
                            await _deleteBackup(filePath);
                          }
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreFromBackup(String filePath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will add the backup data to your current data. '
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _backupService.importFromJson(filePath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data restored successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Restore failed: \$e')),
          );
        }
      }
    }
  }

  Future<void> _deleteBackup(String filePath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: const Text('Are you sure you want to delete this backup file?'),
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

    if (confirmed == true) {
      try {
        await _backupService.deleteBackupFile(filePath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup file deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: \$e')),
          );
        }
      }
    }
  }

  Future<void> _testNotification() async {
    await _notificationService.showInstantNotification(
      id: 999,
      title: 'Test Notification',
      body: 'This is a test notification from Todo Notes App',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent')),
      );
    }
  }

  Future<void> _clearAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications cleared')),
      );
    }
  }

  void _reportIssue() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: const Text(
          'To report an issue or provide feedback, please contact us at:\n\n'
          'Email: support@todonotesapp.com\n'
          'GitHub: github.com/todonotesapp/issues',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
