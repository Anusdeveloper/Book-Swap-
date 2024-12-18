// past_events_screen.dart

import 'package:flutter/material.dart';

class PastEventsScreen extends StatelessWidget {
  const PastEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Events'),
      ),
      body: const Center(
        child: Text('Past events will be listed here.'),
      ),
    );
  }
}
