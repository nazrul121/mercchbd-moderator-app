import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/utils/auth_guard.dart';
import '../includes/CustomSearchableDropdown.dart';
import '../includes/SnackBar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // 1. Initialize empty controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _divisionController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();

  String moderatorId = '';
  String _gender = '';
  bool _isSaving = false;
  bool _isLoading = true; // Added loading state
  List<dynamic> _apiDistricts = [];
  List<dynamic> _apiDivisions= [];

  Map<String, dynamic>? _selectedDivisionId;
  Map<String, dynamic>? selectedDistrictId;
  Map<String, dynamic>? selectedThana;


  Future<void> _fetchDivisions() async {
    try {
      final divRes = await http.get(Uri.parse('https://getmerchbd.com/api/divisions'));
      if (divRes.statusCode == 200) {
        List<dynamic> fetchedDivs = json.decode(divRes.body);
        setState(() {
          _apiDivisions = fetchedDivs;

          // If we have a saved ID, find the matching Map object in the list
          if (tempDivisionId != null) {
            _selectedDivisionId = _apiDivisions.firstWhere(
                  (item) => item['id'] == tempDivisionId,
              orElse: () => null,
            );
            _fetchDistricts();
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchDistricts() async {
    try {
      final distRes = await http.get(Uri.parse('https://getmerchbd.com/api/districts'));
      if (distRes.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(distRes.body);
        List<dynamic> allDistricts = data['districts'] ?? [];

        setState(() {
          _apiDistricts = allDistricts;

          // ✅ 1. Auto-select District object using tempDistrictId
          if (tempDistrictId != null) {
            selectedDistrictId = _apiDistricts.firstWhere(
                  (d) => d['id'] == tempDistrictId,
              orElse: () => null,
            );
          }

          // ✅ 2. Auto-select City object using tempCityId
          // We look inside the already selected district's cities
          if (tempCityId != null && selectedDistrictId != null) {
            final List<dynamic> cities = selectedDistrictId!['cities'] ?? [];
            selectedThana = cities.firstWhere(
                  (c) => c['id'] == tempCityId,
              orElse: () => null,
            );
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }


  @override
  void initState() {
    super.initState();
    _loadModeratorData();
    _fetchDivisions();
  }

  int? tempDivisionId;
  int? tempDistrictId;
  int? tempCityId;

  Future<void> _loadModeratorData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? moderatorString = prefs.getString('moderator');

    if (moderatorString != null) {
      final Map<String, dynamic> data = jsonDecode(moderatorString);
      setState(() {
        photo = data;
        _firstNameController.text = data['first_name']?.toString() ?? "";
        _lastNameController.text = data['last_name']?.toString() ?? "";
        _phoneController.text = data['phone']?.toString() ?? "";
        _addressController.text = data['address']?.toString() ?? "";
        _gender = (data['sex']?.toString().toLowerCase() == 'female') ? 'female' : 'male';

        tempDivisionId = num.tryParse(data['division_id']?.toString() ?? '')?.toInt();
        tempDistrictId = num.tryParse(data['district_id']?.toString() ?? '')?.toInt();
        tempCityId = num.tryParse(data['city_id']?.toString() ?? '')?.toInt();
        moderatorId = data['id']?.toString() ?? "";

      });
    }
  }

  void showCustomSnackbar(BuildContext context, String message, String type) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => CustomSnackbar(message: message, type:type),
    );
  }

  Map<String, dynamic>? matchingCity(List<dynamic> districts, int cityId) {
    if (districts.isEmpty) return null;

    for (final d in districts) {
      final List<dynamic> cities = d['cities'] ?? [];
      for (final c in cities) {
        // Use standard int comparison if possible, or both to string
        if (c['id'].toString() == cityId.toString()) {
          return c; // Return the CITY object, not the district 'd'
        }
      }
    }
    return null;
  }


  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Map<String, dynamic>? photo;
  // Define this inside the build method
  ImageProvider? _getImageProvider(Map<String, dynamic>? userData) {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (userData != null && userData['photo'] != null) {
      String path = userData['photo'];
      // If Laravel stores "/storage/...", we prefix the domain
      String fullUrl = path.startsWith('http') ? path : "https://getmerchbd.com$path";
      return NetworkImage(fullUrl);
    }
    return null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _divisionController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      var uri = Uri.parse('https://getmerchbd.com/api/update-moderator/$moderatorId');
      // print("$uri, Moderator ID:  $moderatorId"); return;
      var request = http.MultipartRequest('POST', uri);

      // Add Headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add Text Fields
      request.fields['first_name'] = _firstNameController.text;
      request.fields['last_name'] = _lastNameController.text;
      request.fields['phone'] = _phoneController.text;
      request.fields['gender'] = _gender;
      request.fields['division_id'] = _selectedDivisionId?['id'].toString() ?? '';
      request.fields['district_id'] = selectedDistrictId?['id'].toString() ?? '';
      request.fields['city_id'] = selectedThana?['id'].toString() ?? '';
      request.fields['address'] = _addressController.text;

      // Add Image File
      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo', // Changed from 'profile_photo' to 'photo' to match Laravel
          _imageFile!.path,
          contentType: http.MediaType('image', 'jpeg'),
        ));

        // Also pass oldPhoto if your API needs it for deletion logic
        if (photo != null && photo!['photo'] != null) {
          request.fields['oldPhoto'] = photo!['photo'];
          request.fields['type'] = 'update';
        }
      }

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {

        final Map<String, dynamic> responseData = json.decode(response.body);
        // 2. Check if the response contains the updated moderator data
        if (responseData.containsKey('moderator')) {
          final updatedModerator = responseData['moderator'];
          // 3. Save the new data back to SharedPreferences
          await prefs.setString('moderator', json.encode(updatedModerator));
          print("Local storage updated with new moderator data.");
        }
        showCustomSnackbar(context,'Profile has been updaetd successfully!', 'success');

        return;
      } else if (response.statusCode == 422) {
        // Laravel Validation Errors
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('errors')) {
          // Get the first error message from the list
          Map<String, dynamic> errors = responseData['errors'];

          // This logic picks the first error message it finds
          String errorMessage = "Validation Error";
          if (errors.isNotEmpty) {
            var firstKey = errors.keys.first;
            errorMessage = errors[firstKey][0]; // Takes the first message of the first field
          }

          showCustomSnackbar(context,errorMessage,'warning');return;
        }
      } else {
        showCustomSnackbar(context, "Server Error: ${response.statusCode}", 'error'); return;
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildCustomAppBar(context, 'Edit Profile'),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _getImageProvider(photo), // Pass your moderator data here
                      child: (_imageFile == null && (photo == null || photo?['photo'] == null))
                          ? const Icon(Icons.person, size: 60, color: Colors.orange)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text("Personal Information",
                style: TextStyle(fontFamily: 'Audiowide', fontSize: 18, color: Colors.orange),
              ),

              const SizedBox(height: 20),

              _buildTextField(_firstNameController, "First Name", Icons.person_outline),
              _buildTextField(_lastNameController, "Last Name", Icons.person_outline),
              _buildTextField(_phoneController, "Phone Number", Icons.phone_android_outlined, keyboardType: TextInputType.phone),

              // 1. Division
              Row(
                children: [
                  Expanded(
                    child: CustomSearchableDropdown<Map<String, dynamic>>(
                      label: "Division",
                      items: _apiDivisions.cast<Map<String, dynamic>>(),
                      selectedItem: _selectedDivisionId,
                      itemLabelBuilder: (item) => item['name'] ?? '',
                      onSelected: (val) {
                        setState(() {
                          _selectedDivisionId = val;
                          selectedDistrictId = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height:20),
              // 2. District (Items depend on Division)
              Row(
                children: [
                  Expanded(
                    child: CustomSearchableDropdown<Map<String, dynamic>>(
                      label: "District",
                      items: _apiDistricts.cast<Map<String, dynamic>>(),
                      selectedItem: selectedDistrictId,
                      itemLabelBuilder: (item) => item['name'] ?? '',
                      onSelected: (val) {
                        setState(() {
                          selectedDistrictId = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height:20),
              Row(
                children: [
                  Expanded(
                    child: CustomSearchableDropdown<Map<String, dynamic>>(
                      label: "City / Thana",
                      enabled: selectedDistrictId != null,
                      items: (selectedDistrictId?['cities'] as List? ?? []).cast<Map<String, dynamic>>(),
                      selectedItem: selectedThana,
                      itemLabelBuilder: (item) => item['name'] ?? '',
                      onSelected: (val) {
                        setState(() {
                          selectedThana = val;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height:20),

              _buildTextField(_addressController, "Living Address", Icons.home_outlined, maxLines: 2),

              const SizedBox(height: 10),
              const Text("Gender", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                children: [
                  Radio<String>(
                    value: 'male',
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                  const Text("Male"),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'female',
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

  // Keep your _buildTextField as it was...
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
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
        ),
      ),
    );
  }


}