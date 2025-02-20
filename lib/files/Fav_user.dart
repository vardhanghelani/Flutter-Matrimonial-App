import 'package:flutter/material.dart';
import 'db_helper.dart';

class FavoriteScreen extends StatefulWidget {
  final Function onToggleFavorite;

  FavoriteScreen({required this.onToggleFavorite});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> favoriteUsers = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final users = await dbHelper.getUsers();
    setState(() {
      favoriteUsers = users.where((user) => user['isFavorite'] == 1).toList();
    });
  }

  Future<void> _toggleFavorite(int id) async {
    final user = favoriteUsers.firstWhere((u) => u['id'] == id);
    await dbHelper.updateUser({...user, 'isFavorite': user['isFavorite'] == 1 ? 0 : 1});
    widget.onToggleFavorite();
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Favorite Users"), backgroundColor: Color.fromRGBO(107, 203, 217, 1)),
      body: favoriteUsers.isEmpty
          ? Center(child: Text("No favorite users yet!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: favoriteUsers.length,
        itemBuilder: (context, index) {
          var user = favoriteUsers[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(child: Text(user["name"][0].toUpperCase())),
              title: Text(user["name"], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Email: ${user["email"]}"),
              trailing: IconButton(
                icon: Icon(Icons.favorite, color: Colors.red),
                onPressed: () => _toggleFavorite(user["id"]),
              ),
            ),
          );
        },
      ),
    );
  }
}
