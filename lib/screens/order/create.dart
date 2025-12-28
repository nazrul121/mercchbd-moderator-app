import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/SnackBar.dart';
import 'package:merchbd/screens/order/billing_shipping.dart';
import 'package:merchbd/screens/order/order_list.dart';
import 'package:merchbd/screens/order/searachProduct.dart';
import 'package:merchbd/utils/auth_guard.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

import 'FinalOrderDetails.dart';

class CreateOrder extends StatefulWidget {
  const CreateOrder({super.key});

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final GlobalKey<AddressFormState> addressKey = GlobalKey<AddressFormState>();

  final _discountController = TextEditingController();
  String _orderSource = 'whatApp';
  String payment_method = "";

  void _nextStep() {
    if (_currentStep == 0) {
      // Check Address Form Validation
      final addressState = addressKey.currentState;

      if (addressState == null || !addressState.validateAddress()) {
        showCustomSnackbar(context, "Please fill in all required address fields!");
        return;
      }
    }


    if (_currentStep < 2) {
      _pageController.nextPage( duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      _finishOrder();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void showCustomSnackbar(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => CustomSnackbar(message: message),
    );
  }

  Future<void> _finishOrder() async {

    // 1. Get the current state of the address form via the key
    final addressState = addressKey.currentState;

    if (_orderItems.isEmpty) {
      showCustomSnackbar(context, 'Please add one product at least!');
      return;
    }


    // 2. Prepare the Billing and Shipping Data
    Map<String, dynamic> billingInfo = {
      "name": addressState?.bNameController.text,
      "phone": addressState?.bPhoneController.text,
      "district": addressState?.selectedDistrict?['name'],
      "city": addressState?.selectedCity?['name'],
      "address": addressState?.bAddressController.text,
    };

    Map<String, dynamic> shippingInfo = addressState!.isShippingSame
        ? billingInfo // Use billing if same
        : {
      "name": addressState.sNameController.text,
      "phone": addressState.sPhoneController.text,
      "district": addressState.selectedShipDistrict?['name'],
      "city": addressState.selectedShipThana?['name'],
      "address": addressState.sAddressController.text,
    };

    // 3. Prepare Order Summary Data
    double subtotal = _calculateTotal();
    double shippingCost = addressState.deliveryCost;
    double discount = double.tryParse(_discountController.text) ?? 0.0;
    double grandTotal = (subtotal + shippingCost) - discount;

    // 4. Construct the Final JSON Object
    Map<String, dynamic> finalOrderData = {
      "order_source": _orderSource,
      "billing": billingInfo,
      "shipping": shippingInfo,
      "items": _orderItems, // List of products with quantities
      "summary": {
        "subtotal": subtotal,
        "shipping_cost": shippingCost,
        "discount": discount,
        "grand_total": grandTotal,
      }
    };
    _showOrderSummaryDialog(finalOrderData);
  }

  void _showOrderSummaryDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Order Data"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Billing info--'),
              Text("Customer: ${data['billing']['name']}"),
              Text("Phone: ${data['billing']['phone']}"),
              Text("District: ${data['billing']['district']}"),
              Text("Thana: ${data['billing']['city']}"),
              const Divider(),
              Text('Shipping info--'),
              Text("Receiver: ${data['shipping']['name']}"),
              Text("Phone: ${data['shipping']['phone']}"),
              Text("District: ${data['shipping']['district']}"),
              Text("Thana: ${data['shipping']['city']}"),
              const Divider(),
              const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
              ..._orderItems.map((item) => Text("• ${item['title']} x ${item['quantity']}")).toList(),
              const Divider(),
              Text("Grand Total: ৳${data['summary']['grand_total']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Edit")),
          ElevatedButton(
              onPressed: () {
                // Here you would call your POST request to https://getmerchbd.com/api/create-order
                _submitOrderToApi();
                // Navigator.pop(context);
              },
              child: const Text("Confirm & Send")
          ),
        ],
      ),
    );
  }

  Future<void> _submitOrderToApi() async {
    final addressState = addressKey.currentState;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? moderatorString = prefs.getString('moderator');

    Map<String, dynamic> moderatorMap = jsonDecode(moderatorString!);
    String moderatorId = moderatorMap['id'].toString();
    String user_id = moderatorMap['user_id'].toString();

    if (addressState == null) return;
    // 1. Map your UI data to the required API Model
    final Map<String, dynamic> orderData = {
      "moderator_id": moderatorId,
      "payment_geteway": payment_method, // Hardcoded or from your UI
      "zone_id":  addressState.zone_id.toString(),
      "total_items": _orderItems.length.toString(),
      "total_cost": _calculateTotal().toString(),
      "invoice_discount": "0",
      "transaction_id": "CashOnDelivery",
      "shipping_cost": addressState.deliveryCost.toString(),
      "discount": _discountController.text.isEmpty ? "0" : _discountController.text,
      "order_date": DateTime.now().toString().split(' ')[0], // Format: YYYY-MM-DD
      "ref": _orderSource.toLowerCase(),
      "shippingCostFrom": "zone",

      // Billing
      "district": addressState.selectedDistrict?['name'] ?? "",
      "city": addressState.selectedCity?['name'] ?? "",
      "name": addressState.bNameController.text,
      "phone": addressState.bPhoneController.text,
      "email": "",
      "address": addressState.bAddressController.text,
      "postCode": "0000",

      // Shipping (Check if same as billing)
      "ship_district": addressState.isShippingSame
          ? (addressState.selectedDistrict?['name'] ?? "")
          : (addressState.selectedShipDistrict?['name'] ?? ""),
      "ship_city": addressState.isShippingSame
          ? (addressState.selectedCity?['name'] ?? "")
          : (addressState.selectedShipThana?['name'] ?? ""),
      "ship_name": addressState.isShippingSame ? addressState.bNameController.text : addressState.sNameController.text,
      "ship_phone": addressState.isShippingSame ? addressState.bPhoneController.text : addressState.sPhoneController.text,
      "ship_email": "",
      "ship_address": addressState.isShippingSame ? addressState.bAddressController.text : addressState.sAddressController.text,
      "ship_postCode": "0000",
      "created_by": "1", // Replace with logged-in user ID

      // 2. Map the Product Items
      "order_items": _orderItems.map((item) {
        return {
          "product_id": item['id'].toString(),
          "bundle_promotion_id": null, "buy_one_get_one_id":null,
          "variation_option_id":null,
          "product_combination_id":null,
          "qty": item['quantity'].toString(),
          "net_price": item['sale_price'].toString(),
          "sale_price": item['sale_price'].toString(),
          "discount_price": item['sale_price'].toString(),
          "vat": "0",
          "vat_type": "including",
          "status": "placed",
          "user_id": user_id,
          "created_by": user_id
        };
      }).toList(),
    };

    String fullJsonString = jsonEncode(orderData);
    debugPrint(fullJsonString);


    // 3. Send to API
    try {
      showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('https://getmerchbd.com/api/create-order'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json', // REQUIRED for JSON requests
        },
        body: fullJsonString, // PASS YOUR DATA HERE
      );

      final data = jsonDecode(response.body);
      if (data['errors'] != null) {
        setState(() {
          final errors = data['errors'] as Map<String, dynamic>;
          CustomSnackbar(message: errors.toString());
        });
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
        Navigator.pop(context); // Close loading dialog
        print("${response.body}");
      } else {
        throw Exception("Failed to create order: ${response.body}");
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text("Order Created Successfully!", textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderList()));
            },
            child: const Text("Go to Order List"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: buildCustomAppBar(context, 'Create Order'),
        body: Column(
          children: [
            // --- HEADER WITH ORDER LIST LINK ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Step ',
                      style: TextStyle(color: Colors.black, fontSize: 20), // Default style
                      children: <TextSpan>[
                        TextSpan(
                          text: '${_currentStep + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Audiowide')
                        ),
                        TextSpan(text: ' of 3'), // Reverts to the parent style if no style is provided
                      ],
                    ),
                  ),

                  TextButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderList())),
                    icon: const Icon(Icons.list_alt, size: 20),
                    label: const Text("Order List"),
                  ),
                ],
              ),
            ),

            // --- PROGRESS BAR ---
            LinearProgressIndicator(
              value: (_currentStep + 1) / 3,
              backgroundColor: Colors.grey.shade300,
              color: Colors.orange,
            ),

            // --- STEP CONTENT ---
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // User must use buttons
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  Padding( padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: AddressForm(key: addressKey),
                    ),
                  ),
                  _buildStepTwo(),   // Product Search
                  _buildStepThree(), // Final Details
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(child: _buildBottomNavActions()),
      ),
    );
  }

  List<Map<String, dynamic>> _orderItems = [];

  void _addItemToOrder(Map<String, dynamic> product) {
    setState(() {
      // We check if the product is already in the list to avoid duplicates
      bool exists = _orderItems.any((item) => item['id'] == product['id']);
      if (!exists) {
        // Add product with a default quantity of 1
        _orderItems.add({
          'id': product['id'],
          'title': product['title'],
          'sale_price': product['sale_price'],
          'thumbs': product['thumbs'],
          'quantity': 1,
        });
      } else {
        // If it exists, maybe just increase the quantity?
        int index = _orderItems.indexWhere((item) => item['id'] == product['id']);
        _orderItems[index]['quantity']++;
      }
    });
  }

  // --- STEP 2: PRODUCT SEARCH ---
  Widget _buildStepTwo() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: SingleChildScrollView( // Allow scrolling when the item list grows
        child: ProductSearchAutocomplete(
          orderItems: _orderItems,
          onProductAdded: (product) => _addItemToOrder(product),
          onRemoveItem: (index) {
            setState(() => _orderItems.removeAt(index));
          },
          onListChanged: () {
            setState(() {}); // Re-build parent to refresh totals for Step 3
          },
        ),
      ),
    );
  }

  // --- STEP 3: FINAL DETAILS ---
  Widget _buildStepThree() {
    final addressState = addressKey.currentState;
    double shipping = addressState?.deliveryCost ?? 0.0;
    String cityName = addressState?.selectedCity?['name'] ?? "Not selected";

    return FinalOrderDetails(
      discountController: _discountController,
      orderSource: _orderSource,
      paymentGateway: payment_method, // Pass the current state
      subtotal: _calculateTotal(),
      shippingCost: shipping,
      city: cityName,
      onSourceChanged: (newSource) {
        setState(() => _orderSource = newSource);
      },
      onPaymentMethodChanged: (newMethod) {
        setState(() => payment_method = newMethod); // Update parent state
      },
      onDiscountChanged: () {
        setState(() {}); // Refresh for grand total calculation
      },
    );
  }

  double _calculateTotal() {
    return _orderItems.fold(0.0, (double sum, item) {
      double price = double.tryParse(item['sale_price'].toString()) ?? 0.0;
      int qty = item['quantity'] ?? 1;
      return sum + (price * qty);
      // Removed _deliveryCost from here to avoid adding it multiple times per item
    });
  }

  Widget _buildBottomNavActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(onPressed: _prevStep, child: const Text("Back"))
          else
            const SizedBox(width: 50),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 40)),
            onPressed: _nextStep,
            child: Text(_currentStep == 2 ? "Finish" : "Next", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}