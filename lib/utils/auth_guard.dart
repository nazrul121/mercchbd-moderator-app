import 'package:flutter/material.dart';
import 'package:merchbd/login.dart';
import 'package:merchbd/utils/auth_service.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    bool status = await AuthService.isLoggedIn();
    if (!status) {
      if (!mounted) return;
      // Clear everything and force login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    } else {
      if (mounted) setState(() => _isAuthorized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show nothing or a loader while checking
    if (!_isAuthorized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.child;
  }
}

