import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/status/status_controller.dart'; // for StudentAppState enum

class LoginResponse {
  final String studentId;
  final String name;
  final String email;
  final String status;

  LoginResponse({
    required this.studentId,
    required this.name,
    required this.email,
    required this.status,
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

  SubmitQuizResult({
    required this.score,
    required this.maxScore,
    required this.passed,
  });
}

class StudentStatus {
  final StudentAppState state;
  final String? task;
  final String? mentorName;

  StudentStatus({
    required this.state,
    this.task,
    this.mentorName,
  });
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class ApiService {
  static const _getQuizUrl =
      "https://quiz-test-wgcc.onrender.com/api-quiz/get-quiz";
  static const _submitQuizUrl =
      "https://quiz-test-wgcc.onrender.com/api-quiz/submit-quiz";
  static const _loginUrl =
      "https://quiz-test-wgcc.onrender.com/api-student/create";
  static const _markCompleteUrl =
      "https://quiz-test-wgcc.onrender.com/api-student/task-complete"; 

  /// LOGIN — create student session
  Future<LoginResponse> login({
    required String email,
    required String studentId,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse(_loginUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "id": studentId, "password": password}),
    );

    print("📥 Login response => ${res.body}");

    final json = jsonDecode(res.body);

    return LoginResponse(
      studentId: json["id"] ?? studentId,
      name: json["name"] ?? "Student",
      email: json["email"] ?? email,
      status: json["status"] ?? "On Track",
    );
  }

  /// GET QUIZ — loads quiz
  Future<QuizData> getQuiz() async {
    final res = await http.get(Uri.parse(_getQuizUrl));
    print("📥 Quiz response => ${res.body}");

    if (res.statusCode != 200) throw ApiException("Failed to fetch quiz");

    final json = jsonDecode(res.body);

    final questions = (json["questions"] as List).map((q) {
      return QuizQuestion(
        id: q["id"],
        text: q["text"],
        options: List<String>.from(q["options"]),
      );
    }).toList();

    return QuizData(
      quizId: json["quiz_id"],
      questions: questions,
    );
  }

  /// SUBMIT QUIZ — with focus time
  Future<SubmitQuizResult> submitQuiz({
    required String studentId,
    required String quizId,
    required Map<String, String> answers,
    required int focusMinutes,
  }) async {
    final answersList = answers.entries.map((entry) {
      return {
        "question_id": entry.key,
        "answer": entry.value,
      };
    }).toList();

    final body = {
      "student_id": studentId,
      "quiz_id": quizId,
      "answers": answersList,
      "focus_minutes": focusMinutes,
    };

  //  print("🚀 SUBMIT REQUEST BODY => ${jsonEncode(body)}");

    final res = await http.post(
      Uri.parse(_submitQuizUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print("📥 Submit Response => ${res.body}");

    if (res.statusCode != 200) throw ApiException("Submit failed");

    final json = jsonDecode(res.body);

    return SubmitQuizResult(
      score: json["score"] ?? 0,
      maxScore: json["total"] ?? 0,
      passed: json["status"] == "success",
    );
  }

  /// GET STUDENT STATUS — Locked / Remedial / Normal
  Future<StudentStatus> getStudentStatus(String studentId) async {
  final url = Uri.parse("https://quiz-test-wgcc.onrender.com/api-student/status?student_id=$studentId");

  print("📤 GET Status => $url");

  final res = await http.get(url);
  print("📥 STATUS Response => ${res.body} | status=${res.statusCode}");

  if (res.statusCode != 200) {
    throw ApiException("Failed to fetch student status");
  }

  final json = jsonDecode(res.body);

  late final StudentAppState state;
  if (json["status"] == "Normal") state = StudentAppState.normal;
  else if (json["status"] == "Remedial") state = StudentAppState.remedial;
  else state = StudentAppState.locked;

  return StudentStatus(
    state: state,
    task: json["task"],
    mentorName: json["mentor_name"],
  );
}


  /// MARK TASK COMPLETE
  Future<void> markTaskComplete({required String studentId}) async {
    final res = await http.post(
      Uri.parse(_markCompleteUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"student_id": studentId}),
    );

    print("📥 Task Complete Response => ${res.body}");
  }
}
