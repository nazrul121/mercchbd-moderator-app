import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/login.dart';
import 'package:merchbd/query-page/todayOrders.dart';
import 'package:merchbd/utils/auth_guard.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, String> userInfo = {'email': 'Loading...', 'phone': '...', 'id': '...'};
  String? _loginTime;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      int? timestamp = prefs.getInt('login_time');
      if (timestamp != null) {
        var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        _loginTime = "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
      }
      userInfo = {
        'email': prefs.getString('user_email') ?? 'Not set',
        'phone': prefs.getString('user_phone') ?? 'Not set',
        'id': prefs.getInt('user_id')?.toString() ?? '0',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        backgroundColor: Colors.grey[100], // Light grey background for premium contrast
        appBar: buildCustomAppBar(context, 'Dashboard', true),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quick Actions",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 15),

                    // Grid of Premium Buttons
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.3,
                      children: [
                        _buildMenuCard(Icons.add_shopping_cart, "Create Order", Colors.orange, '/create-order'),
                        _buildMenuCard(Icons.list_alt, "My Ref Orders", Colors.blue, '/ref-orders'),
                        _buildMenuCard(Icons.track_changes, "My Targets", Colors.purple, '/targets'),
                        _buildMenuCard(Icons.payments_outlined, "My Payments", Colors.green, '/payments'),
                        _buildMenuCard(Icons.account_circle_outlined, "Profile", Colors.teal, '/profile'),
                        _buildMenuCard(Icons.logout, "Logout", Colors.red, ''),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 40),
              const TodayOrderList(),
              const SizedBox(height: 100), // Extra space for footer
            ],
          ),
        ),
        bottomNavigationBar: const Footer(),
      )
    );
  }

  // --- Premium Menu Card Widget ---
  Widget _buildMenuCard(IconData icon, String title, Color color,String routeName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (title == 'Logout') {
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              }
              return; // 🔥 CRITICAL: Stops the code here so it doesn't try to navigate below
            }
            Navigator.pushNamed(context, routeName);
            debugPrint("$title clicked");
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Profile Header ---
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.orange.shade100,
            child: Icon(Icons.person, size: 35, color: Colors.orange),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userInfo['email']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                "Phone: ${userInfo['phone']}",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Text("Login Time: ${_loginTime ?? 'Loading...'}"),
            ],
          ),
        ],
      ),
    );
  }
}