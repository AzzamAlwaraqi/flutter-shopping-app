import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/database_service.dart';

/// Screen for adding a new delivery address or editing an existing one.
class AddEditAddressPage extends StatefulWidget {
  /// If provided, the form will be pre-filled with this address's data for editing.
  final AddressModel? existingAddress;

  /// Null means the real Firestore; tests pass a service backed by a fake one.
  final DatabaseService? database;

  const AddEditAddressPage({super.key, this.existingAddress, this.database});

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late final DatabaseService _dbService = widget.database ?? DatabaseService();

  /// True while a save is in flight, so a second tap can't add the address twice.
  bool _saving = false;

  // Form field controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addr1Controller = TextEditingController();
  final _addr2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate fields if editing an existing address
    if (widget.existingAddress != null) {
      final a = widget.existingAddress!;
      _nameController.text = a.fullName;
      _phoneController.text = a.phoneNumber;
      _addr1Controller.text = a.addressLine1;
      _addr2Controller.text = a.addressLine2;
      _cityController.text = a.city;
      _stateController.text = a.state;
      _zipController.text = a.zipCode;
      _isDefault = a.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addr1Controller.dispose();
    _addr2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  /// Validates the form and saves the address to Firestore.
  Future<void> _saveAddress() async {
    if (_saving) return;
    if (_formKey.currentState!.validate()) {
      final newAddress = AddressModel(
        id: widget.existingAddress?.id,
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
        addressLine1: _addr1Controller.text,
        addressLine2: _addr2Controller.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        isDefault: _isDefault,
      );

      setState(() => _saving = true);
      try {
        if (widget.existingAddress == null) {
          await _dbService.addAddress(newAddress);
        } else {
          await _dbService.updateAddress(newAddress);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        // Before, a failed save left the button silently doing nothing
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't save the address. Check your connection and try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingAddress == null ? "New Address" : "Edit Address",
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Full Name"),
              _buildTextField(_nameController),
              const SizedBox(height: 15),
              _buildLabel("Phone Number"),
              _buildTextField(
                _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              _buildLabel("Address Line 1"),
              _buildTextField(_addr1Controller),
              const SizedBox(height: 15),
              _buildLabel("Address Line 2"),
              _buildTextField(_addr2Controller),
              const SizedBox(height: 15),
              _buildLabel("City"),
              _buildTextField(_cityController),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("State"),
                        _buildTextField(_stateController),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Zip Code"),
                        _buildTextField(
                          _zipController,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // The model always had isDefault, but the form had no way to set it
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Use as my default address"),
                value: _isDefault,
                activeThumbColor: Colors.green,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: 15),
              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.green.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _saving ? null : _saveAddress,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          "SAVE ADDRESS",
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to build consistent labels for form fields.
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Helper to build a standard decorated text field.
  Widget _buildTextField(
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (val) => val == null || val.isEmpty ? "Required field" : null,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }
}
