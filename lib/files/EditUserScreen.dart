import 'package:flutter/material.dart';
import 'db_helper.dart';

class EditUserScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final Function(Map<String, dynamic>) onSave;

  EditUserScreen({required this.user, required this.onSave});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController dobController;
  late TextEditingController cityController;
  String gender = 'Male';
  List<String> hobbies = ["Reading", "Traveling", "Gaming", "Sports", "Music", "Cooking"];
  List<String> selectedHobbies = [];
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user["name"]);
    emailController = TextEditingController(text: widget.user["email"]);
    mobileController = TextEditingController(text: widget.user["mobile"]);
    dobController = TextEditingController(text: widget.user["dob"]);
    cityController = TextEditingController(text: widget.user["city"]);
    gender = widget.user["gender"];
    selectedHobbies = (widget.user["hobbies"] as String).split(',');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    dobController.dispose();
    cityController.dispose();
    super.dispose();
  }

  void _updateUser() async {
    Map<String, dynamic> updatedUser = {
      "id": widget.user["id"],
      "name": nameController.text,
      "email": emailController.text,
      "mobile": mobileController.text,
      "dob": dobController.text,
      "city": cityController.text,
      "gender": gender,
      "hobbies": selectedHobbies.join(','),
    };

    await dbHelper.updateUser(updatedUser);
    widget.onSave(updatedUser);
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
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Full Name")),
            SizedBox(height: 10),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            SizedBox(height: 10),
            TextField(controller: mobileController, decoration: InputDecoration(labelText: "Mobile")),
            SizedBox(height: 10),
            TextField(controller: dobController, decoration: InputDecoration(labelText: "Date of Birth")),
            SizedBox(height: 10),
            TextField(controller: cityController, decoration: InputDecoration(labelText: "City")),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: InputDecoration(labelText: "Gender"),
              items: ["Male", "Female", "Other"]
                  .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                  .toList(),
              onChanged: (value) => setState(() => gender = value!),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: hobbies.map((hobby) {
                bool isSelected = selectedHobbies.contains(hobby);
                return FilterChip(
                  label: Text(hobby),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedHobbies.add(hobby);
                      } else {
                        selectedHobbies.remove(hobby);
                      }
                    });
                  },
                  selectedColor: Colors.purple,
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: _updateUser,
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
