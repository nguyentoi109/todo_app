import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../core/constants/api_constants.dart';
import '../models/task_model.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _api = ApiService();

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(date);
  }

  Future<List<TaskModel>> getTasks({
    String search = '',
    String filter = 'all',
    String sort = 'newest',
  }) async {
    try {
      final response = await _api.dio.get(
        ApiConstants.tasks,
        queryParameters: {
          if (search.isNotEmpty) 'search': search,
          'filter': filter,
          'sort': sort,
        },
      );

      if (response.data['success'] == true) {
        final List list = response.data['data'] ?? [];
        return list.map((e) => TaskModel.fromJson(e)).toList();
      }
      throw response.data['message'] ?? 'Không thể tải danh sách công việc.';
    } on DioException catch (e) {
      throw _api.extractErrorMessage(e);
    }
  }

  Future<TaskModel> getTaskDetail(int id) async {
    try {
      final response = await _api.dio.get(ApiConstants.taskDetail(id));
      if (response.data['success'] == true) {
        return TaskModel.fromJson(response.data['data']);
      }
      throw response.data['message'] ?? 'Không tìm thấy công việc.';
    } on DioException catch (e) {
      throw _api.extractErrorMessage(e);
    }
  }

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required TaskPriority priority,
    DateTime? dueDate,
  }) async {
    try {
      final response = await _api.dio.post(
        ApiConstants.tasks,
        data: {
          'title': title,
          'description': description,
          'priority': priority.apiValue,
          'due_date': _formatDate(dueDate),
        },
      );
      if (response.data['success'] == true) {
        return TaskModel.fromJson(response.data['data']);
      }
      throw response.data['message'] ?? 'Tạo công việc thất bại.';
    } on DioException catch (e) {
      throw _api.extractErrorMessage(e);
    }
  }

  Future<TaskModel> updateTask({
    required int id,
    required String title,
    required String description,
    required TaskPriority priority,
    DateTime? dueDate,
  }) async {
    try {
      final response = await _api.dio.put(
        ApiConstants.taskDetail(id),
        data: {
          'title': title,
          'description': description,
          'priority': priority.apiValue,
          'due_date': _formatDate(dueDate),
        },
      );
      if (response.data['success'] == true) {
        return TaskModel.fromJson(response.data['data']);
      }
      throw response.data['message'] ?? 'Cập nhật công việc thất bại.';
    } on DioException catch (e) {
      throw _api.extractErrorMessage(e);
    }
  }

  Future<TaskModel> setCompleted(int id, bool completed) async {
    try {
      final response = await _api.dio.patch(
        ApiConstants.taskComplete(id),
        data: {'completed': completed},
      );
      if (response.data['success'] == true) {
        return TaskModel.fromJson(response.data['data']);
      }
      throw response.data['message'] ?? 'Cập nhật trạng thái thất bại.';
    } on DioException catch (e) {
      throw _api.extractErrorMessage(e);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final response = await _api.dio.delete(ApiConstants.taskDetail(id));
      if (response.data['success'] != true) {
        throw response.data['message'] ?? 'Xoá công việc thất bại.';
      }
    } on DioException catch (e) {
      throw _api.extractErrorMessage(e);
    }
  }

  Future<TaskStatistics> getStatistics() async {
    try {
      final response = await _api.dio.get(ApiConstants.taskStatistics);
      if (response.data['success'] == true) {
        return TaskStatistics.fromJson(response.data['data']);
      }
      throw response.data['message'] ?? 'Không thể tải thống kê.';
    } on DioException catch (e) {
      throw _api.extractErrorMessage(e);
    }
  }
}
