import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late TaskPriority _priority;
  DateTime? _dueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _priority = widget.task.priority;
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );
      setState(() {
        _dueDate = DateTime(date.year, date.month, date.day, time?.hour ?? 18,
            time?.minute ?? 0);
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final success = await context.read<TaskProvider>().updateTask(
          id: widget.task.id,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
        );

    setState(() => _isSaving = false);

    if (success && mounted) {
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(context.read<TaskProvider>().errorMessage ??
                'Cập nhật thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa công việc')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _titleController,
                  label: 'Tiêu đề',
                  icon: Icons.title_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập tiêu đề'
                      : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descController,
                  label: 'Mô tả',
                  icon: Icons.notes_rounded,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                const Text('Mức độ ưu tiên',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Row(
                  children: TaskPriority.values.map((p) {
                    final selected = _priority == p;
                    final color = AppColors.priorityColor(p.apiValue);
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _priority = p),
                        child: Container(
                          margin: EdgeInsets.only(
                              right: p != TaskPriority.high ? 10 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? color.withOpacity(0.14)
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: selected ? color : Colors.transparent,
                                width: 1.4),
                          ),
                          child: Text(
                            p.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected ? color : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text('Hạn hoàn thành',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickDueDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 19, color: AppColors.textHint),
                        const SizedBox(width: 12),
                        Text(
                          _dueDate != null
                              ? DateFormat('dd/MM/yyyy - HH:mm')
                                  .format(_dueDate!)
                              : 'Chọn ngày hết hạn (không bắt buộc)',
                          style: TextStyle(
                            fontSize: 14,
                            color: _dueDate != null
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                          ),
                        ),
                        const Spacer(),
                        if (_dueDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _dueDate = null),
                            child: const Icon(Icons.close_rounded,
                                size: 18, color: AppColors.textHint),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                    label: 'Lưu thay đổi',
                    isLoading: _isSaving,
                    onPressed: _handleSave),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
