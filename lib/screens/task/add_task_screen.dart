import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/constants/app_colors.dart';
import 'package:todo_app/models/task_model.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/widgets/custom_button.dart';
import 'package:todo_app/widgets/custom_textfield.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreen();
}

class _AddTaskScreen extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  bool isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 3650)),
        builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context)
                  .colorScheme
                  .copyWith(primary: AppColors.primary),
            ),
            child: child!));

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 18, minute: 0),
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
    setState(() => isSaving = true);

    final success = await context.read<TaskProvider>().createTask(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _priority,
        dueDate: _dueDate);

    setState(() => isSaving = false);

    if (success && mounted) {
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(context.read<TaskProvider>().errorMessage ??
                'Tạo công việc thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm công việc')),
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
                const SizedBox(
                  height: 16,
                ),
                CustomTextField(
                  controller: _descController,
                  label: 'Mô tả',
                  icon: Icons.note_add_rounded,
                  maxLines: 4,
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Mức độ ưu tiên',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(
                  height: 10,
                ),
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
                    ));
                  }).toList(),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Hạn hoàn thành',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(
                  height: 10,
                ),
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
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 19,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Text(
                          _dueDate != null
                              ? DateFormat('dd/MM/yyyy - HH:mm')
                                  .format(_dueDate!)
                              : 'Chọn ngày hết hạn(không bắt buộc',
                          style: TextStyle(
                              fontSize: 14,
                              color: _dueDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textHint),
                        ),
                        const Spacer(),
                        if (_dueDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _dueDate = null),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.textHint,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                CustomButton(
                  label: 'Lưu công việc',
                  isLoading: isSaving,
                  onPressed: _handleSave,
                ),
              ],
            )),
      )),
    );
  }
}
