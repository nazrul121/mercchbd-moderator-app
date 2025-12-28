import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FinalOrderDetails extends StatefulWidget {
  final TextEditingController discountController;
  final String orderSource;
  final String paymentGateway;
  final double subtotal;
  final double shippingCost;
  final String city;
  final Function(String) onSourceChanged;
  final Function(String) onPaymentMethodChanged;
  final VoidCallback onDiscountChanged;

  const FinalOrderDetails({
    super.key,
    required this.discountController,
    required this.orderSource,
    required this.paymentGateway,
    required this.subtotal,
    required this.shippingCost,
    required this.city,
    required this.onSourceChanged,
    required this.onPaymentMethodChanged,
    required this.onDiscountChanged,
  });

  @override
  State<FinalOrderDetails> createState() => _FinalOrderDetailsState();
}

class _FinalOrderDetailsState extends State<FinalOrderDetails> {
  List<dynamic> _gateways = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPaymentGateways();
  }

  Future<void> _fetchPaymentGateways() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Update this URL to your actual payment gateways endpoint
      final response = await http.get(
        Uri.parse('https://getmerchbd.com/api/payment-methods'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      debugPrint(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint(response.body);
        setState(() {
          _gateways = data;
          _isLoading = false;
        });

        // If no payment method is selected yet, default to the first one from API
        if (widget.paymentGateway.isEmpty && _gateways.isNotEmpty) {
          widget.onPaymentMethodChanged(_gateways[0]['id'].toString());
        }
      }
    } catch (e) {
      debugPrint("Error fetching gateways: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accessing variables via "widget." prefix
    double discount = double.tryParse(widget.discountController.text) ?? 0.0;
    double grandTotal = (widget.subtotal + widget.shippingCost) - discount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Final Preview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Discount Field
              Expanded(
                child: TextFormField(
                  controller: widget.discountController, // Added widget.
                  keyboardType: TextInputType.number,
                  onChanged: (val) => widget.onDiscountChanged(), // Added widget.
                  decoration: const InputDecoration(
                    labelText: "Discount",
                    prefixText: "৳",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // 2. Order Source Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: widget.orderSource, // Added widget.
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Order Source",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: {
                    'fb': 'Facebook',
                    'web': 'Website',
                    'whatApp': 'WhatsApp',
                    'cell': 'Over phone call',
                    'other': 'Other source'
                  }.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (val) => widget.onSourceChanged(val!), // Added widget.
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Payment Gateway Dropdown (API Loaded)
          _isLoading
              ? const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ))
              : DropdownButtonFormField<String>(
            value: widget.paymentGateway.isEmpty ? null : widget.paymentGateway,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: "Payment gateway",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _gateways.map((gateway) {
              return DropdownMenuItem<String>(
                value: gateway['id'].toString(),
                child: Text(gateway['name'] ?? "Unnamed Gateway"),
              );
            }).toList(),
            onChanged: (val) => widget.onPaymentMethodChanged(val!),
          ),

          const SizedBox(height: 30),

          // 4. Summary Row Section
          Column(
            children: [
              _summaryRow("Subtotal:", "৳${widget.subtotal}"),
              _summaryRow("Shipping to:", widget.city),
              _summaryRow("Shipping Charge:", "৳${widget.shippingCost}"),
              _summaryRow("Discount:", "-৳$discount", color: Colors.red),
              const Divider(height: 30),
              _summaryRow(
                  "Grand Total:",
                  "৳${grandTotal < 0 ? 0 : grandTotal.toStringAsFixed(2)}",
                  isBold: true,
                  color: Colors.green
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.black)),
        ],
      ),
    );
  }
}