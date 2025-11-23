import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import '../../api/api_service.dart';
import '../../utils/storage_service.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? token;
  final String? studentId;
  final String? name;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.token,
    this.studentId,
    this.name,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? token,
    String? studentId,
    String? name,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      error: error,
    );
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final api = ref.watch(apiServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthController(apiService: api, storageService: storage);
});

class AuthController extends StateNotifier<AuthState> {
  final ApiService apiService;
  final StorageService storageService;

  AuthController({
    required this.apiService,
    required this.storageService,
  }) : super(const AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final auth = await storageService.loadAuth();
    if (auth.token != null && auth.studentId != null) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: auth.token,
        studentId: auth.studentId,
        name: auth.name,
      );
    } else {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
  }

  Future<void> login({
    required String email,
    required String studentId,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await apiService.login(
        email: email,
        studentId: studentId,
        password: password,
      );

      await storageService.saveAuth(
        token: res.token,
        studentId: res.studentId,
        name: res.name,
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: res.token,
        studentId: res.studentId,
        name: res.name,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> register({
    required String email,
    required String studentId,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await apiService.register(
        email: email,
        studentId: studentId,
        password: password,
      );

      await storageService.saveAuth(
        token: res.token,
        studentId: res.studentId,
        name: res.name,
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: res.token,
        studentId: res.studentId,
        name: res.name,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> logout() async {
    await storageService.clearAuth();
    state = const AuthState(isLoading: false, isAuthenticated: false);
  }
}
