import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegistrationScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onUserAdded;

  RegistrationScreen({required this.onUserAdded});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _dobController = TextEditingController();

  String? _selectedGender;
  String? _selectedCity;
  File? _selectedImage;

  List<String> genderOptions = ["Male", "Female", "Other"];
  List<String> cityOptions = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix"];
  List<String> hobbies = ["Reading", "Traveling", "Gaming", "Sports", "Music", "Cooking"];
  List<String> selectedHobbies = [];

  /// **📸 Select Image (Camera/Gallery)**
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// **📅 Show Date Picker**
  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime initialDate = _dobController.text.isNotEmpty
        ? DateFormat("dd/MM/yyyy").parse(_dobController.text)
        : DateTime(now.year - 18);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate, // Start from selected date if available
      firstDate: DateTime(now.year - 80),
      lastDate: DateTime(now.year - 18),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  /// **📌 Validations**
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) return "Full name cannot be empty";
    if (!RegExp(r"^[a-zA-Z-' ]{3,50}$").hasMatch(value)) {
      return "Enter a valid full name (3-50 letters)";
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email cannot be empty";
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Mobile number cannot be empty";
    if (!RegExp(r"^\d{10}$").hasMatch(value)) {
      return "Enter a valid 10-digit mobile number";
    }
    return null;
  }

  String? _validateDOB(String? value) {
    if (value == null || value.isEmpty) return "Date of Birth cannot be empty";
    try {
      DateTime dob = DateFormat("dd/MM/yyyy").parse(value);
      DateTime today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      if (age < 18) return "You must be at least 18 years old";
      return null;
    } catch (e) {
      return "Enter a valid date (DD/MM/YYYY)";
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> newUser = {
        "name": _fullNameController.text,
        "email": _emailController.text,
        "mobile": _mobileController.text,
        "dob": _dobController.text,
        "city": _selectedCity,
        "gender": _selectedGender,
        "hobbies": selectedHobbies.join(','),
        "photo": _selectedImage?.path ?? "",
      };

      widget.onUserAdded(newUser);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registration")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// **📸 Photo Selection**
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                /// **📌 Full Name Field**
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(labelText: "Full Name"),
                  validator: _validateFullName,
                ),
                SizedBox(height: 10),

                /// **📌 Email Field**
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),

                /// **📌 Mobile Number Field**
                TextFormField(
                  controller: _mobileController,
                  decoration: InputDecoration(labelText: "Mobile Number"),
                  validator: _validateMobile,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),

                /// **📅 Date of Birth**
                TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    labelText: "Date of Birth",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context), // Open Date Picker directly
                  validator: _validateDOB,
                ),
                SizedBox(height: 10),

                /// **📌 Gender Selection**
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(labelText: "Gender"),
                  items: genderOptions.map((gender) {
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) => value == null ? "Select gender" : null,
                ),
                SizedBox(height: 10),

                /// **📌 City Selection**
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: InputDecoration(labelText: "City"),
                  items: cityOptions.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCity = value),
                ),
                SizedBox(height: 10),

                /// **📌 Hobbies Selection**
                Wrap(
                  spacing: 10,
                  children: hobbies.map((hobby) {
                    return FilterChip(
                      label: Text(hobby),
                      selected: selectedHobbies.contains(hobby),
                      onSelected: (selected) {
                        setState(() {
                          selected
                              ? selectedHobbies.add(hobby)
                              : selectedHobbies.remove(hobby);
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),

                /// **✅ Submit Button**
                ElevatedButton(onPressed: _submitForm, child: Text("Register")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
