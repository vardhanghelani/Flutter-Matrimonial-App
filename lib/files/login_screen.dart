import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
import 'DashboardScreen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showPassword = false;
  final ApiHelper apiHelper = ApiHelper();

  // Function to show the progress dialog
  void showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Logging in..."),
            ],
          ),
        );
      },
    );
  }

  // Function to hide the progress dialog
  void hideProgressDialog() {
    Navigator.of(context).pop();
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      String enteredEmail = emailController.text.trim();
      String enteredPassword = passwordController.text.trim();

      showProgressDialog(); // Show loading spinner

      try {
        Map<String, dynamic>? user = await apiHelper.getUserByEmail(enteredEmail);

        if (user == null) {
          hideProgressDialog(); // Hide loading spinner
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User does not exist"), backgroundColor: Colors.red),
          );
        } else if (user['password'] != enteredPassword) {
          hideProgressDialog();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid credentials"), backgroundColor: Colors.red),
          );
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('loggedInUserEmail', enteredEmail);

          hideProgressDialog();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login Successful!"), backgroundColor: Colors.green),
          );

          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyDashboardScreen(loggedInUserEmail: enteredEmail)),
            );
          });
        }
      } catch (e) {
        hideProgressDialog();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred. Please try again."), backgroundColor: Colors.red),
        );
        print("Login Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFF9E58E7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: Colors.white, size: 60),
            SizedBox(height: 10),
            Text(
              "Welcome Back!",
              style: GoogleFonts.poppins(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Login to continue",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 30),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email, color: Color(0xFF6A5AE0)),
                      ),
                      validator: (value) => value!.isEmpty ? "Please enter your email" : null,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF6A5AE0)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword ? Icons.visibility : Icons.visibility_off,
                            color: Color(0xFF6A5AE0),
                          ),
                          onPressed: () => setState(() => showPassword = !showPassword),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? "Please enter your password" : null,
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                        backgroundColor: Color(0xFF6A5AE0),
                      ),
                      child: Text("Sign in", style: TextStyle(fontSize: 18,color: Colors.white)),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupScreen()),
                        );
                      },
                      child: Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(
                          color: Color(0xFF6A5AE0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
