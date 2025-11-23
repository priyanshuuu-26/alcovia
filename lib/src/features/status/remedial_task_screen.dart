import 'package:flutter/material.dart';

class RemedialTaskScreen extends StatelessWidget {
  final String task;
  final String? mentorName;

  const RemedialTaskScreen({
    super.key,
    required this.task,
    this.mentorName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Remedial Task")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Task from Mentor",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              task,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (mentorName != null)
              Text("Assigned by: $mentorName", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
