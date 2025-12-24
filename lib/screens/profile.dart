import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      // Since AuthGuard handles the redirect, we know isLoggedIn is true here
      appBar: buildCustomAppBar(context, 'profile', true),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Text('My profile'),
            )
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}


