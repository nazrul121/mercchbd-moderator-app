import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../includes/CustomSearchableDropdown.dart';

class AddressForm extends StatefulWidget {
  const AddressForm({super.key});

  @override
  AddressFormState createState() => AddressFormState(); // Removed underscore
}

// 2. Remove the underscore from the Class name
class AddressFormState extends State<AddressForm> {
  double deliveryCost = 0.0;

  bool _isShippingSame = true;

  // Locations Data
  List<dynamic> _apiDistricts = []; // Store the 'districts' array from API
  Map<String, dynamic>? _selectedDistrict; // Store the whole District object
  Map<String, dynamic>? _selectedCity;     // Store the whole City object
  double _deliveryCost = 0.0;

  Map<String, dynamic>? _selectedShipDistrict; // Store the whole District object
  Map<String, dynamic>? _selectedShipThana;

  // Controllers
  final TextEditingController _bNameController = TextEditingController();
  final TextEditingController _bPhoneController = TextEditingController();
  final TextEditingController _bAddressController = TextEditingController();

  final TextEditingController _sNameController = TextEditingController();
  final TextEditingController _sPhoneController = TextEditingController();
  final TextEditingController _sAddressController = TextEditingController();

  Future<void> _fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('https://getmerchbd.com/api/districts'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _apiDistricts = data['districts'];
          debugPrint("${_apiDistricts}");
        });
      }
    } catch (e) {
      debugPrint("Error fetching locations: $e");
    }
  }

  void _sendDataToParent() {
    widget.onDataChanged({
      'deliveryCost': _deliveryCost,
      'billingDistrict': _selectedDistrict,
      'billingCity': _selectedCity,
      'billingAddress': _bAddressController.text,
      'isShippingSame': _isShippingSame,
      // Add other fields as needed
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(_isShippingSame) SizedBox(height: 30,),

        _buildSectionHeader(Icons.account_balance_wallet, "Billing Information"),
        const SizedBox(height: 15),
        _buildTextField(_bNameController, "Full Name"),
        const SizedBox(height: 10),
        _buildTextField(_bPhoneController, "Phone No"),
        const SizedBox(height: 10),

        // Billing Dropdowns
        Row(
          children: [
            Expanded(
              child: CustomSearchableDropdown<Map<String, dynamic>>(
                label: "District",
                items: _apiDistricts.cast<Map<String, dynamic>>(),
                selectedItem: _selectedDistrict,
                itemLabelBuilder: (item) => item['name'] ?? '',
                onSelected: (val) {
                  setState(() {
                    _selectedDistrict = val;
                    _selectedCity = null; // Reset child
                    _deliveryCost = double.tryParse(val?['delivery_cost'].toString() ?? '0') ?? 0.0;
                  });
                  _sendDataToParent();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
                  child: CustomSearchableDropdown<Map<String, dynamic>>(
                    label: "City",
                    enabled: _selectedDistrict != null,
                    items: (_selectedDistrict?['cities'] as List? ?? []).cast<Map<String, dynamic>>(),
                    selectedItem: _selectedCity,
                    itemLabelBuilder: (item) => item['name'] ?? '',
                    onSelected: (val) {
                      setState(() {
                        _selectedCity = val;
                        // Access nested zone delivery cost
                        if (val != null && val['zones'] != null && (val['zones'] as List).isNotEmpty) {
                          _deliveryCost = double.tryParse(val['zones'][0]['delivery_cost'].toString() ?? '0') ?? 0.0;
                        }
                      });
                    },
                  ),
                ),
          ],
        ),
        if (_deliveryCost != 0.0 && _selectedCity != null && _isShippingSame==true)
          Text("Delivery Cost for ${_selectedCity?['name']} : ৳${_deliveryCost.toString()}",
            style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
          ),

        const SizedBox(height: 10),
        _buildTextField(_bAddressController, "Street Address"),

        const SizedBox(height: 15),

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text("Shipping address is same as billing"),
          value: _isShippingSame,
          activeColor: Colors.orange,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (val) => setState(() => _isShippingSame = val ?? false),
        ),

        // --- SHIPPING SECTION ---
        if (!_isShippingSame) ...[
          const Divider(height: 30),
          _buildSectionHeader(Icons.local_shipping, "Shipping Information"),
          const SizedBox(height: 15),
          _buildTextField(_sNameController, "Recipient Name"),
          const SizedBox(height: 10),
          _buildTextField(_sPhoneController, "Recipient Phone"),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: CustomSearchableDropdown<Map<String, dynamic>>(
                  label: "District",
                  items: _apiDistricts.cast<Map<String, dynamic>>(),
                  selectedItem: _selectedShipDistrict,
                  itemLabelBuilder: (item) => item['name'] ?? '',
                  onSelected: (val) {
                    setState(() {
                      _selectedShipDistrict = val;
                      _selectedShipThana = null; // Reset child
                      _deliveryCost = double.tryParse(val?['delivery_cost'].toString() ?? '0') ?? 0.0;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomSearchableDropdown<Map<String, dynamic>>(
                  label: "City",
                  enabled: _selectedShipDistrict != null,
                  items: (_selectedShipDistrict?['cities'] as List? ?? []).cast<Map<String, dynamic>>(),
                  selectedItem: _selectedShipThana,
                  itemLabelBuilder: (item) => item['name'] ?? '',
                  onSelected: (val) {
                    setState(() {
                      _selectedShipThana = val;
                      // Access nested zone delivery cost
                      if (val != null && val['zones'] != null && (val['zones'] as List).isNotEmpty) {
                        _deliveryCost = double.tryParse(val['zones'][0]['delivery_cost'].toString() ?? '0') ?? 0.0;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_deliveryCost != 0.0 && _selectedShipThana != null)
            Text(
              "Delivery Cost for ${_selectedShipThana?['name']} : ৳${_deliveryCost.toString()}",
              style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
            ),

          const SizedBox(height: 10),
          _buildTextField(_sAddressController, "Shipping Street Address"),
        ],
      ],
    );
  }


  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 22),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
    );
  }
}