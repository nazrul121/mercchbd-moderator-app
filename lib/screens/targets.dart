import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/utils/auth_guard.dart';


class TargetScreen extends StatelessWidget {
  const TargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        // Since AuthGuard handles the redirect, we know isLoggedIn is true here
        appBar: buildCustomAppBar(context, 'target'),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'My Targets',
                    style: TextStyle(
                      fontFamily: 'Audiowide',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Scrollbar(
                thumbVisibility: true,
                thickness: 6.0,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
                          columns: const [
                            DataColumn(label: Text('Month')),
                            DataColumn(label: Text('Monthly Pay')),
                            DataColumn(label: Text('Per Order')),
                            DataColumn(label: Text('Target')),
                          ],
                          rows: [
                            _buildDataRow('January', '৳5,000', '৳50', '100 Orders'),
                            _buildDataRow('February', '৳6,000', '৳60', '120 Orders'),
                            _buildDataRow('March', '৳5,500', '৳55', '110 Orders'),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
            )
          ]
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