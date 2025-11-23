import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_service.dart';
import 'status_controller.dart';

class LockedScreen extends ConsumerWidget {
  const LockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusState = ref.watch(statusControllerProvider);

    return PopScope(          
      canPop:false,
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
                    ? const CircularProgressIndicator()
                    : _buildLockedContent(context, ref, statusState),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLockedContent(
      BuildContext context, WidgetRef ref, StatusState statusState) {
    if (statusState.state == StudentAppState.remedial) {
      // When mentor assigns task → UI will change automatically
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Remedial Task Assigned',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            statusState.task ?? '',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(statusControllerProvider.notifier).markTaskComplete();
              },
              child: const Text('Mark Complete'),
            ),
          ),
        ],
      );
    }

    // Locked state 
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Analysis in progress.\nWaiting for mentor...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        const Text(
          'A mentor is reviewing your quiz performance.\nPlease wait.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ref.read(statusControllerProvider.notifier).refreshStatus();
            },
            child: const Text('Refresh Status'),
          ),
        ),
      ],
    );
  }
}
