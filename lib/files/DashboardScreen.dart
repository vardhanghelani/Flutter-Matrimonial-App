import 'package:flutter/material.dart';
import 'package:matrimonial/files/match_making_screen.dart';
import 'Registration_screen.dart';
import 'Userlist_screen.dart';
import 'About_us.dart';
import 'My_profille_screen.dart';
import 'db_helper.dart';
import 'login_screen.dart';
import 'Fav_user.dart'; // Re-adding import for FavoriteScreen
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class MyDashboardScreen extends StatefulWidget {
  final String loggedInUserEmail;

  MyDashboardScreen({required this.loggedInUserEmail});

  @override
  _MyDashboardScreenState createState() => _MyDashboardScreenState();
}

class _MyDashboardScreenState extends State<MyDashboardScreen> {
  final ApiHelper apiHelper = ApiHelper();
  String userName = "Loading..."; // Default placeholder

  @override
  void initState() {
    super.initState();
    _fetchUserName();

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  Future<void> _fetchUserName() async {
    Map<String, dynamic>? user = await apiHelper.getUserByEmail(widget.loggedInUserEmail);
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
    setState(() {}); // Refresh UI
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear saved data
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
            'Hello, $userName!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            )
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF3F8CFF),
              Color(0xFF00C6FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: screenSize.width > 600 ? 1.5 : 1.0,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildGridItem(
                          context,
                          Icons.person_add_rounded,
                          "Add Profile",
                          "Create a new user profile",
                          Colors.orange,
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistrationScreen(onUserAdded: _addUser),
                              ),
                            );
                          }
                      ),
                      _buildGridItem(
                          context,
                          Icons.people_rounded,
                          "Browse Profiles",
                          "View and search profiles",
                          Colors.purple,
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserListScreen(loggedInUserEmail: widget.loggedInUserEmail),
                              ),
                            );
                          }
                      ),
                      _buildGridItem(
                          context,
                          Icons.person_rounded,
                          "Match making",
                          "Matches made",
                          Colors.teal,
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MatchmakingScreen(),
                              ),
                            );
                          }
                      ),
                      _buildGridItem(
                          context,
                          Icons.info_rounded,
                          "About Us",
                          "Learn more about our app",
                          Colors.indigo,
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AboutUsScreen(),
                              ),
                            );
                          }
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3F8CFF),
                    Color(0xFF00C6FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : "?",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3F8CFF),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Hello, $userName!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.loggedInUserEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.person_rounded,
              title: 'My Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyProfileScreen(loggedInUserEmail: widget.loggedInUserEmail),
                  ),
                );
              },
            ),
            Divider(),
            _buildDrawerItem(
              icon: Icons.people_rounded,
              title: 'All Profiles',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserListScreen(loggedInUserEmail: widget.loggedInUserEmail),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.favorite_rounded,
              title: 'Favorites',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoriteScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.info_rounded,
              title: 'About Us',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutUsScreen(),
                  ),
                );
              },
            ),
            Divider(),
            _buildDrawerItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF3F8CFF)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 0,
    );
  }

  Widget _buildGridItem(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      Color accentColor,
      VoidCallback onTap
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: accentColor,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}