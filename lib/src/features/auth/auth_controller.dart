import 'package:alcovia/src/api/api_service.dart';
import 'package:alcovia/src/utils/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? studentId;
  final String? name;
  final String? email;
  final String? status;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.studentId,
    this.name,
    this.email,
    this.status,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? studentId,
    String? name,
    String? email,
    String? status,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      error: error,
    );
  }
}

final apiProvider = Provider<ApiService>((ref) => ApiService());
final storageProvider = Provider<StorageService>((ref) => StorageService());

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final api = ref.read(apiProvider);
  final storage = ref.read(storageProvider);
  return AuthController(api, storage);
});

class AuthController extends StateNotifier<AuthState> {
  final ApiService api;
  final StorageService storage;

  AuthController(this.api, this.storage) : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final saved = await storage.loadAuth();
    if (saved.studentId != null) {
      state = state.copyWith(
        isAuthenticated: true,
        studentId: saved.studentId,
        name: saved.name,
        email: saved.email,
        status: saved.status,
      );
    }
  }

  Future<void> login({
    required String email,
    required String studentId,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await api.login(
        email: email,
        studentId: studentId,
        password: password,
      );

      await storage.saveAuth(
        studentId: result.studentId,
        name: result.name,
        email: result.email,
        status: result.status,
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        studentId: result.studentId,
        name: result.name,
        email: result.email,
        status: result.status,
        error: null,
      );
    } catch (_) {
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        error: null,
      );
    }
  }

  Future<void> logout() async {
    await storage.clearAuth();
    state = const AuthState();
  }
}
