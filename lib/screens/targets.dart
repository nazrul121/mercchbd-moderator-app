import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchbd/includes/loadingWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/utils/auth_guard.dart';

import '../includes/ui_helper.dart';

class TargetScreen extends StatefulWidget {
  const TargetScreen({super.key});

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  List<dynamic> _targets = [];
  bool _isLoading = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchTargetData();
  }

  Future<void> _fetchTargetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final moderatorString = prefs.getString('moderator');

      if (moderatorString == null) return;

      Map<String, dynamic> moderatorMap = jsonDecode(moderatorString);
      int moderatorId = moderatorMap['id'];

      final url = Uri.parse('https://getmerchbd.com/api/targets/$moderatorId?page=$_currentPage');

      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Adjust this key based on your actual API response structure (e.g., data['data'])
          _targets = data is List ? data : data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching targets: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: buildCustomAppBar(context, 'target'),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('My Targets',
                    style: TextStyle(fontFamily: 'Audiowide', fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _isLoading? const LoadingWidget()
            : _targets.isEmpty ? Center(child: Text("No targets found", style: TextStyle(color:Colors.red.shade300, fontWeight: FontWeight.bold, fontFamily: "Audiowide")))
            : Expanded( // Wrap in Expanded to allow scrolling
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 6.0,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
                          columns: const [
                            DataColumn(label: Text('Month')),
                            DataColumn(label: Text('Monthly Pay')),
                            DataColumn(label: Text('Per Order')),
                            DataColumn(label: Text('Target')),
                          ],
                          rows: _targets.map((item) {
                            return _buildDataRow(
                              formatTargetMonth(item['month_for']),
                              "৳${item['monthly_pay']?.toString() ?? '0'}",
                              "৳${item['per_order_pay']?.toString() ?? '0'}",
                              "${item['target_order']?.toString() ?? '0'} Orders",
                            );
                          }).toList(),

                        ),
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

  DataRow _buildDataRow(String month, String monthly, String perOrder, String target) {
    return DataRow(cells: [
      DataCell(Text(month)),
      DataCell(Text(monthly, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
      DataCell(Text(perOrder)),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(target, style: const TextStyle(fontSize: 12)),
      )),
    ]);
  }
}