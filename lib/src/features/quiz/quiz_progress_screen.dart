import 'package:alcovia/src/features/auth/auth_controller.dart';
import 'package:alcovia/src/features/quiz/thankyou_screen.dart';
import 'package:alcovia/src/features/status/status_lockscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'quiz_controller.dart';

class QuizProgressScreen extends ConsumerStatefulWidget {
  const QuizProgressScreen({super.key});

  @override
  ConsumerState<QuizProgressScreen> createState() => _QuizProgressScreenState();
}

class _QuizProgressScreenState extends ConsumerState<QuizProgressScreen> {
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _submitQuiz();
    });
  }

  Future<void> _submitQuiz() async {
    if (_submitted) return;
    _submitted = true;

    final auth = ref.read(authControllerProvider);
    final quizNotifier = ref.read(quizControllerProvider.notifier);

    final result = await quizNotifier.submitQuiz(
      studentId: auth.studentId!,
    );

    if (!mounted) return;

    // If backend failed or quiz didn't return result
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit quiz")),
      );
      Navigator.pop(context);
      return;
    }

    // Auto navigation based on result
    if (result.passed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ThankYouScreen(
            score: result.score,
            maxScore: result.maxScore,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LockedScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Evaluating your quiz...',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
