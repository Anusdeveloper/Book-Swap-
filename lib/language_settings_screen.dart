// language_settings_screen.dart

import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
      ),
      body: const Center(
        child: Text('Language settings will be here.'),
      ),
    );
  }
}
