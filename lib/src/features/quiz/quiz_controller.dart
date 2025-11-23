import 'package:alcovia/src/features/auth/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import '../../api/api_service.dart';

class QuizState {
  final bool isLoading;
  final QuizData? quiz;
  final int currentIndex;
  final Map<String, String> answers;
  final bool isSubmitting;
  final String? error;

  const QuizState({
    this.isLoading = false,
    this.quiz,
    this.currentIndex = 0,
    this.answers = const {},
    this.isSubmitting = false,
    this.error,
  });

  QuizState copyWith({
    bool? isLoading,
    QuizData? quiz,
    int? currentIndex,
    Map<String, String>? answers,
    bool? isSubmitting,
    String? error,
  }) {
    return QuizState(
      isLoading: isLoading ?? this.isLoading,
      quiz: quiz ?? this.quiz,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

final quizControllerProvider =
    StateNotifierProvider<QuizController, QuizState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return QuizController(apiService: api);
});

class QuizController extends StateNotifier<QuizState> {
  final ApiService apiService;
  DateTime? _startTime;

  QuizController({required this.apiService}) : super(const QuizState());

  Future<void> loadQuiz({
    required String token,
    required String studentId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final quiz = await apiService.fetchQuiz(token: token, studentId: studentId);
      _startTime = DateTime.now();
      state = state.copyWith(
        isLoading: false,
        quiz: quiz,
        currentIndex: 0,
        answers: {},
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load quiz.',
      );
    }
  }

  void selectAnswer(String questionId, String answer) {
    final newAnswers = Map<String, String>.from(state.answers);
    newAnswers[questionId] = answer;
    state = state.copyWith(answers: newAnswers);
  }

  void nextQuestion() {
    if (state.quiz == null) return;
    if (state.currentIndex < state.quiz!.questions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previousQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  Future<SubmitQuizResult?> submitQuiz({
    required String token,
    required String studentId,
  }) async {
    if (state.quiz == null) return null;
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final endTime = DateTime.now();
      final start = _startTime ?? endTime;
      final seconds = endTime.difference(start).inSeconds;
      final focusMinutes = (seconds / 60).ceil().clamp(1, 180); // 1–180 mins

      final result = await apiService.submitQuiz(
        token: token,
        studentId: studentId,
        quizId: state.quiz!.quizId,
        answers: state.answers,
        focusMinutes: focusMinutes,
      );

      state = state.copyWith(isSubmitting: false);
      return result;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.message);
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit quiz.',
      );
    }
    return null;
  }
}
