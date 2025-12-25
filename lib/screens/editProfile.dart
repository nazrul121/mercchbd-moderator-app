import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/utils/auth_guard.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers for each field
  final _nameController = TextEditingController(text: "User Full Name");
  final _phoneController = TextEditingController(text: "017XXXXXXXX");
  final _divisionController = TextEditingController(text: "Dhaka");
  final _districtController = TextEditingController(text: "Dhaka");
  final _cityController = TextEditingController(text: "Mirpur");
  final _addressController = TextEditingController(text: "Block-D, Road-5, House-12");

  String _gender = 'Male'; // Default value for Radio buttons
  bool _isSaving = false;

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _phoneController.dispose();
    _divisionController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully!")),
      );
      Navigator.pop(context); // Go back to Profile Screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildCustomAppBar(context, 'Edit Profile'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Personal Information",
                style: TextStyle(
                  fontFamily: 'Audiowide',
                  fontSize: 18,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField(_nameController, "Full Name", Icons.person_outline),
              _buildTextField(_phoneController, "Phone Number", Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              _buildTextField(_divisionController, "Division", Icons.map_outlined),
              _buildTextField(_districtController, "District", Icons.location_on_outlined),
              _buildTextField(_cityController, "City Name", Icons.location_city_outlined),
              _buildTextField(_addressController, "Living Address", Icons.home_outlined, maxLines: 2),

              const SizedBox(height: 10),
              const Text("Gender", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  Radio<String>(
                    value: 'Male',
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                  const Text("Male"),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'Female',
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                  const Text("Female"),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "SAVE CHANGES",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: const Footer(),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.orange, width: 2),
          ),
        ),
      ),
    );
  }
}