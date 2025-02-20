import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'Registration_screen.dart';
import 'Userlist_screen.dart';
import 'Fav_user.dart';
import 'About_us.dart';

class MyDashboardScreen extends StatefulWidget {
  @override
  _MyDashboardScreenState createState() => _MyDashboardScreenState();
}

class _MyDashboardScreenState extends State<MyDashboardScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Matrimonial"), backgroundColor: Color.fromRGBO(107, 203, 217, 1)),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(20),
        children: [
          _buildGridItem(context, Icons.person_add, "Add Profile", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreen(onUserAdded: _loadUsers)));
          }),
          _buildGridItem(context, Icons.list, "Browse Profiles", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserListScreen(onUpdateUser: _loadUsers, onDeleteUser: _loadUsers)));
          }),
          _buildGridItem(context, Icons.favorite, "Favorites", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FavoriteScreen(onToggleFavorite: _loadUsers)));
          }),
          _buildGridItem(context, Icons.info, "About Us", () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 50, color: Color.fromRGBO(107, 203, 217, 1)), SizedBox(height: 10), Text(label)]),
      ),
    );
  }
}
