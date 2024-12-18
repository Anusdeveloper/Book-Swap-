import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'firebase_options.dart'; // Ensure you generate this file using FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const BookSwapApp());
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
    runApp(const InitializationErrorApp());
  }
}

class BookSwapApp extends StatelessWidget {
  const BookSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookSwap Hub',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// Fallback app if Firebase initialization fails
class InitializationErrorApp extends StatelessWidget {
  const InitializationErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Initialization Error')),
        body: const Center(
          child: Text(
            'Failed to initialize Firebase. Please restart the app or check your configuration.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
