import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import '../../api/api_service.dart';
import '../auth/auth_controller.dart';

class StatusState {
  final bool isLoading;
  final StudentAppState state;
  final String? task;
  final String? error;

  const StatusState({
    this.isLoading = false,
    this.state = StudentAppState.normal,
    this.task,
    this.error,
  });

  StatusState copyWith({
    bool? isLoading,
    StudentAppState? state,
    String? task,
    String? error,
  }) {
    return StatusState(
      isLoading: isLoading ?? this.isLoading,
      state: state ?? this.state,
      task: task ?? this.task,
      error: error,
    );
  }
}

final statusControllerProvider =
    StateNotifierProvider<StatusController, StatusState>((ref) {
  final api = ref.watch(apiServiceProvider);
  final auth = ref.watch(authControllerProvider);
  return StatusController(apiService: api, authState: auth);
});

class StatusController extends StateNotifier<StatusState> {
  final ApiService apiService;
  final AuthState authState;

  StatusController({
    required this.apiService,
    required this.authState,
  }) : super(const StatusState(isLoading: false)) {
    refreshStatus();
  }

  String? get _token => authState.token;
  String? get _studentId => authState.studentId;

  bool get _hasAuth => _token != null && _studentId != null;

  Future<void> refreshStatus() async {
    if (!_hasAuth) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await apiService.getStudentStatus(
        token: _token!,
        studentId: _studentId!,
      );
      state = state.copyWith(
        isLoading: false,
        state: res.state,
        task: res.task,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch status.',
      );
    }
  }

  Future<void> markTaskComplete() async {
    if (!_hasAuth) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await apiService.markTaskComplete(
        token: _token!,
        studentId: _studentId!,
      );
      state = state.copyWith(
        isLoading: false,
        state: StudentAppState.normal,
        task: null,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to mark task complete.',
      );
    }
  }
}
