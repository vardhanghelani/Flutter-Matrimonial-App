import 'package:flutter/material.dart';
import 'DashboardScreen.dart'; // Import Dashboard screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyDashboardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.9, // 90% of screen width
              height: screenHeight * 0.6, // 60% of screen height
              child: Image.asset(
                'assets/couple-logo-design-illustrations-vector.jpg',
                fit: BoxFit.contain, // Ensures full image visibility
              ),
            ),
            SizedBox(height: 20),
            // Text(
            //   'Welcome to Matrimonial App',
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),
          ],
        ),
      ),
    );
  }
}
