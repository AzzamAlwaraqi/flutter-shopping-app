import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'my_order_page.dart';
import 'delivery_address_page.dart';
import '../services/database_service.dart';

/// The main Profile screen that serves as the user's account dashboard.
class ProfilePage extends StatefulWidget {
  final String name;

  /// Passed down to the address screens; null means the real Firestore.
  final DatabaseService? database;

  const ProfilePage({super.key, required this.name, this.database});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Colors.green,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
        ),
        title: Column(
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.green),
                ),
                const SizedBox(width: 10),
                Text(
                  _displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Navigation to Edit Profile
              _buildProfileOption(
                icon: Icons.person_outline,
                title: "My Profile",
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfilePage(initialName: _displayName),
                    ),
                  );
                  // Update the name if it was changed in EditProfilePage
                  if (result != null && result is String) {
                    setState(() {
                      _displayName = result;
                    });
                  }
                },
              ),
              const Divider(),
              // Navigation to My Orders
              _buildProfileOption(
                icon: Icons.shopping_bag_outlined,
                title: "My Order",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOrderPage(),
                    ),
                  );
                },
              ),
              const Divider(),
              // Navigation to Delivery Addresses
              _buildProfileOption(
                icon: Icons.location_on_outlined,
                title: "Delivery Address",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DeliveryAddressPage(database: widget.database),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to build a consistent list item for profile options.
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: Colors.green,
        size: 28,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }
}
