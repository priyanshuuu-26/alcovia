import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyToken = 'auth_token';
  static const _keyStudentId = 'student_id';
  static const _keyName = 'student_name';

  Future<void> saveAuth({
    required String token,
    required String studentId,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyStudentId, studentId);
    await prefs.setString(_keyName, name);
  }

  Future<({String? token, String? studentId, String? name})> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      token: prefs.getString(_keyToken),
      studentId: prefs.getString(_keyStudentId),
      name: prefs.getString(_keyName),
    );
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyStudentId);
    await prefs.remove(_keyName);
  }
}
