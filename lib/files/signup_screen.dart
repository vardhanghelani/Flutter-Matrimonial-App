import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'db_helper.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final ApiHelper apiHelper = ApiHelper();

  late ProgressDialog _progressDialog; // Progress dialog

  @override
  void initState() {
    super.initState();
    _progressDialog = ProgressDialog(context);
    _progressDialog.style(
      message: "Signing up...",
      progressWidget: CircularProgressIndicator(),
    );
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      // Show Progress Dialog
      _progressDialog.show();

      try {
        String name = nameController.text.trim();
        String email = emailController.text.trim();
        String password = passwordController.text.trim();
        String mobile = mobileController.text.trim();

        // Check if user already exists
        Map<String, dynamic>? existingUser = await apiHelper.getUserByEmail(email);
        if (existingUser != null) {
          _progressDialog.hide();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Email already registered! Try another."), backgroundColor: Colors.red),
          );
          return;
        }

        // Insert user into database
        await apiHelper.insertUser({
          "name": name,
          "email": email,
          "password": password,
          "mobile": mobile,
          "dob": "",
          "gender": "",
          "city": "",
          "hobbies": "",
          "isFavorite": 0,
        });

        _progressDialog.hide(); // Hide Progress Dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup Successful! Please login."), backgroundColor: Colors.green),
        );

        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
        });

      } catch (e) {
        _progressDialog.hide();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Something went wrong! Try again."), backgroundColor: Colors.red),
        );
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),

              // Heart Logo
              Icon(Icons.favorite, color: Colors.white, size: 60),
              SizedBox(height: 10),

              // "Create Account" Title
              Text(
                "Create Account",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Fill in the details below",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 30),

              // Signup Form
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name Field
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: Icon(Icons.person, color: Color(0xFF6A5AE0)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your name";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      // Email Field
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email, color: Color(0xFF6A5AE0)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }
                          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      // Password Field
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock, color: Color(0xFF6A5AE0)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a password";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      // Mobile Number Field
                      TextFormField(
                        controller: mobileController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Mobile Number",
                          prefixIcon: Icon(Icons.phone, color: Color(0xFF6A5AE0)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your mobile number";
                          }
                          if (value.length != 10) {
                            return "Mobile number must be exactly 10 digits";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      // Sign Up Button
                      ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                          backgroundColor: Color(0xFF6A5AE0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Sign Up", style: TextStyle(fontSize: 18,color: Colors.white)),
                      ),

                      SizedBox(height: 10),

                      // Already Have an Account? Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                            },
                            child: Text("Login Here", style: TextStyle(color: Color(0xFF6A5AE0))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
