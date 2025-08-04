import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/loading.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() {
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration(seconds: 5),
      () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingScreen();
                  }

                  if (snapshot.hasData) {
                    return const ChatScreen();
                  }

                  return const AuthScreen();
                },
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      body: Center(
        child: SizedBox(
          height: 350,
          width: 400,
          child: Lottie.asset(
            'assets/animations/chat_logo.json',
            fit: BoxFit.contain,
            repeat: true,
            filterQuality: FilterQuality.high,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
