import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchbd/includes/loadingWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/utils/auth_guard.dart';

import '../includes/ui_helper.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<dynamic> _payments = [];
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchPaymentData();
  }

  Future<void> _fetchPaymentData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final moderatorString = prefs.getString('moderator');

      if (moderatorString == null) return;

      Map<String, dynamic> moderatorMap = jsonDecode(moderatorString);
      int moderatorId = moderatorMap['id'];

      final url = Uri.parse('https://getmerchbd.com/api/payments/$moderatorId?page=$_currentPage');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Check if data is paginated (data['data']) or a direct list
          _payments = data is List ? data : data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching payments: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return AuthGuard(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildCustomAppBar(context, 'Payments'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Payment History',
                    style: TextStyle(
                      fontFamily: 'Audiowide',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading? LoadingWidget()
             : _payments.isEmpty
                  ? Center(child: Text("No payment history found", style: TextStyle(color:Colors.red.shade300, fontWeight: FontWeight.bold, fontFamily: "Audiowide")))
             : Scrollbar(
                thumbVisibility: true,
                thickness: 6.0,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    child: SizedBox(
                      width: screenWidth > 400 ? screenWidth : 400, // Ensure min width for table
                      child: DataTable(
                        columnSpacing: screenWidth * 0.05,
                        headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
                        columns: const [
                          DataColumn(label: Text('Date', style: TextStyle(fontFamily: 'Audiowide'))),
                          DataColumn(label: Text('Route', style: TextStyle(fontFamily: 'Audiowide'))),
                          DataColumn(label: Text('Amount', style: TextStyle(fontFamily: 'Audiowide'))),
                        ],
                        rows: _payments.map((payment) {
                          // Get the raw date string from the API
                          String rawDate = payment['date'] ?? payment['payment_date'].toString().split('T')[0];

                          return _buildDataRow(
                              formatMyDate(rawDate), // <--- Use the formatter here
                              payment['route'] ?? payment['method'] ?? 'N/A',
                              "৳${payment['amount']}"
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const Footer(),
      ),
    );
  }

  DataRow _buildDataRow(String date, String via, String amount) {
    return DataRow(cells: [
      DataCell(Text(date)),
      DataCell(
          Text(
              via,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)
          )
      ),
      DataCell(
          Text(
              amount,
              style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold
              )
          )
      ),
    ]);
  }
}