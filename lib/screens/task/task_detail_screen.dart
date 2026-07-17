import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/services/task_service.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreen();
}

class _TaskDetailScreen extends State<TaskDetailScreen> {
  final TaskService _taskService = TaskService();
  TaskModel? _task;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final task = await _taskService.getTaskDetail(widget.taskId);
      setState(() {
        _task = task;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleComplete() async {
    if (_task == null) return;
    final success = await context.read<TaskProvider>().toggleCompleted(_task!);
    if (success) {
      setState(() => _task = _task!.copyWith(completed: !_task!.completed));
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Xoá công việc?'),
        content: Text(
            'Bạn có chắc muốn xoá "${_task!.title}"? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await context.read<TaskProvider>().deleteTask(_task!.id);
              if (success && mounted) context.pop();
            },
            child: const Text('Xoá', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        actions: _task == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => EditTaskScreen(task: _task!)),
                    );
                    _loadTask();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error),
                  onPressed: _confirmDelete,
                ),
              ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.error)))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final task = _task!;
    final color = AppColors.priorityColor(task.priority.apiValue);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Ưu tiên ${task.priority.label}',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      (task.completed ? AppColors.success : AppColors.warning)
                          .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  task.completed ? 'Đã hoàn thành' : 'Chưa hoàn thành',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color:
                        task.completed ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            task.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              decoration: task.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 16),
          if (task.description.isNotEmpty) ...[
            const Text('Mô tả',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(task.description,
                style: const TextStyle(
                    fontSize: 14.5, color: AppColors.textPrimary, height: 1.5)),
            const SizedBox(height: 24),
          ],
          _infoRow(
              Icons.calendar_today_rounded,
              'Ngày tạo',
              task.createdAt != null
                  ? DateFormat('dd/MM/yyyy - HH:mm').format(task.createdAt!)
                  : '-'),
          const SizedBox(height: 14),
          _infoRow(
            Icons.event_available_rounded,
            'Hạn hoàn thành',
            task.dueDate != null
                ? DateFormat('dd/MM/yyyy - HH:mm').format(task.dueDate!)
                : 'Không có hạn',
            valueColor: task.isOverdue ? AppColors.overdue : null,
          ),
          const SizedBox(height: 36),
          CustomButton(
            label: task.completed
                ? 'Bỏ đánh dấu hoàn thành'
                : 'Đánh dấu hoàn thành',
            icon: task.completed ? Icons.replay_rounded : Icons.check_rounded,
            color: task.completed ? AppColors.textSecondary : AppColors.success,
            onPressed: _toggleComplete,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
