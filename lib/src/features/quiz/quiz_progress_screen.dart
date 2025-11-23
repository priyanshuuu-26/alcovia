import 'package:alcovia/src/api/api_service.dart';
import 'package:alcovia/src/features/quiz/thankyou_screen.dart';
import 'package:alcovia/src/features/status/status_lockscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
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
    // Delay a frame so build has context before async call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _submit();
    });
  }

  Future<void> _submit() async {
    if (_submitted) return;
    _submitted = true;

    final auth = ref.read(authControllerProvider);
    if (auth.token == null || auth.studentId == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final quizNotifier = ref.read(quizControllerProvider.notifier);
    final result = await quizNotifier.submitQuiz(
      token: auth.token!,
      studentId: auth.studentId!,
    );

    final quizState = ref.read(quizControllerProvider);
    if (quizState.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(quizState.error!)),
      );
      Navigator.of(context).pop();
      return;
    }

    if (!mounted || result == null) return;

    if (result.passed && result.studentState == StudentAppState.normal) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ThankYouScreen(
            score: result.score,
            maxScore: result.maxScore,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
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
