import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import '../auth/auth_controller.dart';
import '../../api/api_service.dart';

/// student can have 3 states from backend:
enum StudentAppState { normal, locked, remedial }

class StatusState {
  final bool isLoading;
  final StudentAppState? state;
  final String? task;
  final String? mentorName;
  final String? mentorEmail;
  final String? error;

  const StatusState({
    this.isLoading = false,
    this.state,
    this.task,
    this.mentorName,
    this.mentorEmail,
    this.error,
  });

  StatusState copyWith({
    bool? isLoading,
    StudentAppState? state,
    String? task,
    String? mentorName,
    String? mentorEmail,
    String? error,
  }) {
    return StatusState(
      isLoading: isLoading ?? this.isLoading,
      state: state ?? this.state,
      task: task ?? this.task,
      mentorName: mentorName ?? this.mentorName,
      mentorEmail: mentorEmail ?? this.mentorEmail,
      error: error,
    );
  }
}

final statusControllerProvider =
    StateNotifierProvider<StatusController, StatusState>((ref) {
  final api = ref.watch(apiProvider);
  return StatusController(api);
});

class StatusController extends StateNotifier<StatusState> {
  final ApiService api;

  StatusController(this.api) : super(const StatusState());

  /// load status from backend
  Future<void> loadStatus(String studentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final status = await api.getStudentStatus(studentId); // 👈 FIXED
      state = state.copyWith(
        isLoading: false,
        state: status.state,
        task: status.task,
        mentorName: status.mentorName,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshStatus(String studentId) async {
    await loadStatus(studentId);
  }

  /// Mark task complete
  Future<void> completeTask(String studentId) async {
    state = state.copyWith(isLoading: true);
    try {
      await api.markTaskComplete(studentId: studentId);
      await loadStatus(studentId); // reload after completion
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
