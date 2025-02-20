import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with values from the provided user map
    nameController = TextEditingController(text: widget.user["name"] ?? "");
    emailController = TextEditingController(text: widget.user["email"] ?? "");
    mobileController = TextEditingController(text: widget.user["mobile"] ?? ""); // Fixed the key to "mobile"
    dobController = TextEditingController(text: widget.user["dob"] ?? "");
    cityController = TextEditingController(text: widget.user["city"] ?? "");
    gender = widget.user["gender"] ?? "Male";
    selectedHobbies = List<String>.from(widget.user["hobbies"] ?? []);
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    dobController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Edit User",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: mobileController,
              decoration: InputDecoration(
                labelText: "Mobile",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: dobController,
              decoration: InputDecoration(
                labelText: "Date of Birth",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
              ),
              items: ["Male", "Female", "Other"]
                  .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  gender = value!;
                });
              },
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              onPressed: () {
                widget.onSave({
                  "name": nameController.text,
                  "email": emailController.text,
                  "mobile": mobileController.text, // Ensure "mobile" is saved with the correct key
                  "dob": dobController.text,
                  "city": cityController.text,
                  "gender": gender,
                  "hobbies": selectedHobbies,
                });
                Navigator.pop(context);
              },
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
