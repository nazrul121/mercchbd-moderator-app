import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/order/order_details.dart';

class OrderQuery extends StatefulWidget {
  const OrderQuery({super.key});

  @override
  State<OrderQuery> createState() => _OrderQueryState();
}

class _OrderQueryState extends State<OrderQuery> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _orders = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  int? _selectedStatusId;

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

  // --- CORRECTED FETCH METHOD ---
  Future<void> fetchOrders() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // 1. Build the dynamic URL
      String url = 'https://getmerchbd.com/api/orders/10?page=$_currentPage';

      // 2. Append the status filter if one is selected
      if (_selectedStatusId != null) {
        url += '&status=$_selectedStatusId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
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

  // Helper for Colors and Icons
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
          padding: EdgeInsets.fromLTRB(16, 10, 16, 5),
          child: Text("My Reference Orders", style: TextStyle(fontSize: 14, color: Colors.grey)),
        ),
        _buildFilterChips(),

        Expanded(
          child: _orders.isEmpty && !_isLoading
              ? const Center(child: Text("No orders found for this status"))
              : ListView.builder(
            controller: _scrollController,
            itemCount: _orders.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _orders.length) {
                final order = _orders[index];

                // Date formatting logic
                String formattedDate = "";
                try {
                  DateTime parsedDate = DateTime.parse(order['order_date'].toString());
                  formattedDate = DateFormat('dd MMM, yyyy').format(parsedDate);
                } catch(e) { formattedDate = order['order_date'].toString(); }

                int statusId = int.tryParse(order['order_status_id'].toString()) ?? 0;
                var theme = getStatusTheme(statusId);

                return InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDetails(order: order)));
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                                color: theme['color'].withOpacity(0.1), // Better design
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
                          Text(formattedDate, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(15),
                  child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final statuses = [
      {'id': null, 'name': 'All'},
      {'id': 1, 'name': 'Placed'},
      {'id': 2, 'name': 'Confirmed'},
      {'id': 3, 'name': 'Processing'},
      {'id': 4, 'name': 'Shipped'},
      {'id': 5, 'name': 'Refund'},
      {'id': 6, 'name': 'Order Returned'},
      {'id': 7, 'name': 'Delivered'},
      {'id': 8, 'name': 'Cancelled'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: statuses.map((status) {
          bool isSelected = _selectedStatusId == status['id'];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(status['name'].toString()),
              selected: isSelected,
              selectedColor: Colors.orange,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedStatusId = status['id'] as int?;
                    _orders.clear();
                    _currentPage = 1;
                    _hasMore = true;
                  });
                  fetchOrders();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}