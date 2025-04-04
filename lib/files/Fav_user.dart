import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'dart:io';
import 'EditUserScreen.dart';
import 'package:intl/intl.dart';

class FavoritesScreen extends StatefulWidget {
  final String loggedInUserEmail;

  FavoritesScreen({required this.loggedInUserEmail});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiHelper apiHelper = ApiHelper();
  List<Map<String, dynamic>> favoriteUsers = [];
  bool isLoading = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFavoriteUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> fetchedUsers = await apiHelper.getUsers();
      setState(() {
        // Filter for favorites only and exclude logged in user
        favoriteUsers = fetchedUsers
            .where((user) =>
        user['isFavorite'] == 1 &&
            user['email'] != widget.loggedInUserEmail)
            .toList();

        _applySearch();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading favorite users: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _applySearch() {
    if (isSearching && searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      setState(() {
        favoriteUsers = favoriteUsers.where((user) {
          final name = user['name']?.toString().toLowerCase() ?? '';
          final email = user['email']?.toString().toLowerCase() ?? '';
          final city = user['city']?.toString().toLowerCase() ?? '';
          return name.contains(query) || email.contains(query) || city.contains(query);
        }).toList();
      });
    }
  }

  void _editUser(String id, Map<String, dynamic> updatedUser) async {
    setState(() {
      isLoading = true;
    });

    try {
      await apiHelper.updateUser(id, updatedUser);
      _loadFavoriteUsers(); // Reload to reflect changes

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User updated successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update user"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _deleteUser(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text("Confirm Deletion"),
            ],
          ),
          content: Text("Are you sure you want to delete this user? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  isLoading = true;
                });

                try {
                  await apiHelper.deleteUser(id);
                  _loadFavoriteUsers();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("User deleted successfully"),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to delete user"),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("DELETE"),
            ),
          ],
        );
      },
    );
  }

  void _removeFromFavorites(String id) async {
    try {
      await apiHelper.updateUser(id, {'isFavorite': 0});

      // Remove from local list
      setState(() {
        favoriteUsers.removeWhere((user) => user['id'] == id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User removed from favorites"),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update favorite status"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  int? _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return null;
    try {
      DateTime birthDate = DateFormat("yyyy-MM-dd").parse(dob);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        _loadFavoriteUsers(); // Reset search
      }
    });
  }

  Widget _getUserImage(Map<String, dynamic> user, double size) {
    final imagePath = user['imagePath'];

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }
    }

    // Fallback to UI Avatars API for a generated avatar
    return Image.network(
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user['name'])}&background=random',
      width: size,
      height: size,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.indigo,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          color: Colors.grey[200],
          child: Icon(Icons.person, size: size * 0.5, color: Colors.grey[400]),
        );
      },
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    int? age = _calculateAge(user['dob']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.indigo, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _getUserImage(user, 100),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          user['name'],
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo[800]),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          user['email'],
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 5),
                        if (age != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                            ),
                            child: Text(
                              "$age years old",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 30,
                      ),
                      onPressed: () {
                        _removeFromFavorites(user['id']);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 10),

                // User details in attractive format
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDetailColumn(Icons.location_city, "City", user['city'] ?? 'N/A'),
                      VerticalDivider(thickness: 1),
                      _buildDetailColumn(Icons.wc, "Gender", user['gender'] ?? 'N/A'),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                if (user['hobbies'] != null && user['hobbies'].toString().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hobbies",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (user['hobbies'] as String)
                            .split(',')
                            .map((hobby) => Chip(
                          label: Text(hobby.trim()),
                          backgroundColor: Colors.indigo.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.indigo.withOpacity(0.3)),
                          ),
                        ))
                            .toList(),
                      ),
                    ],
                  ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit,
                      label: "Edit",
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditUserScreen(
                              user: user,
                              onSave: (updatedUser) => _editUser(user['id'], updatedUser),
                            ),
                          ),
                        );
                      },
                    ),
                    _buildActionButton(
                      icon: Icons.delete,
                      label: "Delete",
                      color: Colors.red,
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteUser(user['id']);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailColumn(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.indigo),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
        elevation: 0,
        title: isSearching
            ? TextField(
          controller: searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search favorites...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _loadFavoriteUsers();
            _applySearch();
          },
          autofocus: true,
        )
            : Row(
          children: [
            Icon(Icons.favorite, color: Colors.white),
            SizedBox(width: 10),
            Text("Favorite Users", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadFavoriteUsers,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red[100]!, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(color: Colors.red[400]),
        )
            : favoriteUsers.isEmpty
            ? _buildEmptyState()
            : _buildUserList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            isSearching ? "No matching favorites found" : "No favorite users yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            isSearching
                ? "Try a different search term"
                : "Add favorites from the user list",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemCount: favoriteUsers.length,
      itemBuilder: (context, index) {
        final user = favoriteUsers[index];
        int? age = _calculateAge(user['dob']);

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showUserDetails(user),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                    ),
                    child: ClipOval(
                      child: _getUserImage(user, 60),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user['name'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (age != null)
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Text(
                                  "$age yrs",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          user['email'],
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 4),
                        if (user['city'] != null && user['city'].toString().isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                              SizedBox(width: 4),
                              Text(
                                user['city'],
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeFromFavorites(user['id']),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditUserScreen(
                                  user: user,
                                  onSave: (updatedUser) => _editUser(user['id'], updatedUser),
                                ),
                              ),
                            );
                          } else if (value == 'delete') {
                            _deleteUser(user['id']);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}