import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:selamkapisi/coach/coach.dart';
import 'package:selamkapisi/dashboard.dart';
import 'package:selamkapisi/login.dart';
import 'package:selamkapisi/profile/profile.dart';
import 'package:selamkapisi/signup.dart';
import 'package:selamkapisi/forgot_password.dart';
import 'package:selamkapisi/fatwa/fatwa.dart';
import 'package:selamkapisi/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      // Ana route'u kaldırdık ve sadece home kullanıyoruz
      home: const SplashScreen(),
      routes: {
        // '/' route'unu kaldırdık
        '/login': (context) => const LogIn(),
        '/signup': (context) => const SignUp(),
        '/forgot-password': (context) => const ForgotPassword(),
        '/dashboard': (context) => const Dashboard(),
        '/fatwa': (context) => const FatwaPage(),
        '/profile': (context) => const ProfilePage(),
        '/coach': (context) => const CoachPage(),
      },
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const LogIn(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward().then((_) {
      // Doğrudan AuthWrapper'a yönlendiriyoruz
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arkaplan Kabe Resmi
          Image.asset(
            'assets/images/minare.jpg',
            fit: BoxFit.cover,
          ),

          // Koyu overlay
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // Logo Animasyonu
          // Logo Animasyonu
          Center(
            child: AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFFFD700), // Altın rengi
                      BlendMode.srcIn,
                    ),
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/selam_kapisi_logo.png',
                width: MediaQuery.of(context).size.width * 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const LogIn();
          }

          _initializeUserData(user);

          return const Dashboard();
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<void> _initializeUserData(User user) async {
    final firestore = FirebaseFirestore.instance;
    final userDoc = await firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      await firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'prayerCount': 0,
        'quranPages': 0,
        'charityAmount': 0,
        'socialPoints': 0,
        'totalScore': 0,
      });
    }
  }
}