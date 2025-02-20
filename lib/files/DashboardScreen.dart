import 'package:flutter/material.dart';
import 'Registration_screen.dart';
import 'Userlist_screen.dart';
import 'Fav_user.dart';
import 'About_us.dart';

class MyDashboardScreen extends StatefulWidget {
  @override
  _MyDashboardScreenState createState() => _MyDashboardScreenState();
}

class _MyDashboardScreenState extends State<MyDashboardScreen> {
  List<Map<String, dynamic>> users = [
    {
      "name": "John Doe",
      "email": "john.doe@example.com",
      "mobile": "1234567890",
      "dob": "1990-05-12",
      "gender": "Male",
      "city": "Ahmedabad",
      "hobbies": ["Reading", "Traveling", "Music"],
      "isFavorite": false
    },
    {
      "name": "Jane Smith",
      "email": "jane.smith@example.com",
      "mobile": "0987654321",
      "dob": "1992-07-24",
      "gender": "Female",
      "city": "Rajkot",
      "hobbies": ["Dancing", "Cooking", "Yoga"],
      "isFavorite": true
    },
    {
      "name": "Vardhan Ghelani",
      "email": "vg.ghelani@example.com",
      "mobile": "9265190525",
      "dob": "2004-12-24",
      "gender": "Male",
      "city": "Rajkot",
      "hobbies": ["Dancing", "Cooking", "Yoga"],
      "isFavorite": true
    },
    {
      "name": "Aarav Sharma",
      "email": "aarav.sharma@example.com",
      "mobile": "9876543210",
      "dob": "1995-01-15",
      "gender": "Male",
      "city": "Vadodara",
      "hobbies": ["Cricket", "Music", "Traveling"],
      "isFavorite": false
    },
    {
      "name": "Saanvi Patel",
      "email": "saanvi.patel@example.com",
      "mobile": "8765432109",
      "dob": "1998-03-22",
      "gender": "Female",
      "city": "Surat",
      "hobbies": ["Dancing", "Reading", "Cooking"],
      "isFavorite": true
    },
    {
      "name": "Vihaan Gupta",
      "email": "vihaan.gupta@example.com",
      "mobile": "7654321098",
      "dob": "1993-06-30",
      "gender": "Male",
      "city": "Jamnagar",
      "hobbies": ["Football", "Photography", "Traveling"],
      "isFavorite": false
    },
    {
      "name": "Anaya Reddy",
      "email": "anaya.reddy@example.com",
      "mobile": "6543210987",
      "dob": "1996-09-10",
      "gender": "Female",
      "city": "Ahmedabad",
      "hobbies": ["Yoga", "Painting", "Traveling"],
      "isFavorite": true
    },
    {
      "name": "Kabir Khan",
      "email": "kabir.khan@example.com",
      "mobile": "5432109876",
      "dob": "1991-12-05",
      "gender": "Male",
      "city": "Rajkot",
      "hobbies": ["Music", "Gaming", "Traveling"],
      "isFavorite": false
    },
    {
      "name": "Isha Mehta",
      "email": "isha.mehta@example.com",
      "mobile": "4321098765",
      "dob": "1994-11-20",
      "gender": "Female",
      "city": "Ahmedabad",
      "hobbies": ["Cooking", "Dancing", "Traveling"],
      "isFavorite": true
    },
  ];

  void addUser(Map<String, dynamic> user) {
    setState(() {
      users.add(user);
    });
  }

  void updateUser(int index, Map<String, dynamic> updatedUser) {
    setState(() {
      users[index] = updatedUser;
    });
  }

  void deleteUser(int index) {
    setState(() {
      users.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Matrimony',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(107, 203, 217, 1), // Blue Color
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(107, 203, 217, 1),
                  Color.fromRGBO(187, 222, 251, 1),
                ], // Gradient from Blue to Light Blue
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
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
                      builder: (context) =>
                          RegistrationScreen(onUserAdded: addUser),
                    ),
                  );
                }),
                _buildGridItem(context, Icons.list, "Browse Profiles", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserListScreen(
                        users: users,
                        onUpdateUser: updateUser,
                        onDeleteUser: deleteUser,
                      ),
                    ),
                  );
                }),
                _buildGridItem(context, Icons.favorite, "Favorites", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoriteScreen(
                        users: users,
                        onToggleFavorite: (index) {
                          setState(() {
                            users[index]['isFavorite'] =
                            !users[index]['isFavorite'];
                          });
                        },
                      ),
                    ),
                  );
                }),
                _buildGridItem(context, Icons.info, "About Us", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutUsScreen(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Color.fromRGBO(107, 203, 217, 1), // Blue Color
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
