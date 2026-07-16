import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthResult {
  final UserModel user;
  final String token;

  AuthResult({required this.user, required this.token});
}

class AuthService {
  final ApiService _api = ApiService();

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _api.dio.post(
        ApiConstants.register,
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        await _api.saveToken(token);
        return AuthResult(user: UserModel.fromJson(data['user']), token: token);
      }
      throw response.data['message'] ?? 'Đăng ký thất bại.';
    } on DioException catch (e) {
      throw _api.extractErrorMessage(e);
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        await _api.saveToken(token);
        return AuthResult(user: UserModel.fromJson(data['user']), token: token);
      }
      throw response.data['message'] ?? 'Đăng nhập thất bại.';
    } on DioException catch (e) {
      throw _api.extractErrorMessage(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.dio.post(ApiConstants.logout);
    } catch (_) {
      // Bỏ qua lỗi mạng khi logout, vẫn xoá token cục bộ
    } finally {
      await _api.clearToken();
    }
  }

  Future<bool> isLoggedIn() => _api.hasToken();

  Future<UserModel> getProfile() async {
    try {
      final response = await _api.dio.get(ApiConstants.profile);
      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }
      throw response.data['message'] ?? 'Không thể tải hồ sơ.';
    } on DioException catch (e) {
      throw _api.extractErrorMessage(e);
    }
  }

  Future<UserModel> updateProfile({required String fullName}) async {
    try {
      final response = await _api.dio.put(
        ApiConstants.profile,
        data: {'full_name': fullName},
      );
      if (response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      }
      throw response.data['message'] ?? 'Cập nhật thất bại.';
    } on DioException catch (e) {
      throw _api.extractErrorMessage(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _api.dio.put(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      if (response.data['success'] != true) {
        throw response.data['message'] ?? 'Đổi mật khẩu thất bại.';
      }
    } on DioException catch (e) {
      throw _api.extractErrorMessage(e);
    }
  }
}
