import 'package:flutter/material.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/screens/home.dart';
import 'package:merchbd/utils/auth_guard.dart';
import 'package:merchbd/utils/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  String? _error;
  String? _usernameError;
  String? _passwordError;

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
      _usernameError = null;
      _passwordError = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      final url = Uri.parse('https://getmerchbd.com/api/login');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // CRITICAL: Tells the server to talk in JSON
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 20));

      // Log this to your console to see exactly what the server says
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      // ✅ SUCCESS
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Decode ONCE

        // 1. Moderator Check (Uncomment if needed)
        /* if (data['moderator'] == null) {
           setState(() {
             _error = 'Access Denied: Only moderators can logIn';
             _isLoading = false;
           });
           return;
        }
        */

        if (data['status'] == 'success' || data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();

          // Save details
          if (data['token'] != null) await prefs.setString('auth_token', data['token']);
          if (data['user'] != null) {
            final user = data['user'];
            await prefs.setString('user_email', user['email'] ?? '');
            await prefs.setString('user_phone', user['phone'] ?? '');
            await prefs.setInt('user_id', user['id'] ?? 0);
          }

          await prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);

          // CRITICAL: Set this to true BEFORE navigating
          await AuthService.setLoginStatus(true);

          if (!mounted) return;

          // Use pushAndRemoveUntil to prevent "Back" button returning to Login
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AuthGuard(child: HomeScreen())),
                (route) => false,
          );
          return; // Exit function
        }
      }

      // ❌ HANDLE VALIDATION ERRORS (The { "errors": { ... } } structure)
      if (data['errors'] != null) {
        setState(() {
          final errors = data['errors'] as Map<String, dynamic>;
          _usernameError = (errors['username'] != null) ? errors['username'][0] : null;
          _passwordError = (errors['password'] != null) ? errors['password'][0] : null;
          _isLoading = false;
        });
        return;
      }

      // ❌ HANDLE GENERAL MESSAGE (Invalid credentials)
      setState(() {
        _error = data['message']?.toString() ?? 'Invalid username or password.';
        _isLoading = false;
      });

    } catch (e) {
      debugPrint('Login error: $e');
      setState(() {
        _error = 'Connection error. Check your internet.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Closes keyboard when tapping outside
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Gradient
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.orange.shade300, Colors.orange.shade50, Colors.orange.shade600],
                      stops: [0.0, _animationController.value * 0.5, 1.0],
                    ),
                  ),
                );
              },
            ),
            Column(
              children: [
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
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6))],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Fixed Typo in .png
                              Image.asset('assets/logo.png', width: 150),
                              const SizedBox(height: 16),
                              Text(
                                'Welcome Back',
                                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
                              ),
                              const SizedBox(height: 22),

                              // Username Field
                              TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: const OutlineInputBorder(),
                                  errorText: _usernameError, // Shows API error
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              TextField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible, // Toggle based on state
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  // Added suffixIcon for the toggle
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: const OutlineInputBorder(),
                                  errorText: _passwordError,
                                ),
                              ),

                              if (_error != null) ...[
                                const SizedBox(height: 16),
                                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                              ],

                              const SizedBox(height: 24),
                              TextButton(onPressed: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) => const HomeScreen(), // The new page widget
                                  ),
                                );
                              }, child: Text('Go home')),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: _isLoading? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                      SizedBox(width: 12),
                                      Text("Verifying..."),
                                    ],
                                  ) :
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.key_off_outlined, size: 22, color: Colors.white,),
                                      Text(" LOGIN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer()
    );
  }
}