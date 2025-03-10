import 'package:flutter/material.dart';
import 'db_helper.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> favoriteUsers = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteUsers();
  }

  // Load favorite users from the database
  void _loadFavoriteUsers() async {
    List<Map<String, dynamic>> favUsers = await dbHelper.getFavoriteUsers();
    setState(() {
      favoriteUsers = favUsers;
    });
  }

  // ✅ Toggle favorite status and refresh
  void _toggleFavorite(int id, bool isFavorite) async {
    await dbHelper.toggleFavorite(id, !isFavorite);
    _loadFavoriteUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorite Users')),
      body: favoriteUsers.isEmpty
          ? Center(child: Text("No favorite users yet!"))
          : ListView.builder(
        itemCount: favoriteUsers.length,
        itemBuilder: (context, index) {
          var user = favoriteUsers[index];
          return Card(
            child: ListTile(
              title: Text(user['name']),
              subtitle: Text(user['email']),
              trailing: IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                onPressed: () => _toggleFavorite(user['id'], user['isFavorite'] == 1),
              ),
            ),
          );
        },
      ),
    );
  }
}
