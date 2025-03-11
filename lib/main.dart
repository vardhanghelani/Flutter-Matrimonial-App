import 'package:flutter/material.dart';
import 'files/login_screen.dart';
import 'files/DashboardScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? loggedInEmail = prefs.getString('loggedInUserEmail');

  runApp(MyApp(
    initialScreen: loggedInEmail != null
        ? MyDashboardScreen(loggedInUserEmail: loggedInEmail)
        : LoginScreen(),
  ));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  MyApp({required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: initialScreen,
    );
  }
}
