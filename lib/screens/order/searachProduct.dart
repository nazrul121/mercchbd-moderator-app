import 'dart:io';
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
  TextEditingController? _searchController;
  Map<String, dynamic>? _pendingProduct;
  String? _selectedCombinationId;

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
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } on SocketException {
      debugPrint("No Internet connection");
    } catch (e) {
      debugPrint("Autocomplete Error: $e");
    }
    return const Iterable.empty();
  }

  void _handleProductSelection(Map<String, dynamic> product) {
    List combinations = product['product_combinations'] ?? [];
    if (combinations.isEmpty) {
      widget.onProductAdded(product);
      _clearSearch();
    } else {
      setState(() {
        _pendingProduct = product;
        _selectedCombinationId = null; // IMPORTANT: Reset the ID for the new product
      });
    }
  }

  void _clearSearch() {
    _searchController?.clear();
    setState(() {
      _pendingProduct = null;
      _selectedCombinationId = null;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Search Field (Keep your existing Autocomplete here)
        Autocomplete<Map<String, dynamic>>(
          displayStringForOption: (option) => option['title'],
          optionsBuilder: (value) => _searchProducts(value.text),
          onSelected: _handleProductSelection,
          // ... (keep optionsViewBuilder and fieldViewBuilder same as your code)
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        leading: Image.network(
                          "https://getmerchbd.com/${option['thumbs']}",
                          width: 40,
                          errorBuilder: (c, e, s) => const Icon(Icons.image),
                        ),
                        title: Text(option['title']),
                        subtitle: Text("MRP: ৳${option['sale_price']}"),
                        onTap: () => onSelected(option),
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

        // 2. Variation Selection UI
        if (_pendingProduct != null) ...[
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select Variation for: ${_pendingProduct!['title']}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  key: ValueKey("dropdown_${_pendingProduct!['id']}"),
                  isExpanded: true,
                  hint: const Text("Choose Size/Color"),
                  value: _selectedCombinationId,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, filled: true, fillColor: Colors.white),
                  items: (_pendingProduct!['product_combinations'] as List).map((comb) {
                    return DropdownMenuItem<String>(
                      value: comb['id'].toString(),
                      child: Text(
                        "${comb['combination_string'].toString().replaceAll('~', ' ').toUpperCase()} (Stock: ${comb['qty']})",
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCombinationId = val),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _clearSearch,
                        child: const Text("Cancel")
                    ),
                    ElevatedButton(
                      onPressed: _selectedCombinationId == null ? null : () {
                        // 1. Get the list of combinations
                        final List combinations = _pendingProduct!['product_combinations'] ?? [];

                        // 2. Find the selected map using the ID from the dropdown
                        final selectedMap = combinations.firstWhere(
                              (c) => c['id'].toString() == _selectedCombinationId,
                          orElse: () => {},
                        );

                        if (selectedMap.isNotEmpty) {
                          // 3. Create a NEW map so we don't modify the original list reference
                          final Map<String, dynamic> productToAdd = Map<String, dynamic>.from(_pendingProduct!);

                          // 4. ATTACH THE DATA (Ensure keys match exactly what the UI looks for)
                          productToAdd['selected_variation'] = selectedMap;
                          productToAdd['variation_option_id'] = _selectedCombinationId;
                          productToAdd['quantity'] = 1; // Default quantity

                          debugPrint("Adding to cart: ${productToAdd['title']} with Variation: ${selectedMap['combination_string']}");

                          // 5. Send to parent
                          widget.onProductAdded(productToAdd);
                          // 6. Reset
                          _clearSearch();
                        }
                      },
                      child: const Text("Add to Order"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.shopping_basket_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text("Order Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(),

        // 3. The List of Added Items
        widget.orderItems.isEmpty
            ? const Padding(padding: EdgeInsets.all(20), child: Text("No products added yet"))
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.orderItems.length,
          itemBuilder: (context, index) {
            final item = widget.orderItems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Image.network(
                  "https://getmerchbd.com/${item['thumbs']}",
                  width: 40,
                  errorBuilder: (c, e, s) => const Icon(Icons.image),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),

                    if (item['selected_variation'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item['selected_variation']['combination_string'].replaceAll('~',', ').toString(),
                        style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ] else ...[
                      // This helps you see if the data is missing
                      const Text("No variation selected", style: TextStyle(fontSize: 10, color: Colors.red)),
                    ],
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Text("৳${item['sale_price']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 15),
                      _buildQtyToggle(item),
                    ],
                  ),
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
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(5),
      ),
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