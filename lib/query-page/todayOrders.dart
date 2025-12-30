import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:merchbd/includes/loadingWidget.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/order/order_details.dart';
import 'package:timezone/timezone.dart' as tz;

class TodayOrderList extends StatefulWidget {
  const TodayOrderList({super.key});

  @override
  State<TodayOrderList> createState() => _TodayOrderListState();
}

class _TodayOrderListState extends State<TodayOrderList> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _orders = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
        if (!_isLoading && _hasMore) {
          fetchOrders();
        }
      }
    });
  }

  Future<void> fetchOrders() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      String? moderatorString = prefs.getString('moderator');
      if (moderatorString == null) return;
      Map<String, dynamic> moderatorMap = jsonDecode(moderatorString);
      String url = 'https://getmerchbd.com/api/moderator-orders-today/${moderatorMap['id']}/10?page=$_currentPage';

      final response = await http.get(
        Uri.parse(url),
        headers: { 'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List newItems = data['data'];

        setState(() {
          _orders.addAll(newItems);
          _currentPage++;
          _isLoading = false;
          if (data['next_page_url'] == null) _hasMore = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic> getStatusTheme(int statusId) {
    switch (statusId) {
      case 1: return {'color': Colors.orange, 'icon': Icons.assignment_late};
      case 2: return {'color': Colors.blue, 'icon': Icons.check_circle_outline};
      case 3: return {'color': Colors.purple, 'icon': Icons.sync};
      case 4: return {'color': Colors.indigo, 'icon': Icons.local_shipping};
      case 7: return {'color': Colors.green, 'icon': Icons.done_all};
      case 5:
      case 6: return {'color': Colors.amber.shade900, 'icon': Icons.keyboard_return};
      case 8:
      case 9: return {'color': Colors.red, 'icon': Icons.cancel};
      default: return {'color': Colors.grey, 'icon': Icons.help_outline};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 15, 16, 10),
          child: Row(
            children: [
              Icon(Icons.today, size: 18, color: Colors.orange),
              SizedBox(width: 8),
              Text("Today's Reference Orders",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),

         _orders.isEmpty && !_isLoading ?
         const Center(
             child: Text("No orders found for today",
                 style: TextStyle(color:Colors.red, fontWeight: FontWeight.bold, fontFamily: "Audiowide")
             )
         ) :
         ListView.builder(
           controller: _scrollController,
           shrinkWrap: true,
           physics: const NeverScrollableScrollPhysics(),

           itemCount: _orders.length + (_hasMore ? 1 : 0),
           itemBuilder: (context, index) {
             if (index < _orders.length) {
               final order = _orders[index];

               String formattedDate = "";
               try {
                 // 1. Parse the string from Laravel
                 DateTime utcTime = DateTime.parse(order['created_at'].toString());
                 // 2. Convert to the App's Local Timezone (Asia/Dhaka)
                 var bdTime = tz.TZDateTime.from(utcTime, tz.local);
                 // 3. Format it
                 formattedDate = DateFormat('dd MMM, hh:mm a').format(bdTime);
               } catch (e) {
                 formattedDate = order['order_date'].toString();
               }

               int statusId = int.tryParse(order['order_status_id'].toString()) ?? 0;
               var theme = getStatusTheme(statusId);

               return InkWell(
                 onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetails(order: order)));
                 },
                 child: Card(
                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                   elevation: 1,
                   child: ListTile(
                     title: Text("Invoice #${order['invoice_id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                     subtitle: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text("${order['first_name']} ${order['last_name']}"),
                         const SizedBox(height: 4),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                           decoration: BoxDecoration(
                               color: theme['color'].withOpacity(0.1),
                               borderRadius: BorderRadius.circular(4),
                               border: Border.all(color: theme['color'])
                           ),
                           child: Text(
                             order['order_status']?['title'] ?? 'N/A',
                             style: TextStyle(color: theme['color'], fontSize: 11, fontWeight: FontWeight.bold),
                           ),
                         ),
                       ],
                     ),
                     trailing: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       crossAxisAlignment: CrossAxisAlignment.end,
                       children: [
                         Text("৳${order['total_cost']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
                         Text(formattedDate, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                       ],
                     ),
                   ),
                 ),
               );
             } else {
               return const Padding(
                 padding: EdgeInsets.all(15),
                 child: LoadingWidget(),
               );
             }
           },
         ),

      ],
    );
  }
}