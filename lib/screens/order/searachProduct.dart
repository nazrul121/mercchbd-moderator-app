import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProductSearchAutocomplete extends StatelessWidget {
  final Function(Map<String, dynamic>) onProductSelected;

  const ProductSearchAutocomplete({super.key, required this.onProductSelected});

  Future<Iterable<Map<String, dynamic>>> _searchProducts(String query) async {
    if (query.length < 2) return const Iterable.empty();

    try {

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      // Replace with your actual search endpoint
      debugPrint(token);
      final response = await http.get(
        Uri.parse('https://getmerchbd.com/api/products?q=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint("Response Body: ${response.body}");
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint("Autocomplete Error: $e");
    }
    return const Iterable.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Map<String, dynamic>>(
      // This is what the user sees in the text field after selecting
      displayStringForOption: (option) => option['title'],

      optionsBuilder: (TextEditingValue textEditingValue) {
        return _searchProducts(textEditingValue.text);
      },

      // Customizing the appearance of the dropdown list
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 300,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    leading: option['thumbs'] != null
                        ? Image.network("https://getmerchbd.com/${option['thumbs']}", width: 40)
                        : const Icon(Icons.image),
                    title: Text(option['title']),
                    subtitle: Text("৳${option['sale_price']}"),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },

      onSelected: (selection) {
        // Sends the full product Map back to the parent
        onProductSelected(selection);
      },

      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: "Type product name...",
            prefixIcon: const Icon(Icons.search, color: Colors.orange),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => controller.clear(),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
          ),
        );
      },
    );
  }
}