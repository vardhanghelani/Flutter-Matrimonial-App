import 'package:flutter/material.dart';
import 'DashboardScreen.dart';
import 'login_screen.dart';
import 'db_helper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 2)); // Show splash for 2 seconds

    try {
      // Ensure database is initialized before fetching users
      await dbHelper.database;

      final users = await dbHelper.getUsers();

      if (users.isNotEmpty) {
        // If a user exists, navigate to Dashboard
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyDashboardScreen()),
          );
        }
      } else {
        // Otherwise, navigate to Login Page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      }
    } catch (e) {
      print("Error initializing database: $e");
      // Fallback to login screen in case of error
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/couple-logo-design-illustrations-vector.jpg',
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.6,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
