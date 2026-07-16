import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

enum TaskFilter { all, pending, completed, overdue, highPriority }

extension TaskFilterX on TaskFilter {
  String get apiValue {
    switch (this) {
      case TaskFilter.pending:
        return 'pending';
      case TaskFilter.completed:
        return 'completed';
      case TaskFilter.overdue:
        return 'overdue';
      case TaskFilter.highPriority:
        return 'high_priority';
      case TaskFilter.all:
        return 'all';
    }
  }

  String get label {
    switch (this) {
      case TaskFilter.pending:
        return 'Chưa hoàn thành';
      case TaskFilter.completed:
        return 'Đã hoàn thành';
      case TaskFilter.overdue:
        return 'Quá hạn';
      case TaskFilter.highPriority:
        return 'Ưu tiên cao';
      case TaskFilter.all:
        return 'Tất cả';
    }
  }
}

enum TaskSort { newest, oldest, dueSoon }

extension TaskSortX on TaskSort {
  String get apiValue {
    switch (this) {
      case TaskSort.oldest:
        return 'oldest';
      case TaskSort.dueSoon:
        return 'due_soon';
      case TaskSort.newest:
        return 'newest';
    }
  }

  String get label {
    switch (this) {
      case TaskSort.oldest:
        return 'Cũ nhất';
      case TaskSort.dueSoon:
        return 'Gần đến hạn';
      case TaskSort.newest:
        return 'Mới nhất';
    }
  }
}

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _tasks = [];
  TaskStatistics statistics = TaskStatistics.empty();

  bool isLoading = false;
  String? errorMessage;

  String searchQuery = '';
  TaskFilter filter = TaskFilter.all;
  TaskSort sort = TaskSort.newest;

  List<TaskModel> get tasks => _tasks;

  Future<void> loadTasks({bool showLoading = true}) async {
    if (showLoading) {
      isLoading = true;
      notifyListeners();
    }
    try {
      _tasks = await _taskService.getTasks(
        search: searchQuery,
        filter: filter.apiValue,
        sort: sort.apiValue,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadStatistics() async {
    try {
      statistics = await _taskService.getStatistics();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> refreshAll() async {
    await Future.wait([loadTasks(showLoading: false), loadStatistics()]);
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    loadTasks(showLoading: false);
  }

  void setFilter(TaskFilter newFilter) {
    filter = newFilter;
    loadTasks();
  }

  void setSort(TaskSort newSort) {
    sort = newSort;
    loadTasks();
  }

  Future<bool> createTask({
    required String title,
    required String description,
    required TaskPriority priority,
    DateTime? dueDate,
  }) async {
    try {
      await _taskService.createTask(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
      await refreshAll();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask({
    required int id,
    required String title,
    required String description,
    required TaskPriority priority,
    DateTime? dueDate,
  }) async {
    try {
      await _taskService.updateTask(
        id: id,
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
      await refreshAll();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleCompleted(TaskModel task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    final previous = _tasks;
    if (index != -1) {
      _tasks = List.of(_tasks);
      _tasks[index] = task.copyWith(completed: !task.completed);
      notifyListeners();
    }

    try {
      await _taskService.setCompleted(task.id, !task.completed);
      await loadStatistics();
      return true;
    } catch (e) {
      _tasks = previous;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await _taskService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
      await loadStatistics();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
