import 'package:flutter/material.dart';
import 'package:merchbd/includes/CustomAppBar.dart';
import 'package:merchbd/includes/Footer.dart';
import 'package:merchbd/screens/editProfile.dart';
import 'package:merchbd/utils/auth_guard.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: buildCustomAppBar(context, 'Profile'),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoTile(Icons.phone_android, "Phone No", "017XXXXXXXX"),
                    _buildInfoTile(Icons.map_outlined, "Division", "Dhaka"),
                    _buildInfoTile(Icons.location_city, "District", "Dhaka"),
                    _buildInfoTile(Icons.home_work_outlined, "City Name", "Mirpur"),
                    _buildInfoTile(Icons.home_outlined, "Living Address", "Block-D, Road-5, House-12"),
                    _buildInfoTile(Icons.wc, "Gender", "Male"),
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

  // Header with Profile Photo and Name
  // In ProfileScreen.dart inside _buildHeader()
  Widget _buildHeader(BuildContext context) {
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
                child: const Icon(Icons.person, size: 60, color: Colors.orange),
              ),
              // Floating Edit Button for Photo
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    // Navigate to Edit Page
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                  },
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
          const Text(
            "User Full Name",
            style: TextStyle(fontFamily: 'Audiowide', fontSize: 22, fontWeight: FontWeight.bold),
          ),
          // --- ADD THIS LINK BUTTON ---
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit_note, color: Colors.orange),
            label: const Text("Edit Profile", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Reusable Info Tile
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}