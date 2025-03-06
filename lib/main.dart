import 'package:flutter/material.dart';
import './files/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),  // ✅ Ensure this is the correct widget
    );
  }
}
