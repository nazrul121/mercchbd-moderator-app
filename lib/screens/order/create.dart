import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';

class CreateOrder extends StatefulWidget {
  const CreateOrder({super.key});

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {

  @override
  Widget build(BuildContext context) {
    bool _isLoggedIn = false;

    return Scaffold(
      appBar: buildCustomAppBar(context, 'create-order', _isLoggedIn),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(right: 10,left: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Create Order'),
                  TextButton(
                      onPressed: (){

                      },
                      child: Row(
                        children: [
                          Icon(Icons.shopping_basket), Text(' Order list')
                        ],
                      )
                  )
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Footer(),
    );
  }
}
