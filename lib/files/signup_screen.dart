import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  void signUp() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("All fields are required")));
      return;
    }

    final user = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "mobile": "",
      "dob": "",
      "gender": "",
      "city": "",
      "hobbies": "",
      "isFavorite": 0,
    };

    await dbHelper.insertUser(user);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account Created Successfully!")));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up"), backgroundColor: Color.fromRGBO(107, 203, 217, 1)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person))),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email))),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              child: Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(107, 203, 217, 1)),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen())),
              child: Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
