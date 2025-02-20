import 'package:flutter/material.dart';
import 'db_helper.dart';

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final Function onSave;

  EditUserScreen({required this.user, required this.onSave});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController dobController;
  late TextEditingController cityController;
  String gender = 'Male';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user["name"]);
    emailController = TextEditingController(text: widget.user["email"]);
    mobileController = TextEditingController(text: widget.user["mobile"]);
    dobController = TextEditingController(text: widget.user["dob"]);
    cityController = TextEditingController(text: widget.user["city"]);
    gender = widget.user["gender"];
  }

  Future<void> _saveUser() async {
    final updatedUser = {
      "id": widget.user["id"],
      "name": nameController.text,
      "email": emailController.text,
      "mobile": mobileController.text,
      "dob": dobController.text,
      "city": cityController.text,
      "gender": gender,
      "hobbies": widget.user["hobbies"],
      "isFavorite": widget.user["isFavorite"],
    };
    await dbHelper.updateUser(updatedUser);
    widget.onSave();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit User"), backgroundColor: Colors.purple),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(nameController, "Full Name", Icons.person),
            _buildTextField(emailController, "Email", Icons.email),
            _buildTextField(mobileController, "Mobile", Icons.phone),
            _buildTextField(dobController, "Date of Birth", Icons.calendar_today),
            _buildTextField(cityController, "City", Icons.location_city),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
              items: ["Male", "Female", "Other"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (value) => setState(() => gender = value!),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveUser, child: Text("Save")),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(controller: controller, decoration: InputDecoration(prefixIcon: Icon(icon), labelText: label, border: OutlineInputBorder())),
    );
  }
}
