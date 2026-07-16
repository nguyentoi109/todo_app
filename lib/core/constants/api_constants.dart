/// Cấu hình địa chỉ API
///
/// - Nếu chạy Android Emulator: dùng http://10.0.2.2/todo_api/api
/// - Nếu chạy trên máy thật (cùng mạng wifi với máy chủ XAMPP): dùng IP LAN của máy tính,
///   ví dụ http://192.168.1.100/todo_api/api
/// - Nếu chạy trên Web/Desktop: dùng http://localhost/todo_api/api
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = "http://10.0.2.2/todo_api/api";

  // Auth
  static const String register = "/register";
  static const String login = "/login";
  static const String logout = "/logout";

  // Profile
  static const String profile = "/profile";
  static const String changePassword = "/change-password";

  // Tasks
  static const String tasks = "/tasks";
  static const String taskStatistics = "/tasks/statistics";

  static String taskDetail(int id) => "/tasks/$id";

  static String taskComplete(int id) => "/tasks/$id/complete";
}
