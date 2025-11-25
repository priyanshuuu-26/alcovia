import 'package:alcovia/src/features/auth/auth_controller.dart';
import 'package:riverpod/legacy.dart';
import '../../api/api_service.dart';

class QuizState {
  final bool isLoading;
  final QuizData? quiz;
  final int currentIndex;
  final Map<String, String> answers;
  final bool isSubmitting;
  final String? error;
  final String email;

  const QuizState({
    required this.email,
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
    String? email,
  }) {
    return QuizState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      quiz: quiz ?? this.quiz,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

final quizControllerProvider = StateNotifierProvider<QuizController, QuizState>(
  (ref) {
    final api = ref.watch(apiProvider);
    final auth = ref.watch(authControllerProvider);

    return QuizController(
      apiService: api, 
      email: auth.email ?? "");

  },
);

class QuizController extends StateNotifier<QuizState> {
  final ApiService apiService;
  DateTime? _startTime;

  QuizController({required this.apiService, required String email})
    : super(QuizState(email: email));
  Future<void> loadQuiz() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final quiz = await apiService.getQuiz();
      _startTime = DateTime.now();

      state = state.copyWith(
        isLoading: false,
        quiz: quiz,
        currentIndex: 0,
        answers: {},
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "Failed to load quiz");
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

  Future<SubmitQuizResult?> submitQuiz({required String studentId}) async {
    if (state.quiz == null) return null;

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final endTime = DateTime.now();
      final start = _startTime ?? endTime;
      final seconds = endTime.difference(start).inSeconds;
      final focusMinutes = (seconds / 60).ceil().clamp(1, 180);

      final result = await apiService.submitQuiz(
        studentId: studentId,
        quizId: state.quiz!.quizId,
        answers: state.answers,
        focusMinutes: focusMinutes,
        email: state.email,
      );

      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }
}
