import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/database_service.dart';
import 'add_edit_address_page.dart';

/// Screen that lists all saved delivery addresses for the user.
class DeliveryAddressPage extends StatefulWidget {
  /// Null means the real Firestore; tests pass a service backed by a fake one.
  final DatabaseService? database;

  const DeliveryAddressPage({super.key, this.database});

  @override
  State<DeliveryAddressPage> createState() => _DeliveryAddressPageState();
}

class _DeliveryAddressPageState extends State<DeliveryAddressPage> {
  late final DatabaseService _dbService = widget.database ?? DatabaseService();
  late final Stream<List<AddressModel>> _addresses = _dbService.getAddresses();

  /// Shows a short message at the bottom when a Firestore call fails.
  void _showError(String action, Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Couldn't $action. Check your connection and try again.")),
    );
  }

  Future<void> _setDefault(String? id) async {
    if (id == null) return;
    try {
      await _dbService.setDefaultAddress(id);
    } catch (e) {
      _showError('change the default address', e);
    }
  }

  Future<void> _delete(String id) async {
    try {
      await _dbService.deleteAddress(id);
    } catch (e) {
      _showError('delete the address', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Delivery Address",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      // StreamBuilder listens to real-time updates from Firestore
      body: StreamBuilder<List<AddressModel>>(
        stream: _addresses,
        builder: (context, snapshot) {
          // Checked first: before, a failed load fell through to "No addresses found"
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Couldn't load your addresses. Check your connection and try again.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No addresses found. Add one!"));
          }

          final addresses = snapshot.data!;
          // The selected radio is whichever address is saved as the default
          final defaultId = addresses
              .where((a) => a.isDefault)
              .map((a) => a.id)
              .firstOrNull;

          return RadioGroup<String>(
            groupValue: defaultId,
            onChanged: _setDefault,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                return _buildAddressCard(addresses[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Navigate to add new address
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditAddressPage(database: _dbService)),
          );
        },
      ),
    );
  }

  /// Builds a card representing a single address with edit and delete options.
  Widget _buildAddressCard(AddressModel address) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Picking a radio makes that address the default
          Radio<String>(
            value: address.id!,
            activeColor: Colors.green,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${address.addressLine1}, ${address.city}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  address.phoneNumber,
                  style: const TextStyle(color: Colors.grey),
                ),
                if (address.isDefault) ...[
                  const SizedBox(height: 6),
                  const Text(
                    "Default",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              // Edit existing address
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                tooltip: 'Edit',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditAddressPage(
                        existingAddress: address,
                        database: _dbService,
                      ),
                    ),
                  );
                },
              ),
              // Delete address from database
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                tooltip: 'Delete',
                onPressed: () => _delete(address.id!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
