import 'package:flutter/material.dart';
import './files/Splash_Screen.dart';
import './files/DashboardScreen.dart';
import './files/login_screen.dart';
import './files/signup_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matrimonial App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(), // Start with Splash Screen
      routes: {
        '/dashboard': (context) => MyDashboardScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}
