import 'package:flutter/material.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/screens/home.dart';
import 'package:merchbd/utils/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // 1. Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // 2. Simple Validation Check
    if (username == 'nazrul' && password == '123') {

      // 3. Use your Global AuthService instead of manual SharedPreferences
      await AuthService.setLoginStatus(true);

      // Optional: If you still need to track login time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);

      if (!mounted) return;

      // 4. Navigate and clear stack so user can't "Go Back" to login
      Navigator.pushAndRemoveUntil(
        context,  MaterialPageRoute(builder: (_) => const HomeScreen()),(route) => false,
      );
    } else {
      setState(() {
        _error = 'Invalid username or password';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Your existing AnimatedBuilder for gradient background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade700,
                      Colors.blue.shade50,
                      Colors.blue.shade300,
                      Colors.blue.shade500,
                    ],
                    stops: [
                      0.0,
                      _animationController.value * 0.5,
                      _animationController.value * 0.9,
                      1.0,
                    ],
                  ),
                ),
              );
            },
          ),

          // Main content and footer inside a Column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Center content
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.network(
                              'https://zeroinfosys.com/images/logo/logo.pnhg',
                              fit: BoxFit.cover,
                              errorBuilder: (
                                BuildContext context,
                                Object exception,
                                StackTrace? stackTrace,
                              ) {
                                return Image.asset('assets/logo.png', height: 30);
                              },
                            ),

                            Text(
                              '\nPlease Login',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColorDark,
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                              autofillHints: null,
                              enableSuggestions: false,
                              autocorrect: false,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                prefixIcon: Icon(Icons.lock_outline),
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              autofillHints: null,
                              enableSuggestions: false,
                              autocorrect: false,
                            ),
                            const SizedBox(height: 24),
                            if (_error != null)
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            if (_error != null) const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        )
                                        : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.lock_open_outlined),
                                            Text(
                                              'Login',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Footer(),
            ],
          ),
        ],
      ),
    );
  }
}
