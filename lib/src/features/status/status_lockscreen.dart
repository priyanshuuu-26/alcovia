import 'package:alcovia/src/features/status/remedial_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import 'status_controller.dart';
import '../home/home_screen.dart';

class LockedScreen extends ConsumerWidget {
  const LockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusState = ref.watch(statusControllerProvider);
    final auth = ref.watch(authControllerProvider);

    /// Auto navigation when mentor updates status
  ref.listen(statusControllerProvider, (prev, next) {
  if (!context.mounted) return;

  // 🔹 show error when refresh failed
  if (next.error != null && next.error!.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(next.error!)),
    );
  }

  // Mentor cleared profile → go to Home
  if (next.state == StudentAppState.normal) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
    return;
  }

  // Navigate to Remedial only if task exists
  final hasRemedialTask =
      next.state == StudentAppState.remedial &&
      next.task != null &&
      next.task!.trim().isNotEmpty;

  if (hasRemedialTask) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RemedialTaskScreen(
          task: next.task!,
          mentorName: next.mentorName,
        ),
      ),
    );
  }
});

    return PopScope(
      canPop: false, // prevent user from exiting exam result lock
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: statusState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _lockedContent(context, ref, statusState, auth.email),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _lockedContent(
    BuildContext context,
    WidgetRef ref,
    StatusState statusState,
    String? email,
  ) {
    if (email == null) {
      return const Text(
        "Email is missing",
        textAlign: TextAlign.center,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Your profile is locked\nMentor review in progress',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'Please wait while your quiz performance is reviewed.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: statusState.isLoading
                ? null
                : () {
                    ref
                        .read(statusControllerProvider.notifier)
                        .refreshStatus(email);
                  },
            child: const Text("Refresh Status"),
          ),
        ),
      ],
    );
  }
}
