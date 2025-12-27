import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/screens/order/billing_shipping.dart';
import 'package:merchbd/screens/order/order_list.dart';
import 'package:merchbd/screens/order/searachProduct.dart';
import 'package:merchbd/utils/auth_guard.dart';

class CreateOrder extends StatefulWidget {
  const CreateOrder({super.key});

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}


class _CreateOrderState extends State<CreateOrder> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Controllers
  final GlobalKey<AddressFormState> addressKey = GlobalKey<AddressFormState>();

// Use it in your UI
  AddressForm(key: addressKey),

// Access data later
  void printData() {
  print(addressKey.currentState?.deliveryCost);
  }


  final _discountController = TextEditingController();
  String _orderSource = 'Facebook';

  double _deliveryCost = 0.0;

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
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

  void _finishOrder() {
    // Implement your final API submission here
    debugPrint("Order Finished");
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
                  AddressForm(
                    onDataChanged: (data) {
                      setState(() {
                        _deliveryCost = data['deliveryCost'];
                        // Store other data into a local Map if you need it for the API call
                      });
                    },
                  ),
                  _buildStepTwo(),   // Product Search
                  _buildStepThree(), // Final Details
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavActions(),
      ),
    );
  }

  int? _selectedProductId;
  Map<String, dynamic>? _selectedProductDetails;

  // The array that will hold all products in the current order
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
      child: Column(
        children: [
          // 1. Search Component
          ProductSearchAutocomplete(
            onProductSelected: (product) {
              _addItemToOrder(product);
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

          // 2. The List of selected items
          Expanded(
            child: _orderItems.isEmpty ? const Center(child: Text("No products added yet")):
            ListView.builder(
              shrinkWrap: true, // Useful if inside a Column
              physics: const NeverScrollableScrollPhysics(), // Let the parent scroll
              itemCount: _orderItems.length,
              itemBuilder: (context, index) {
                final item = _orderItems[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Image.network(
                      "https://getmerchbd.com/${item['thumbs']}",
                      width: 40,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                    ),
                    title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [
                        Text("৳${item['sale_price']}", style: const TextStyle(color: Colors.green)),
                        const SizedBox(width: 15),

                        // --- QUANTITY CONTROLS ---
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              // Minus Button
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (item['quantity'] > 1) {
                                      item['quantity']--;
                                    }
                                  });
                                },
                                child: const Icon(Icons.remove, size: 20, color: Colors.red),
                              ),

                              // Quantity Number
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "${item['quantity']}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),

                              // Plus Button
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    item['quantity']++;
                                  });
                                },
                                child: const Icon(Icons.add, size: 20, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _orderItems.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 3: FINAL DETAILS ---
  Widget _buildStepThree() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Final Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Use Row with Expanded to prevent overflow
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discount Field
              Expanded(
                child: TextFormField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() {}), // Rebuild to update summary
                  decoration: const InputDecoration(
                    labelText: "Discount",
                    prefixText: "৳",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 15),

              // Order Source Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _orderSource,
                  isExpanded: true, // Prevents text overflow
                  decoration: const InputDecoration(
                    labelText: "Order Source",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ['Facebook', 'Website', 'WhatsApp', 'Direct'].map((String s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (val) => setState(() => _orderSource = val!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          _buildFinalSummary(),
        ],
      ),
    );
  }

  Widget _buildFinalSummary() {
    double subtotal = _calculateTotal(); // From previous step
    double discount = double.tryParse(_discountController.text) ?? 0.0;
    double grandTotal = subtotal - discount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        children: [
          _summaryRow("Subtotal:", "৳$subtotal"),
          const SizedBox(height: 8),
          _summaryRow("Shipping Cost:", "৳$_deliveryCost"),
          const SizedBox(height: 8),
          _summaryRow("Discount:", "৳$discount",),
          const Divider(height: 24),
          _summaryRow("Grand Total:", "৳${grandTotal < 0 ? 0 : grandTotal}", isBold: true),

        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.black)),
      ],
    );
  }

  double _calculateTotal() {
    return _orderItems.fold(0.0, (double sum, item) {
      double price = double.tryParse(item['sale_price'].toString()) ?? 0.0;
      int qty = item['quantity'] ?? 1;
      return sum + (price * qty) + _deliveryCost;
    });
  }



  // --- NAVIGATION BUTTONS (REPLACING FOOTER FOR THIS PAGE) ---
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