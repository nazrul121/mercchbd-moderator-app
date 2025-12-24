import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/query-page/FullOrderQuery.dart';

class OrderList extends StatefulWidget {
  const OrderList({super.key});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {

  @override
  Widget build(BuildContext context) {
    bool _isLoggedIn = false;

    return Scaffold(
      appBar: buildCustomAppBar(context, 'orders', _isLoggedIn),
      body: SingleChildScrollView(
        child: Column(
          children: [
            OrderQuery()
          ],
        ),
      ),
      bottomNavigationBar: Footer(),
    );
  }
}
