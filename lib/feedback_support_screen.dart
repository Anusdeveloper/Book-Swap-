// feedback_support_screen.dart

import 'package:flutter/material.dart';

class FeedbackSupportScreen extends StatelessWidget {
  const FeedbackSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback & Support'),
      ),
      body: const Center(
        child: Text('This is the Feedback and Support screen.'),
      ),
    );
  }
}
