import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'EditUserScreen.dart';

class UserListScreen extends StatefulWidget {
  final Function onUpdateUser;
  final Function onDeleteUser;

  UserListScreen({required this.onUpdateUser, required this.onDeleteUser});

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
    final fetchedUsers = await dbHelper.getUsers();
    setState(() {
      users = fetchedUsers;
    });
  }

  void _deleteUser(int id) async {
    await dbHelper.deleteUser(id);
    widget.onDeleteUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User List"), backgroundColor: Color.fromRGBO(107, 203, 217, 1)),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          var user = users[index];
          return ListTile(
            title: Text(user["name"]),
            subtitle: Text(user["email"]),
            trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteUser(user["id"])),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUserScreen(user: user, onSave: _loadUsers),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
