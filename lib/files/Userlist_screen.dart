import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'dart:io';
import 'EditUserScreen.dart';
import 'package:intl/intl.dart'; // For Date Formatting

class UserListScreen extends StatefulWidget {
  final String loggedInUserEmail;

  UserListScreen({required this.loggedInUserEmail});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    List<Map<String, dynamic>> fetchedUsers = await dbHelper.getUsers();

    setState(() {
      users = fetchedUsers.where((user) => user['email'] != widget.loggedInUserEmail).toList();
    });
  }

  void _editUser(int id, Map<String, dynamic> updatedUser) async {
    await dbHelper.updateUser(updatedUser);
    _loadUsers();
  }

  void _deleteUser(int id) async {
    await dbHelper.deleteUser(id);
    _loadUsers();
  }

  void _toggleLike(int id, bool isFavorite) async {
    await dbHelper.updateUser({'id': id, 'isFavorite': isFavorite ? 0 : 1});
    _loadUsers();
  }

  /// **🧮 Calculate Age from DOB**
  int? _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return null; // Return null if DOB is not provided
    try {
      DateTime birthDate = DateFormat("yyyy-MM-dd").parse(dob);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--; // Adjust age if birthday hasn't occurred yet this year
      }
      return age;
    } catch (e) {
      return null; // Return null if there's a parsing error
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    int? age = _calculateAge(user['dob']); // Calculate Age

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text("User Details", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              user['photo'] != null
                  ? ClipOval(
                child: Image.file(File(user['photo']), width: 80, height: 80, fit: BoxFit.cover),
              )
                  : Icon(Icons.person, size: 80, color: Colors.grey),
              SizedBox(height: 10),
              Text("📛 Name: ${user['name']}", style: TextStyle(fontSize: 16)),
              Text("📧 Email: ${user['email']}", style: TextStyle(fontSize: 16)),
              Text("📍 City: ${user['city'] ?? 'N/A'}", style: TextStyle(fontSize: 16)),
              Text("🎂 DOB: ${user['dob'] ?? 'N/A'}", style: TextStyle(fontSize: 16)),
              Text("🎈 Age: ${age != null ? '$age years' : 'N/A'}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
              Text("🚻 Gender: ${user['gender'] ?? 'N/A'}", style: TextStyle(fontSize: 16)),
              Text("🎨 Hobbies: ${user['hobbies'] ?? 'N/A'}", style: TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User List")),
      body: users.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 80, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No users available",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          bool isFavorite = user['isFavorite'] == 1;

          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading: user['photo'] != null
                  ? ClipOval(
                child: Image.file(File(user['photo']), width: 50, height: 50, fit: BoxFit.cover),
              )
                  : Icon(Icons.person, size: 50, color: Colors.grey),
              title: Text(user['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(user['email']),
              onTap: () => _showUserDetails(user), // Show user details on tap
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey),
                    onPressed: () => _toggleLike(user['id'], isFavorite),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserScreen(
                          user: user,
                          onSave: (updatedUser) => _editUser(user['id'], updatedUser),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteUser(user['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
