import 'package:shared_preferences/shared_preferences.dart';

class StoredAuth {
  final String? studentId;
  final String? name;
  final String? email;
  final String? status;

  StoredAuth({
    this.studentId,
    this.name,
    this.email,
    this.status,
  });
}

class StorageService {
  /// Save login session
  Future<void> saveAuth({
    required String studentId,
    required String name,
    required String email,
    required String status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("studentId", studentId);
    await prefs.setString("name", name);
    await prefs.setString("email", email);
    await prefs.setString("status", status);
  }

  /// Load auth from storage at app start
  Future<StoredAuth> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    return StoredAuth(
      studentId: prefs.getString("studentId"),
      name: prefs.getString("name"),
      email: prefs.getString("email"),
      status: prefs.getString("status"),
    );
  }

  /// Clear session on logout
  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("studentId");
    await prefs.remove("name");
    await prefs.remove("email");
    await prefs.remove("status");
  }
}
