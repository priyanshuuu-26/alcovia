import 'dart:async';

enum StudentAppState { normal, locked, remedial }

class LoginResponse {
  final String token;
  final String studentId;
  final String name;

  LoginResponse({
    required this.token,
    required this.studentId,
    required this.name,
  });
}

class QuizQuestion {
  final String id;
  final String text;
  final List<String> options;

  QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
  });
}

class QuizData {
  final String quizId;
  final List<QuizQuestion> questions;

  QuizData({
    required this.quizId,
    required this.questions,
  });
}

class SubmitQuizResult {
  final int score;
  final int maxScore;
  final bool passed;
  final StudentAppState studentState;

  SubmitQuizResult({
    required this.score,
    required this.maxScore,
    required this.passed,
    required this.studentState,
  });
}

class StudentStatus {
  final StudentAppState state;
  final String? task;

  StudentStatus({
    required this.state,
    this.task,
  });
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

///
/// MOCK ApiService - works without backend
/// Your friend will later replace these implementations
/// with real HTTP calls to /login, /quiz, /submit-quiz, etc.
///
class ApiService {
  // In-memory student state (for demo)
  final Map<String, StudentAppState> _studentState = {};
  final Map<String, String?> _studentTask = {};

  /// LOGIN
  ///
  /// TODO: Replace with real POST /login
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.isEmpty || password.isEmpty) {
      throw ApiException('Email and password are required.');
    }

    const studentId = 'student_123';
    _studentState[studentId] = _studentState[studentId] ?? StudentAppState.normal;

    return LoginResponse(
      token: 'mock_token_$studentId',
      studentId: studentId,
      name: 'Demo Student',
    );
  }

  /// FETCH QUIZ (multiple questions)
  ///
  /// TODO: Replace with real GET /quiz
  Future<QuizData> fetchQuiz({
    required String token,
    required String studentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Mock quiz
    final questions = <QuizQuestion>[
      QuizQuestion(
        id: 'q1',
        text: 'What is 2 + 2?',
        options: ['1', '2', '3', '4'],
      ),
      QuizQuestion(
        id: 'q2',
        text: 'Which planet is known as the Red Planet?',
        options: ['Earth', 'Mars', 'Jupiter', 'Venus'],
      ),
      QuizQuestion(
        id: 'q3',
        text: 'Flutter is primarily used for?',
        options: ['Web', 'Mobile', 'Desktop', 'All of the above'],
      ),
    ];

    return QuizData(
      quizId: 'quiz_001',
      questions: questions,
    );
  }

  /// SUBMIT QUIZ + focus minutes
  ///
  /// TODO: Replace with real POST /submit-quiz
  ///
  /// answers: Map<questionId, optionText>
  Future<SubmitQuizResult> submitQuiz({
    required String token,
    required String studentId,
    required String quizId,
    required Map<String, String> answers,
    required int focusMinutes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simple mock scoring: count how many answers are non-empty
    // In real backend, answer checking + scoring happens.
    final maxScore = answers.length;
    final score = answers.values.where((a) => a.isNotEmpty).length;

    // Mock passing rule: need at least 70%
    final passed = score >= (0.7 * maxScore);

    final newState = passed ? StudentAppState.normal : StudentAppState.locked;
    _studentState[studentId] = newState;

    if (!passed) {
      // Clear any previous task; mentor + n8n will assign new one
      _studentTask[studentId] = null;
    }

    return SubmitQuizResult(
      score: score,
      maxScore: maxScore,
      passed: passed,
      studentState: newState,
    );
  }

  /// GET STUDENT STATUS
  ///
  /// TODO: Replace with real GET /student-status/:id
  Future<StudentStatus> getStudentStatus({
    required String token,
    required String studentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final state = _studentState[studentId] ?? StudentAppState.normal;
    final task = _studentTask[studentId];

    return StudentStatus(
      state: state,
      task: task,
    );
  }

  /// MARK TASK COMPLETE
  ///
  /// TODO: Replace with real POST /mark-complete
  Future<void> markTaskComplete({
    required String token,
    required String studentId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _studentState[studentId] = StudentAppState.normal;
    _studentTask[studentId] = null;
  }

  /// MOCK: This simulates mentor assigning remedial task.
  /// Useful only for testing the remedial flow without backend.
  Future<void> assignMockRemedialTask({
    required String studentId,
    required String task,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _studentState[studentId] = StudentAppState.remedial;
    _studentTask[studentId] = task;
  }
}
