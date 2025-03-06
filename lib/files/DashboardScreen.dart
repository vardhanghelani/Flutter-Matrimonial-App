import 'package:flutter/material.dart';
import 'Registration_screen.dart';
import 'Userlist_screen.dart';
import 'Fav_user.dart';
import 'About_us.dart';
import 'db_helper.dart';

class MyDashboardScreen extends StatefulWidget {
  final String loggedInUserEmail;

  MyDashboardScreen({required this.loggedInUserEmail});

  @override
  _MyDashboardScreenState createState() => _MyDashboardScreenState();
}

class _MyDashboardScreenState extends State<MyDashboardScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  String userName = "Loading..."; // Default placeholder

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    Map<String, dynamic>? user = await dbHelper.getUserByEmail(widget.loggedInUserEmail);
    if (user != null) {
      setState(() {
        userName = user['name'] ?? "User"; // Use stored name or default
      });
    } else {
      setState(() {
        userName = "Unknown User"; // Fallback in case of error
      });
    }
  }

  void _addUser() {
    _fetchUserName(); // Refresh user list after adding a new user
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $userName!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromRGBO(107, 203, 217, 1),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(107, 203, 217, 1),
                  Color.fromRGBO(187, 222, 251, 1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Main Grid Layout
          Center(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              padding: EdgeInsets.all(20),
              children: [
                _buildGridItem(context, Icons.person_add, "Add Profile", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrationScreen(onUserAdded: _addUser),
                    ),
                  );
                }),
                _buildGridItem(context, Icons.list, "Browse Profiles", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserListScreen(loggedInUserEmail: widget.loggedInUserEmail),
                    ),
                  );
                }),
                _buildGridItem(context, Icons.favorite, "Favorites", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FavoriteScreen()));
                }),
                _buildGridItem(context, Icons.info, "About Us", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsScreen()));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Color.fromRGBO(107, 203, 217, 1)),
            SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
