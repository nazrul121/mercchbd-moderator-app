import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/utils/auth_guard.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return AuthGuard(
      child: Scaffold(
        backgroundColor: Colors.white, // Changed to white for seamless 100% look
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

            // Use Expanded or flexible to let the table take space
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 6.0,
                
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Allow vertical scrolling
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal:5, vertical: 0),
                    child: SizedBox(
                      width: screenWidth, // Forces the container to screen width
                      child: DataTable(
                        // horizontalMargin: 16, // Padding inside the table
                        columnSpacing: screenWidth * 0.1, // Distribute spacing based on screen
                        headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
                        // Force columns to distribute 100%
                        columns: const [
                          DataColumn(label: Expanded(child: Text('Date', style: TextStyle(fontFamily: 'Audiowide')))),
                          DataColumn(label: Expanded(child: Text('Route', style: TextStyle(fontFamily: 'Audiowide')))),
                          DataColumn(label: Expanded(child: Text('Amount', style: TextStyle(fontFamily: 'Audiowide')))),
                        ],
                        rows: [
                          _buildDataRow('10/12/2024', 'bKash', '৳5,000'),
                          _buildDataRow('11/12/2024', 'Rocket', '৳2,500'),
                          _buildDataRow('12/12/2024', 'Nagad', '৳3,200'),
                          _buildDataRow('13/12/2024', 'Bank', '৳10,000'),
                        ],
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