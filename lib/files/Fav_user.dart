import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  final List<Map<String, dynamic>> users;

  final Function(int) onToggleFavorite;

  FavoriteScreen({required this.users, required this.onToggleFavorite});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    // Filter users to include only those marked as favorite.
    List<Map<String, dynamic>> favoriteUsers =
    widget.users.where((user) => user['isFavorite'] == true).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Users'),
        backgroundColor: Color.fromRGBO(107, 203, 217, 1),
      ),
      body: favoriteUsers.isEmpty
          ? Center(
        child: Text(
          'No favorite users yet!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: favoriteUsers.length,
        itemBuilder: (context, index) {
          var user = favoriteUsers[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with avatar and name.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              user["name"].substring(0, 1).toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            user["name"],
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            widget.onToggleFavorite(
                                widget.users.indexOf(user));
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("Email: ${user["email"]}",
                      style: TextStyle(color: Colors.grey[700])),
                  Text("Mobile: ${user["mobile"]}",
                      style: TextStyle(color: Colors.grey[700])),
                  Text("DOB: ${user["dob"]}",
                      style: TextStyle(color: Colors.grey[700])),
                  Text("City: ${user["city"]}",
                      style: TextStyle(color: Colors.grey[700])),
                  Text(
                    "Hobbies: ${user["hobbies"]?.join(', ') ?? 'N/A'}",
                    style: TextStyle(color: Colors.grey[700]),
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
