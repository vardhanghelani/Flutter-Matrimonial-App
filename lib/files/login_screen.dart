import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'DashboardScreen.dart'; // Redirect to Dashboard after login
import 'signup_screen.dart';  // Navigate to sign-up

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  void login() async {
    final user = await dbHelper.getUserByEmail(emailController.text);
    if (user != null && user['password'] == passwordController.text) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"), backgroundColor: Color.fromRGBO(107, 203, 217, 1)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email))),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(107, 203, 217, 1)),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen())),
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
