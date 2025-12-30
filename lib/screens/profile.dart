import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/screens/editProfile.dart';
import 'package:merchbd/utils/auth_guard.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch the data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? moderatorString = prefs.getString('moderator');

    if (moderatorString != null) {
      setState(() {
        userData = jsonDecode(moderatorString);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: buildCustomAppBar(context, 'Profile'),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.phone_android, "Phone No",
                        userData?['phone']?.toString() ?? "N/A"),
                    _buildInfoTile(Icons.email_outlined, "Email",
                        userData?['email']?.toString() ?? "N/A"),
                    _buildInfoTile(Icons.map_outlined, "Division",
                        userData?['division_name']?.toString() ?? "N/A"),
                    _buildInfoTile(Icons.location_city, "District",
                        userData?['district_name']?.toString() ?? "N/A"),
                    _buildInfoTile(Icons.home_work_outlined, "City Name",
                        userData?['city_name']?.toString() ?? "N/A"),
                    _buildInfoTile(Icons.home_outlined, "Living Address",
                        userData?['address']?.toString() ?? "N/A"),
                    _buildInfoTile(Icons.wc, "Gender",
                        userData?['sex']?.toString() ?? "N/A"),
                  ],
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

  Widget _buildHeader(BuildContext context) {
    // Handling the name safely
    String fullName = "${userData?['first_name'] ?? 'User'} ${userData?['last_name'] ?? ''}";
    String? photoUrl = userData?['photo'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.orange.shade100,
                // If photoUrl exists, show it, otherwise show person icon
                backgroundImage: photoUrl != null
                    ? NetworkImage("https://getmerchbd.com$photoUrl")
                    : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.orange)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () => _navigateToEdit(context),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            fullName,
            style: const TextStyle(fontFamily: 'Audiowide', fontSize: 22, fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            onPressed: () => _navigateToEdit(context),
            icon: const Icon(Icons.edit_note, color: Colors.orange),
            label: const Text("Edit Profile", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditProfileScreen())
    ).then((_) => _loadUserData()); // Refresh data when coming back from edit
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.orange, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded( // Added expanded to prevent text overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}