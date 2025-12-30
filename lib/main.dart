import 'package:flutter/material.dart';
import 'package:merchbd/SplashScreen.dart';
import 'package:merchbd/screens/home.dart';
import 'package:merchbd/screens/order/create.dart';
import 'package:merchbd/screens/order/order_list.dart';
import 'package:merchbd/screens/payments.dart';
import 'package:merchbd/screens/profile.dart';
import 'package:merchbd/screens/targets.dart';
import 'package:merchbd/utils/auth_guard.dart';
import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the timezone database
  tz.initializeTimeZones();
  // Set the default location to Bangladesh
  tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

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
      initialRoute: '/home',
      title: 'Merch BD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}