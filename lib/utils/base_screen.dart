import 'package:flutter/material.dart';
import 'package:merchbd/login.dart';
import 'package:merchbd/utils/auth_service.dart';

abstract class BaseScreenState<T extends StatefulWidget> extends State<T> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    bool status = await AuthService.isLoggedIn();
    if (!status) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    } else {
      setState(() => isLoading = false);
    }
  }
}