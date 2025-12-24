import 'dart:async';
import 'package:flutter/material.dart';
import 'package:merchbd/login.dart'; // Make sure this is imported
import 'package:merchbd/screens/home.dart';
import 'package:merchbd/utils/auth_guard.dart';
import 'package:merchbd/utils/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    // Start the fade animation
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _visible = true);
    });

    // Handle navigation after 3 seconds
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      bool isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        // If logged in, go to Home wrapped in Guard
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const AuthGuard(child: HomeScreen()),
        ));
      } else {
        // Otherwise, go straight to Login
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TweenAnimationBuilder(
        tween: ColorTween(begin: const Color(0xFF7E4F00), end: const Color(0xD0E89810)),
        duration: const Duration(seconds: 3),
        builder: (context, Color? color, child) {
          return Container(
            color: color,
            child: Center(
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(seconds: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logo.png', width: 160),
                    const SizedBox(height: 20),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Live in the Moment",
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white.withAlpha(180),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}