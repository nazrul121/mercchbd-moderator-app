import 'package:flutter/material.dart';
import 'package:merchbd/SplashScreen.dart';
import 'package:merchbd/screens/home.dart';
import 'package:merchbd/screens/order/create.dart';
import 'package:merchbd/screens/order/order_list.dart';
import 'package:merchbd/screens/payments.dart';
import 'package:merchbd/screens/profile.dart';
import 'package:merchbd/screens/targets.dart';
import 'package:merchbd/utils/auth_guard.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      routes: {
        '/home': (context) => const AuthGuard(child: HomeScreen()),
        '/create-order': (context) => const AuthGuard(child: CreateOrder()), // Create this page
        '/ref-orders': (context) => const AuthGuard(child: OrderList()),
        '/targets': (context) => const AuthGuard(child: TargetScreen()),
        '/payments': (context) => const AuthGuard(child: PaymentScreen()),
        '/profile': (context) => const AuthGuard(child: Profile()),
      },
      title: 'Merch BD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}