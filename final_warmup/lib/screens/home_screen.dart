import 'package:flutter/material.dart';
import '../models/task.dart';
import '../database/database_helper.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseHelper dbHelper;
  List<Task> tasks = [];
  int totalTasks = 0;
  int completedTasks = 0;
  bool showOnlyCompleted = false;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    _loadTasks();
  }

  /// Load tasks from database
  Future<void> _loadTasks() async {
    try {
      List<Task> loadedTasks;

      if (showOnlyCompleted) {
        loadedTasks = await dbHelper.getTasksByStatus(true);
      } else {
        loadedTasks = await dbHelper.getAllTasks();
      }

      final total = await dbHelper.getTaskCount();
      final completed = await dbHelper.getCompletedTaskCount();

      setState(() {
        tasks = loadedTasks;
        totalTasks = total;
        completedTasks = completed;
      });
    } catch (e) {
      _showErrorDialog('Error loading tasks: $e');
    }
  }

  /// Navigate to add/edit screen
  Future<void> _navigateToAddEditScreen({Task? task}) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => AddEditScreen(task: task)));

    if (result == true) {
      _loadTasks();
    }
  }

  /// Delete a task
  Future<void> _deleteTask(int id) async {
    try {
      await dbHelper.deleteTask(id);
      _loadTasks();
      _showSnackBar('Task deleted');
    } catch (e) {
      _showErrorDialog('Error deleting task: $e');
    }
  }

  /// Toggle task completion status
  Future<void> _toggleTaskStatus(Task task) async {
    try {
      await dbHelper.toggleTaskStatus(task.id!, !task.isCompleted);
      _loadTasks();
      _showSnackBar(
        task.isCompleted ? 'Task marked as incomplete' : 'Task completed',
      );
    } catch (e) {
      _showErrorDialog('Error updating task: $e');
    }
  }

  /// Delete all completed tasks
  Future<void> _deleteAllCompleted() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Completed Tasks?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await dbHelper.deleteCompletedTasks();
                _loadTasks();
                _showSnackBar('All completed tasks deleted');
              } catch (e) {
                _showErrorDialog('Error: $e');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          /// Stats Card
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', totalTasks, Colors.blue),
                _buildStatCard('Completed', completedTasks, Colors.green),
                _buildStatCard(
                  'Pending',
                  totalTasks - completedTasks,
                  Colors.orange,
                ),
              ],
            ),
          ),

          /// Filter Button
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: Text(
                      showOnlyCompleted ? 'Completed Tasks' : 'All Tasks',
                    ),
                    selected: showOnlyCompleted,
                    onSelected: (value) {
                      setState(() => showOnlyCompleted = value);
                      _loadTasks();
                    },
                  ),
                ),
                if (completedTasks > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ElevatedButton.icon(
                      onPressed: _deleteAllCompleted,
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          /// Tasks List
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          showOnlyCompleted
                              ? 'No completed tasks'
                              : 'No tasks yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) => _toggleTaskStatus(task),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Created: ${_formatDate(task.createdAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                                onTap: () =>
                                    _navigateToAddEditScreen(task: task),
                              ),
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.delete, size: 18),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                                onTap: () => _deleteTask(task.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
