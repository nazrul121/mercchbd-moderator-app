import 'package:flutter/material.dart';

class TodayOrderList extends StatelessWidget {
  const TodayOrderList({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data - later you can fetch this from an API
    final List<Map<String, String>> orders = [
      {'id': '101', 'item': 'T-Shirt Print', 'status': 'Pending', 'price': '\$25'},
      {'id': '102', 'item': 'Custom Hoodie', 'status': 'Shipped', 'price': '\$45'},
      {'id': '103', 'item': 'Cotton Polo', 'status': 'Processing', 'price': '\$30'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            "Today's Orders",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true, // Important: allows it to work inside a Column
          physics: const NeverScrollableScrollPhysics(), // Let the main page scroll
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
                title: Text("Order #${order['id']}"),
                subtitle: Text("${order['item']} - ${order['status']}"),
                trailing: Text(
                  order['price']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}