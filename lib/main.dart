import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:selamkapisi/dashboard.dart';
import 'package:selamkapisi/login.dart';
import 'package:selamkapisi/profile/profile.dart';
import 'package:selamkapisi/signup.dart';
import 'package:selamkapisi/forgot_password.dart';
import 'package:selamkapisi/tasks/tasks.dart';

import 'fatwa/fatwa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selam Kapısı',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Define your routes here
      routes: {
        '/': (context) => AuthWrapper(),
        '/login': (context) => LogIn(),
        '/signup': (context) => SignUp(),
        '/forgot-password': (context) => ForgotPassword(),
        '/dashboard': (context) => Dashboard(),
        '/fatwa': (context) => FatwaPage(), // Yeni eklenen
        '/tasks': (context) => TasksPage(),  // Yeni eklenen
        '/profile': (context) => ProfilePage(), // Yeni eklenen
      },
      // Optional: Handle unknown routes
      onGenerateRoute: (settings) {
        // Handle unexpected routes
        return MaterialPageRoute(
          builder: (context) => const LogIn(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LogIn();
          }
          return Dashboard(); // Changed from Home() to Dashboard()
        }
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}