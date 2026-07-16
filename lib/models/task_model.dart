enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get apiValue {
    switch (this) {
      case TaskPriority.low:
        return 'LOW';
      case TaskPriority.medium:
        return 'MEDIUM';
      case TaskPriority.high:
        return 'HIGH';
    }
  }

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Thấp';
      case TaskPriority.medium:
        return 'Trung bình';
      case TaskPriority.high:
        return 'Cao';
    }
  }

  static TaskPriority fromApi(String? value) {
    switch ((value ?? 'MEDIUM').toUpperCase()) {
      case 'HIGH':
        return TaskPriority.high;
      case 'LOW':
        return TaskPriority.low;
      case 'MEDIUM':
      default:
        return TaskPriority.medium;
    }
  }
}

class TaskModel {
  final int id;
  final String title;
  final String description;
  final TaskPriority priority;
  final bool completed;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.completed,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: TaskPriorityX.fromApi(json['priority']),
      completed: json['completed'].toString() == '1' || json['completed'] == true,
      dueDate: json['due_date'] != null && json['due_date'].toString().isNotEmpty
          ? DateTime.tryParse(json['due_date'])
          : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  bool get isOverdue =>
      !completed && dueDate != null && dueDate!.isBefore(DateTime.now());

  TaskModel copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    bool? completed,
    DateTime? dueDate,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class TaskStatistics {
  final int total;
  final int completed;
  final int pending;
  final int overdue;
  final double completionRate;

  TaskStatistics({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.completionRate,
  });

  factory TaskStatistics.fromJson(Map<String, dynamic> json) {
    return TaskStatistics(
      total: int.parse(json['total'].toString()),
      completed: int.parse(json['completed'].toString()),
      pending: int.parse(json['pending'].toString()),
      overdue: int.parse(json['overdue'].toString()),
      completionRate: double.parse(json['completion_rate'].toString()),
    );
  }

  factory TaskStatistics.empty() => TaskStatistics(
    total: 0,
    completed: 0,
    pending: 0,
    overdue: 0,
    completionRate: 0,
  );
}