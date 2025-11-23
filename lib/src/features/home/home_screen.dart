import 'package:alcovia/src/api/api_service.dart';
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
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          )
        ],
      ),
      backgroundColor: Colors.grey.shade100,
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
                    'Welcome, ${authState.name ?? 'Student'}',
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
                  else if (statusState.state == StudentAppState.locked ||
                      statusState.state == StudentAppState.remedial)
                    Column(
                      children: [
                        const Text(
                          'Your account is currently locked or in remedial state.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LockedScreen(),
                                ),
                              );
                            },
                            child: const Text('View Status'),
                          ),
                        )
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const QuizScreen(),
                            ),
                          );
                        },
                        child: const Text('Start Quiz'),
                      ),
                    ),
                  const SizedBox(height: 12),
                  // TextButton(
                  //   onPressed: () {
                  //     ref.read(statusControllerProvider.notifier).refreshStatus();
                  //   },
                  //   child: const Text('Refresh Status'),
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
