import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductSearchAutocomplete extends StatefulWidget {
  final List<Map<String, dynamic>> orderItems;
  final Function(Map<String, dynamic>) onProductAdded;
  final Function(int) onRemoveItem;
  final VoidCallback onListChanged;

  const ProductSearchAutocomplete({
    super.key,
    required this.orderItems,
    required this.onProductAdded,
    required this.onRemoveItem,
    required this.onListChanged,
  });

  @override
  State<ProductSearchAutocomplete> createState() => _ProductSearchAutocompleteState();
}

class _ProductSearchAutocompleteState extends State<ProductSearchAutocomplete> {
  Future<Iterable<Map<String, dynamic>>> _searchProducts(String query) async {
    if (query.length < 2) return const Iterable.empty();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('https://getmerchbd.com/api/products?q=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint("Autocomplete Error: $e");
    }
    return const Iterable.empty();
  }

  // 1. Create a local variable in your State class
  TextEditingController? _searchController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Search Field
        Autocomplete<Map<String, dynamic>>(
          displayStringForOption: (option) => option['title'],
          optionsBuilder: (value) => _searchProducts(value.text),
          onSelected: (selection) => widget.onProductAdded(selection),
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  height: 300,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);

                      return ListTile(
                        leading: Image.network("https://getmerchbd.com/${option['thumbs']}", width: 40, errorBuilder: (c, e, s) => Icon(Icons.image)),
                        title: Text(option['title']),
                        subtitle: Text("MRP: ৳${option['sale_price']}"),
                        onTap: (){
                          onSelected(option);
                          widget.onProductAdded(option);
                          _searchController?.clear(); // Clear the text
                          FocusScope.of(context).focusedChild;
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            _searchController = controller;

            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: "Type product name...",
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            );
          },
        ),

        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.shopping_basket_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text("Order Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(),

        // 2. The List of Items
        widget.orderItems.isEmpty ? const Padding(padding: EdgeInsets.all(20), child: Text("No products added yet"))
          : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.orderItems.length,
          itemBuilder: (context, index) {
            final item = widget.orderItems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Image.network("https://getmerchbd.com/${item['thumbs']}", width: 40, errorBuilder: (c, e, s) => Icon(Icons.image)),
                title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  children: [
                    Text("৳${item['sale_price']}", style: const TextStyle(color: Colors.green)),
                    const SizedBox(width: 15),
                    _buildQtyToggle(item),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => widget.onRemoveItem(index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQtyToggle(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(5)),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 20, color: Colors.red),
            onPressed: () {
              if (item['quantity'] > 1) {
                setState(() => item['quantity']--);
                widget.onListChanged();
              }
            },
          ),
          Text("${item['quantity']}", style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add, size: 20, color: Colors.green),
            onPressed: () {
              setState(() => item['quantity']++);
              widget.onListChanged();
            },
          ),
        ],
      ),
    );
  }
}