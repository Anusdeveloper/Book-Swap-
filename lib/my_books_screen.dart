// my_books_screen.dart

import 'package:flutter/material.dart';

class MyBooksScreen extends StatelessWidget {
  const MyBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Books'),
      ),
      body: const Center(
        child: Text('List of user\'s books goes here'),
      ),
    );
  }
}
