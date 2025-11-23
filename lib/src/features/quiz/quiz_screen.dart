import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'quiz_controller.dart';
import 'quiz_progress_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late Timer _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();

    // Start increasing timer from 0
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });

    // Load quiz once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(quizControllerProvider);
      if (!state.isLoading && state.quiz == null) {
        ref.read(quizControllerProvider.notifier).loadQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizControllerProvider);
    final quizNotifier = ref.read(quizControllerProvider.notifier);

    // 1. Loading state
    if (quizState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Error state
    if (quizState.error != null) {
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    quizState.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      quizNotifier.loadQuiz();
                    },
                    child: const Text("Retry Quiz"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 3. No quiz found
    if (quizState.quiz == null) {
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "No quiz available right now.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      quizNotifier.loadQuiz();
                    },
                    child: const Text("Reload Quiz"),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 4. Quiz loaded → show question
    final quiz = quizState.quiz!;
    final questions = quiz.questions;
    final currentIndex = quizState.currentIndex;
    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question ${currentIndex + 1}/${questions.length}'),
            Text(
              formatTime(_elapsedSeconds),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                // color: Colors.green,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question text
            Text(
              question.text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // Options
            ...question.options.map((option) {
              final selected = quizState.answers[question.id] == option;

              return RadioListTile<String>(
                value: option,
                groupValue: quizState.answers[question.id],
                onChanged: (value) {
                  if (value != null) {
                    quizNotifier.selectAnswer(question.id, value);
                  }
                },
                title: Text(option),
                activeColor: Colors.blue,
                controlAffinity: ListTileControlAffinity.leading,
                selected: selected,
              );
            }),

            const Spacer(),

            // Buttons
            Row(
              children: [
                if (currentIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: quizNotifier.previousQuestion,
                      child: const Text("Previous"),
                    ),
                  ),
                if (currentIndex > 0) const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentIndex < questions.length - 1) {
                        quizNotifier.nextQuestion();
                      } else {
                        if (quizState.answers.length < questions.length) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please answer all questions"),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuizProgressScreen(),
                          ),
                        );
                      }
                    },
                    child: Text(
                      currentIndex < questions.length - 1 ? "Next" : "Submit",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
