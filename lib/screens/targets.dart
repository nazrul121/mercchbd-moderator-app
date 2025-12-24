import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';


class TargetScreen extends StatelessWidget {
  const TargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Since AuthGuard handles the redirect, we know isLoggedIn is true here
      appBar: buildCustomAppBar(context, 'target', true),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Text('target'),
            )
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}