import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:intl/intl.dart';

class OrderDetails extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetails({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Format the date safely
    String formattedDate = "";
    try {
      DateTime dt = DateTime.parse(order['order_date'].toString());
      formattedDate = DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      formattedDate = order['order_date'].toString();
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: buildCustomAppBar(context, 'Order Details',),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INVOICE HEADER CARD ---
            _buildHeaderCard(formattedDate),
            const SizedBox(height: 20),

            // --- CUSTOMER & SHIPPING INFO ---
            _buildInfoSection("Customer Info", [
              "Name: ${order['first_name']} ${order['last_name']}",
              "Phone: ${order['phone']}",
              "Email: ${order['email'] ?? 'N/A'}",
              "Address: ${order['address']}",
            ]),
            const SizedBox(height: 20),

            _buildInfoSection("Shipping Info", [
              "Recipient: ${order['ship_first_name']} ${order['ship_last_name']}",
              "Ship Phone: ${order['ship_phone']}",
              "Ship Address: ${order['ship_address']}",
              "City: ${order['ship_city']}, ${order['ship_district']}",
            ]),
            const SizedBox(height: 20),

            // --- ORDER SUMMARY / TOTALS ---
            _buildSummarySection(),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }

  Widget _buildHeaderCard(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            "Invoice #${order['invoice_id']}",
            style: const TextStyle(
              color: Colors.white,  fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Audiowide',
            ),
            cursorColor: Colors.white, // Customizes the selection cursor color
            showCursor: true,          // Shows the cursor when the user taps
          ),
          const SizedBox(height: 5),
          Text("Order Date: $date", style: const TextStyle(color: Colors.white70)),
          const Divider(color: Colors.white24, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Status", style: TextStyle(color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Text("${order['order_status']['title']}",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> details) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
          const Divider(),
          ...details.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(d, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          )),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _summaryRow("Subtotal", "৳${order['total_cost']}"),

          if (double.parse(order['invoice_discount'].toString()) > 0)
            _summaryRow("Invoice Discount", "- ৳${order['invoice_discount']}"),

          _summaryRow("Shipping", "+ ৳${order['shipping_cost']}"),
          const Divider(),
          _summaryRow("Grand Total", "৳${(order['total_cost'] + order['shipping_cost']) - (order['invoice_discount'] - order['discount'])}", isBold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.green : Colors.black)),
        ],
      ),
    );
  }
}