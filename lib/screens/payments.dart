import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';


class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Since AuthGuard handles the redirect, we know isLoggedIn is true here
      appBar: buildCustomAppBar(context, 'payments', true),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Text('Payment Screen'),
            )
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}