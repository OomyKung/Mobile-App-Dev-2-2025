import 'package:flutter/material.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class AddEditScreen extends StatefulWidget {
  final Task? task;

  const AddEditScreen({super.key, this.task});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DatabaseHelper dbHelper;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();

    if (widget.task != null) {
      titleController = TextEditingController(text: widget.task!.title);
      descriptionController = TextEditingController(
        text: widget.task!.description,
      );
    } else {
      titleController = TextEditingController();
      descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  /// Validate input fields
  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Task title is required';
    }
    if (value.length < 3) {
      return 'Title must be at least 3 characters';
    }
    if (value.length > 100) {
      return 'Title must not exceed 100 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    if (value.length < 5) {
      return 'Description must be at least 5 characters';
    }
    if (value.length > 500) {
      return 'Description must not exceed 500 characters';
    }
    return null;
  }

  /// Save or update task
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final task = Task(
        id: widget.task?.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        isCompleted: widget.task?.isCompleted ?? false,
        createdAt: widget.task?.createdAt,
      );

      if (widget.task != null) {
        // UPDATE existing task
        await dbHelper.updateTask(task);
        _showSnackBar('Task updated successfully');
      } else {
        // CREATE new task
        await dbHelper.insertTask(task);
        _showSnackBar('Task created successfully');
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorDialog('Error saving task: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
        title: Text(widget.task != null ? 'Edit Task' : 'Add Task'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Task Title Field
              Text(
                'Task Title',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: _validateTitle,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              Text(
                'Minimum 3 characters, maximum 100 characters',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 24),

              /// Task Description Field
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter task description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: _validateDescription,
                enabled: !isLoading,
                maxLines: 5,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),
              Text(
                'Minimum 5 characters, maximum 500 characters',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),

              if (widget.task != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Task Info',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Status: ${widget.task!.isCompleted ? "Completed" : "Pending"}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Created: ${_formatDate(widget.task!.createdAt)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (widget.task!.completedAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Completed: ${_formatDate(widget.task!.completedAt!)}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              /// Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveTask,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            widget.task != null ? 'Update Task' : 'Create Task',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Cancel'),
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
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
