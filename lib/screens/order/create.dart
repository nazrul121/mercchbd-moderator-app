import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/screens/order/order_list.dart';
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
  final _billingController = TextEditingController();
  final _shippingController = TextEditingController();
  final _discountController = TextEditingController();
  String _orderSource = 'Facebook';
  List<String> _selectedProducts = []; // To store searched/added products

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
    debugPrint("Order Finished: ${_billingController.text}");
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
                  _buildStepOne(),   // Address
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

  // --- STEP 1: BILLING & SHIPPING ---
  Widget _buildStepOne() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.orange, size: 22,),
              const Text("Billing & ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              Icon(Icons.edit_location_outlined, color: Colors.orange, size: 23),
              const Text("Shipping info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _billingController,
            decoration: const InputDecoration(labelText: "Billing Address", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _shippingController,
            decoration: const InputDecoration(labelText: "Shipping Address", border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  // --- STEP 2: PRODUCT SEARCH ---
  Widget _buildStepTwo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            onChanged: (value) { /* Handle search logic */ },
            decoration: InputDecoration(
              hintText: "Search Product...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          const Expanded(
            child: Center(child: Text("Product search results will appear here")),
          )
        ],
      ),
    );
  }

  // --- STEP 3: FINAL DETAILS ---
  Widget _buildStepThree() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _discountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Discount Amount", prefixText: "৳"),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _orderSource,
            decoration: const InputDecoration(labelText: "Order Source"),
            items: ['Facebook', 'Website', 'WhatsApp', 'Direct'].map((String s) {
              return DropdownMenuItem(value: s, child: Text(s));
            }).toList(),
            onChanged: (val) => setState(() => _orderSource = val!),
          ),
        ],
      ),
    );
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