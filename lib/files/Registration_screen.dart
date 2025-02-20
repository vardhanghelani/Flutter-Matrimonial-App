import 'package:flutter/material.dart';
import 'db_helper.dart';

class RegistrationScreen extends StatefulWidget {
  final Function onUserAdded;

  RegistrationScreen({required this.onUserAdded});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();
  String? _selectedGender;
  String? _selectedCity;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final newUser = {
        "name": _nameController.text,
        "email": _emailController.text,
        "mobile": _mobileController.text,
        "dob": _dobController.text,
        "gender": _selectedGender,
        "city": _selectedCity,
        "hobbies": "",
        "isFavorite": 0,
      };
      await dbHelper.insertUser(newUser);
      widget.onUserAdded();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add User"), backgroundColor: Color.fromRGBO(107, 203, 217, 1)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, "Full Name", Icons.person),
              _buildTextField(_emailController, "Email", Icons.email),
              _buildTextField(_mobileController, "Mobile Number", Icons.phone),
              _buildTextField(_dobController, "Date of Birth", Icons.calendar_today),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text("Save")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(prefixIcon: Icon(icon), labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
