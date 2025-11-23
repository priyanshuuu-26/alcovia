import 'package:alcovia/src/features/quiz/quiz_controller.dart';
import 'package:alcovia/src/features/status/status_lockscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import '../quiz/quiz_screen.dart';
import '../status/status_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final statusState = ref.watch(statusControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade800,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome, ${authState.name ?? "Student"}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start your daily quiz to track your progress.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  if (statusState.isLoading)
                    const CircularProgressIndicator()
                  else if (statusState.state == StudentAppState.locked)
                    Column(
                      children: [
                        const Text(
                          "Your profile is currently locked.",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LockedScreen(),
                                ),
                              );
                            },
                            child: const Text("View Status"),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(quizControllerProvider.notifier).loadQuiz();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QuizScreen(),
                            ),
                          );
                        },
                        child: const Text("Start Quiz"),
                      ),
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
