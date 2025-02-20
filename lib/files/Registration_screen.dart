import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegistrationScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onUserAdded;

  RegistrationScreen({required this.onUserAdded});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;
  String? _selectedCity;
  List<String> _selectedHobbies = [];
  final List<String> _hobbies = ["Reading", "Traveling", "Gaming", "Sports", "Music", "Cooking"];
  final List<String> _cities = ["Ahemdabad", "Rajkot", "Surat", "Vadodara", "Jamnagar"];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newUser = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "mobile": _phoneController.text.trim(),
        "dob": _dobController.text.trim(),
        "gender": _selectedGender,
        "city": _selectedCity,
        "hobbies": _selectedHobbies, // Saving selected hobbies
      };

      print("New User: $newUser"); // Debugging statement to confirm data
      widget.onUserAdded(newUser);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add User")
      ,backgroundColor: Color.fromRGBO(107, 203, 217, 1),),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, "Full Name", Icons.person, r"^[a-zA-Z\s]{3,50}$", "Enter a valid name"),
              _buildTextField(_emailController, "Email", Icons.email, r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$", "Enter a valid email"),
              _buildTextField(_phoneController, "Mobile Number", Icons.phone, r"^\d{10,15}$", "Enter a valid mobile number"),
              _buildDateField(),
              SizedBox(height: 16),
              _buildGenderSelection(),
              SizedBox(height: 16),
              _buildCityDropdown(),
              SizedBox(height: 16),
              _buildHobbiesSelection(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Color.fromRGBO(107, 203, 217, 1), // Set text color to match the theme
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, String pattern, String errorMsg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label cannot be empty";
          }
          if (!RegExp(pattern).hasMatch(value)) {
            return errorMsg;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Date of Birth",
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
          }
        },
      ),
    );
  }

  Widget _buildGenderSelection() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Gender",
        border: OutlineInputBorder(),
      ),
      value: _selectedGender,
      items: ["Male", "Female", "Other"]
          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
      validator: (value) => value == null ? "Please select a gender" : null,
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "City",
        border: OutlineInputBorder(),
      ),
      value: _selectedCity,
      items: _cities
          .map((city) => DropdownMenuItem(value: city, child: Text(city)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCity = value;
        });
      },
      validator: (value) => value == null ? "Please select a city" : null,
    );
  }

  Widget _buildHobbiesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Hobbies", style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 10,
          children: _hobbies.map((hobby) {
            return FilterChip(
              label: Text(hobby),
              selected: _selectedHobbies.contains(hobby),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedHobbies.add(hobby);
                  } else {
                    _selectedHobbies.remove(hobby);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
