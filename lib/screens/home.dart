import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/query-page/todayOrders.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Since AuthGuard handles the redirect, we know isLoggedIn is true here
      appBar: buildCustomAppBar(context, 'Home', true),

      body: SingleChildScrollView(
        child: Column(
          children: [
            TodayOrderList(),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}