import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchbd/includes/loadingWidget.dart';
import '../../includes/CustomSearchableDropdown.dart';

class AddressForm extends StatefulWidget {
  const AddressForm({super.key});

  @override
  AddressFormState createState() => AddressFormState();
}

class AddressFormState extends State<AddressForm> with AutomaticKeepAliveClientMixin {
  // This prevents the data from being cleared when you move to Step 2 or 3
  @override
  bool get wantKeepAlive => true;

  // --- PUBLIC VARIABLES (Parent accesses these via GlobalKey) ---
  double deliveryCost = 0.0;
  bool isShippingSame = true;
  String zone_id = '';

  // Selected Location Objects
  Map<String, dynamic>? selectedDistrict;
  Map<String, dynamic>? selectedCity;
  Map<String, dynamic>? selectedShipDistrict;
  Map<String, dynamic>? selectedShipThana;

  // Controllers
  final TextEditingController bNameController = TextEditingController();
  final TextEditingController bPhoneController = TextEditingController();
  final TextEditingController bAddressController = TextEditingController();

  final TextEditingController sNameController = TextEditingController();
  final TextEditingController sPhoneController = TextEditingController();
  final TextEditingController sAddressController = TextEditingController();

  // Internal API Data
  List<dynamic> _apiDistricts = [];
  bool _isLoading = true;

  Future<void> _fetchLocations() async {
    try {
      final response = await http.get(Uri.parse('https://getmerchbd.com/api/districts'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _apiDistricts = data['districts'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error fetching locations: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: LoadingWidget(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isShippingSame) const SizedBox(height: 20),

        _buildSectionHeader(Icons.account_balance_wallet, "Billing Information"),
        const SizedBox(height: 15),
        _buildTextField(bNameController, "Full Name"),
        const SizedBox(height: 10),
        _buildTextField(bPhoneController, "Phone No"),
        const SizedBox(height: 10),

        // --- BILLING DROPDOWNS ---
        Row(
          children: [
            Expanded(
              child: CustomSearchableDropdown<Map<String, dynamic>>(
                label: "District",
                items: _apiDistricts.cast<Map<String, dynamic>>(),
                selectedItem: selectedDistrict,
                itemLabelBuilder: (item) => item['name'] ?? '',
                onSelected: (val) {
                  setState(() {
                    selectedDistrict = val;
                    selectedCity = null; // Reset city when district changes
                    deliveryCost = double.tryParse(val?['delivery_cost'].toString() ?? '0') ?? 0.0;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomSearchableDropdown<Map<String, dynamic>>(
                label: "City",
                enabled: selectedDistrict != null,
                items: (selectedDistrict?['cities'] as List? ?? []).cast<Map<String, dynamic>>(),
                selectedItem: selectedCity,
                itemLabelBuilder: (item) => item['name'] ?? '',
                onSelected: (val) {
                  String zoneName = val?['zones'][0]['name'];
                  print("zoneName: $zoneName");

                  setState(() {
                    selectedCity = val;
                    if (val != null && val['zones'] != null && (val['zones'] as List).isNotEmpty) {
                      zone_id = val['zones'][0]['id'].toString();
                      print("$zone_id");
                      deliveryCost = double.tryParse(val['zones'][0]['delivery_cost'].toString() ?? '0') ?? 0.0;
                    }
                  });
                },
              ),
            ),
          ],
        ),

        if (deliveryCost != 0.0 && selectedCity != null && isShippingSame)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "Delivery Cost for ${selectedCity?['name']} : ৳${deliveryCost.toString()}",
              style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
            ),
          ),

        const SizedBox(height: 10),
        _buildTextField(bAddressController, "Street Address"),
        const SizedBox(height: 15),

        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text("Shipping address is same as billing"),
          value: isShippingSame,
          activeColor: Colors.orange,
          controlAffinity: ListTileControlAffinity.leading,
           onChanged: (val) {
             setState(() {
               isShippingSame = val ?? false;
             });
             _updateZoneAndCost();
           },
        ),

        // --- SHIPPING SECTION ---
        if (!isShippingSame) ...[
          const Divider(height: 30),
          _buildSectionHeader(Icons.local_shipping, "Shipping Information"),
          const SizedBox(height: 15),
          _buildTextField(sNameController, "Recipient Name"),
          const SizedBox(height: 10),
          _buildTextField(sPhoneController, "Recipient Phone"),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: CustomSearchableDropdown<Map<String, dynamic>>(
                    label: "Shipping District",
                    items: _apiDistricts.cast<Map<String, dynamic>>(),
                    selectedItem: selectedShipDistrict,
                    itemLabelBuilder: (item) => item['name'] ?? '',
                    onSelected: (val) {
                      setState(() {
                        selectedShipDistrict = val;
                        selectedShipThana = null;
                        deliveryCost = double.tryParse(val?['delivery_cost'].toString() ?? '0') ?? 0.0;
                      });
                    }
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomSearchableDropdown<Map<String, dynamic>>(
                  label: "Shipping City",
                  enabled: selectedShipDistrict != null,
                  items: (selectedShipDistrict?['cities'] as List? ?? []).cast<Map<String, dynamic>>(),
                  selectedItem: selectedShipThana,
                  itemLabelBuilder: (item) => item['name'] ?? '',
                  onSelected: (val) {
                    String zoneName = val?['zones'][0]['name'];
                    print("zoneName: $zoneName");

                    setState(() {
                      selectedShipThana = val;
                    });
                    _updateZoneAndCost();

                  },
                ),
              ),
            ],
          ),

          if (deliveryCost != 0.0 && selectedShipThana != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Delivery Cost for ${selectedShipThana?['name']} : ৳${deliveryCost.toString()}",
                style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
              ),
            ),

          const SizedBox(height: 10),
          _buildTextField(sAddressController, "Shipping Street Address"),
        ],
      ],
    );
  }

  // --- HELPER METHODS ---

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


  bool validateAddress() {
    // 1. Check Billing Info
    if (bNameController.text.trim().isEmpty) return false;
    if (bPhoneController.text.trim().isEmpty) return false;
    if (selectedDistrict == null) return false;
    if (selectedCity == null) return false;
    if (bAddressController.text.trim().isEmpty) return false;

    // 2. Check Shipping Info if "Same as Billing" is NOT checked
    if (!isShippingSame) {
      if (sNameController.text.trim().isEmpty) return false;
      if (sPhoneController.text.trim().isEmpty) return false;
      if (selectedShipDistrict == null) return false;
      if (selectedShipThana == null) return false;
      if (sAddressController.text.trim().isEmpty) return false;
    }

    return true; // All checks passed
  }

  void _updateZoneAndCost() {
    // Determine which location to use based on the checkbox
    final activeCity = isShippingSame ? selectedCity : selectedShipThana;

    setState(() {
      if (activeCity != null &&
          activeCity['zones'] != null &&
          (activeCity['zones'] as List).isNotEmpty) {

        final firstZone = activeCity['zones'][0];
        zone_id = firstZone['id'].toString();
        deliveryCost = double.tryParse(firstZone['delivery_cost'].toString()) ?? 0.0;

        debugPrint("Updated: zone_id=$zone_id, cost=$deliveryCost");
      } else {
        // Reset if no city is selected
        zone_id = '';
        deliveryCost = 0.0;
      }
    });
  }

}