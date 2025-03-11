import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  UserDetailsScreen({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(userData['name'])),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(userData['photo']),
                radius: 50,
              ),
            ),
            SizedBox(height: 20),
            Text("Name: ${userData['name']}", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("City: ${userData['city']}", style: GoogleFonts.poppins(fontSize: 16)),
            SizedBox(height: 10),
            Text("Gender: ${userData['gender']}", style: GoogleFonts.poppins(fontSize: 16)),
            SizedBox(height: 10),
            Text("Hobbies: ${userData['hobbies'].join(', ')}", style: GoogleFonts.poppins(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
