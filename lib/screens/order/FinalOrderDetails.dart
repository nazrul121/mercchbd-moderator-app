import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FinalOrderDetails extends StatefulWidget {
  final TextEditingController discountController;
  final TextEditingController noteController;

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
    required this.noteController,
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
          'Authorization': 'Bearer $token','Accept': 'application/json',
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
    double discount = double.tryParse(widget.discountController.text) ?? 0.0;
    double grandTotal = (widget.subtotal + widget.shippingCost) - discount;

    if (widget.noteController.text.isEmpty) {
      widget.noteController.text = "Extra";
    }

    // Check if we should show the note field based on discount input
    bool showNoteField = widget.discountController.text.isNotEmpty &&
        widget.discountController.text != '0';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Final Preview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // --- DISCOUNT & NOTE ROW ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Discount Field
              Expanded(
                child: TextFormField(
                  controller: widget.discountController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    // Trigger rebuild to show/hide Note field
                    setState(() {});
                    widget.onDiscountChanged();
                  },
                  decoration: const InputDecoration(
                    labelText: "Discount",
                    prefixText: "৳",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),

              // 2. Note Field - Becomes visible only when discount has value
              if (showNoteField) ...[
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: widget.noteController,
                    decoration: const InputDecoration(
                      labelText: "Discount Note",
                      hintText: "Reason for discount",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 15),

          // 3. Order Source Dropdown (Now in its own row or full width)
          DropdownButtonFormField<String>(
            value: widget.orderSource,
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
            onChanged: (val) => widget.onSourceChanged(val!),
          ),

          const SizedBox(height: 15),

          // 4. Payment Gateway Dropdown (API Loaded)
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

          // 5. Summary Row Section
          Column(
            children: [
              _summaryRow("Subtotal:", "৳${widget.subtotal}"),
              _summaryRow("Shipping to:", widget.city),
              _summaryRow("Shipping Charge:", "৳${widget.shippingCost}"),
              _summaryRow("Discount:", "-৳$discount", color: Colors.red),
              const Divider(height: 30),
              _summaryRow(
                  "Grand Total:", "৳${grandTotal < 0 ? 0 : grandTotal.toStringAsFixed(2)}",
                  isBold: true, color: Colors.green
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
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to top if it wraps
        children: [
          // Wrap Label in Expanded
          Expanded(
            flex: 2, // Takes 2/5 of space
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ),
          const SizedBox(width: 10), // Add some spacing between them
          // Wrap Value in Expanded
          Expanded(
            flex: 3, // Takes 3/5 of space
            child: Text(
              value,
              textAlign: TextAlign.end, // Keeps value pushed to the right
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? Colors.black
              ),
            ),
          ),
        ],
      ),
    );
  }
}