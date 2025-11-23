import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import 'quiz_controller.dart';
import 'quiz_progress_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authControllerProvider);
      if (auth.token != null && auth.studentId != null) {
        ref
            .read(quizControllerProvider.notifier)
            .loadQuiz(token: auth.token!, studentId: auth.studentId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: quizState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : quizState.quiz == null
                      ? const Center(
                          child: Text('No quiz loaded. Please try again.'),
                        )
                      : _buildQuizContent(context, quizState),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, QuizState quizState) {
    final quiz = quizState.quiz!;
    final question = quiz.questions[quizState.currentIndex];
    final selected = quizState.answers[question.id];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question ${quizState.currentIndex + 1} of ${quiz.questions.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Text(
          question.text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...question.options.map((opt) {
          final isSelected = selected == opt;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                ref
                    .read(quizControllerProvider.notifier)
                    .selectAnswer(question.id, opt);
              },
              child: Row(
                children: [
                  Radio<String>(
                    value: opt,
                    groupValue: selected,
                    onChanged: (_) {
                      ref
                          .read(quizControllerProvider.notifier)
                          .selectAnswer(question.id, opt);
                    },
                  ),
                  Expanded(child: Text(opt)),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        if (quizState.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              quizState.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        Row(
          children: [
            if (quizState.currentIndex > 0)
              TextButton(
                onPressed: () {
                  ref.read(quizControllerProvider.notifier).previousQuestion();
                },
                child: const Text('Previous'),
              ),
            const Spacer(),
            if (quizState.currentIndex < quiz.questions.length - 1)
              ElevatedButton(
                onPressed: () {
                  ref.read(quizControllerProvider.notifier).nextQuestion();
                },
                child: const Text('Next'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  // Navigate to progress screen for submission
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const QuizProgressScreen(),
                    ),
                  );
                },
                child: const Text('Submit Quiz'),
              ),
          ],
        ),
      ],
    );
  }
}
