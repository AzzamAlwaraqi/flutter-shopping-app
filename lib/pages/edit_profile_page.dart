import 'package:flutter/material.dart';

/// Screen that allows users to update their profile information.
class EditProfilePage extends StatefulWidget {
  final String initialName;

  const EditProfilePage({super.key, required this.initialName});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    // Split the combined name into first and last name for editing
    List<String> parts = widget.initialName.split(' ');
    _firstNameController = TextEditingController(
      text: parts.isNotEmpty ? parts[0] : "",
    );
    _lastNameController = TextEditingController(
      text: parts.length > 1 ? parts.sublist(1).join(' ') : "",
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Opens a date picker to select the user's birthday.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("First Name"),
              _buildTextField(
                _firstNameController,
                validator: (val) =>
                    val == null || val.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 20),
              _buildLabel("Last Name"),
              _buildTextField(
                _lastNameController,
                validator: (val) =>
                    val == null || val.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 20),
              // Only the name is saved, so only the name is required.
              // The other fields are optional until they are stored somewhere.
              _buildLabel("Phone Number"),
              _buildTextField(
                _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildLabel("Gender"),
              _buildGenderDropdown(),
              const SizedBox(height: 20),
              _buildLabel("Birthday"),
              _buildTextField(
                _birthdayController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decorationIcon: const Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel("Password"),
              _buildTextField(
                _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B341),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Return the updated full name to the previous screen
                      String newName =
                          "${_firstNameController.text} ${_lastNameController.text}"
                              .trim();
                      Navigator.pop(context, newName);
                    }
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Helper to build a standard decorated text field.
  Widget _buildTextField(
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? decorationIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        suffixIcon: decorationIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.green),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  /// Helper to build the gender selection dropdown.
  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      items: ["Male", "Female"]
          .map((label) => DropdownMenuItem(value: label, child: Text(label)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.green),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
