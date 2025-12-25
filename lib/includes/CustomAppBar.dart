import 'package:flutter/material.dart';
import 'package:merchbd/login.dart';
import 'package:merchbd/screens/home.dart';
import 'package:merchbd/screens/order/create.dart';
import 'package:merchbd/screens/order/order_list.dart';
import 'package:merchbd/screens/payments.dart';
import 'package:merchbd/screens/profile.dart';
import 'package:merchbd/screens/targets.dart';
import 'package:merchbd/utils/auth_service.dart';

PreferredSizeWidget buildCustomAppBar(BuildContext context, String title) {

  // Logic to handle logout
  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false, // Clears the entire navigation history
      );
    }
  }

  return AppBar(
    // Show back arrow only if we aren't on Home AND can actually go back
    automaticallyImplyLeading: title.toLowerCase() != 'home',
    title: Text('Merch BD',style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
    actions: [
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_outlined, size: 28, color: Colors.orangeAccent),
        onSelected: (value) {
          switch (value) {
            case 'home':
              if (title.toLowerCase() != 'home') {
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } break;
            case 'create-order':
              if (title.toLowerCase() != 'create-order') {
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const CreateOrder()),
                );
              }  break;

            case 'orders':
              if (title.toLowerCase() != 'orders') {
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const OrderList()),
                );
              }  break;
            case 'targets':
              if (title.toLowerCase() != 'targets') {
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const TargetScreen()),
                );
              }  break;

            case 'payments':
              if (title.toLowerCase() != 'payments') {
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const PaymentScreen()),
                );
              }  break;

            case 'profile':
              if (title.toLowerCase() != 'profile') {
                Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const Profile()),
                );
              }  break;

            case 'logout':
              _handleLogout();
              break;
            case 'login':
              Navigator.push(
                context, MaterialPageRoute(builder: (_) => const LoginPage()),
              );
              break;
          }
        },

        itemBuilder: (BuildContext context) => [
          const PopupMenuItem<String>(
            value: 'home', height: 40,
            child: Row(
              children: [
                Icon(Icons.home_rounded, size: 18),
                SizedBox(width: 8),
                Text('Home'),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),

          const PopupMenuItem<String>(
            value: 'create-order', height: 40,
            child: Row(
              children: [
                Icon(Icons.add_box, size: 18),
                SizedBox(width: 8),
                Text('Create an order'),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),

          const PopupMenuItem<String>(
            value: 'orders', height: 40,
            child: Row(
              children: [
                Icon(Icons.shopping_cart_outlined, size: 18),
                SizedBox(width: 8),
                Text('My Orders'),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),

          const PopupMenuItem<String>(
            value: 'targets', height: 40,
            child: Row(
              children: [
                Icon(Icons.check_box_outlined, size: 18),
                SizedBox(width: 8),
                Text('My Targets'),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),

          const PopupMenuItem<String>(
            value: 'payments', height: 40,
            child: Row(
              children: [
                Icon(Icons.payments_outlined, size: 18),
                SizedBox(width: 8),
                Text('My Payments'),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),

          const PopupMenuItem<String>(
            value: 'profile', height: 40,
            child: Row(
              children: [
                Icon(Icons.manage_accounts_outlined, size: 18),
                SizedBox(width: 8),
                Text('My Profile'),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),

          // Conditional Menu Item based on auth status
          const PopupMenuItem<String>(
            value: 'logout', height: 40,
            child: Row(
              children: [
                Icon(Icons.logout_outlined, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Logout', style: TextStyle(color: Colors.red)),
              ],
            ),
          )
        ],
      ),
    ],
  );
}