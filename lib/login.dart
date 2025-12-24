import 'package:flutter/material.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/screens/home.dart';
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

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    print(username);

    try {
      // 1. Prepare the API URL
      final url = Uri.parse('https://getmerchbd.com/api/login');

      // 2. Make the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15)); // Timeout after 10 seconds

      print(response);

      // 3. Check the Status Code
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check your API's specific success key (e.g., data['success'] or data['status'])
        if (data['status'] == 'success' || data['success'] == true) {

          // Save login status globally
          await AuthService.setLoginStatus(true);

          // Optional: Save user info or token if your API returns one
          final prefs = await SharedPreferences.getInstance();
          if (data['token'] != null) {
            await prefs.setString('auth_token', data['token']);
          }
          await prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);

          if (!mounted) return;

          // Navigate and clear stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
          );
        } else {
          // API returned 200 but the login credentials were wrong
          setState(() {
            _error = data['message'] ?? 'Invalid username or password';
            _isLoading = false;
          });
        }
      } else {
        // Server returned error like 401, 404, or 500
        setState(() {
          _error = 'Server Error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } on TimeoutException {
      setState(() {
        _error = 'Connection timed out. Please try again.';
        _isLoading = false;
      });
    } catch (e) {
      // General error (like no internet)
      setState(() {
        _error = 'An error occurred. Check your connection.';
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
                      Colors.orange.shade300,
                      Colors.orange.shade50,
                      Colors.orange.shade400,
                      Colors.orange.shade600,
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
                                child: _isLoading
                                ? const SizedBox(
                                  height: 24,
                                  // Removed width: 24 to allow the Row to expand
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min, // Shrink to fit children
                                    children: [
                                      SizedBox(
                                        height: 18, width: 18, // Small box for the circle only
                                        child: CircularProgressIndicator(
                                          color: Colors.grey,strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 10), // Space between loader and text
                                      Text('Checking...', style: TextStyle(color: Colors.grey),),
                                    ],
                                  ),
                                )
                                : Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_open_outlined),
                                    Text( 'Login',  style: TextStyle(fontSize: 16) ),
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
