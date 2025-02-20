import 'package:flutter/material.dart';
import 'EditUserScreen.dart';

class UserListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final Function(int, Map<String, dynamic>) onUpdateUser;
  final Function(int) onDeleteUser;

  UserListScreen({
    required this.users,
    required this.onUpdateUser,
    required this.onDeleteUser,
  });

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredUsers = [];
  Map<int, bool> expandedUsers = {};

  @override
  void initState() {
    super.initState();
    // Start with all users in the filtered list.
    filteredUsers = List.from(widget.users);
  }

  // Toggle the favorite status directly in the user data.
  void _toggleFavorite(int index) {
    setState(() {
      bool currentFavorite = filteredUsers[index]['isFavorite'] ?? false;
      // Toggle favorite status.
      filteredUsers[index]['isFavorite'] = !currentFavorite;
      // Also update the original user list.
      int originalIndex = widget.users.indexWhere((user) =>
      user['email'] == filteredUsers[index]['email']); // Assuming email is unique.
      if (originalIndex != -1) {
        widget.users[originalIndex]['isFavorite'] = !currentFavorite;
      }
    });
  }

  void _toggleExpanded(int index) {
    setState(() {
      expandedUsers[index] = !(expandedUsers[index] ?? false);
    });
  }

  void _filterUsers(String searchText) {
    setState(() {
      filteredUsers = searchText.isEmpty
          ? List.from(widget.users)
          : widget.users.where((user) {
        return (user['name']?.toLowerCase() ?? '').contains(searchText.toLowerCase()) ||
            (user['email']?.toLowerCase() ?? '').contains(searchText.toLowerCase()) ||
            (user['mobile']?.toLowerCase() ?? '').contains(searchText.toLowerCase());
      }).toList();
    });
  }

  void _editUser(int index) {
    // Create a copy of the user so changes can be saved.
    Map<String, dynamic> user = Map.from(filteredUsers[index]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(
          user: user,
          onSave: (updatedUser) {
            setState(() {
              // Update the filtered user.
              filteredUsers[index] = updatedUser;
              // Also update the original user list.
              int origIndex = widget.users.indexWhere(
                      (u) => u['email'] == updatedUser['email']);
              if (origIndex != -1) {
                widget.users[origIndex] = updatedUser;
              }
            });
          },
        ),
      ),
    );
  }

  void _deleteUser(int index) {
    setState(() {
      // Remove the user from the original list.
      int originalIndex = widget.users.indexWhere(
              (user) => user['email'] == filteredUsers[index]['email']);
      if (originalIndex != -1) {
        widget.onDeleteUser(originalIndex);
      }
      // Refresh the filtered list.
      filteredUsers = List.from(widget.users);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(107, 203, 217, 1),
      ),
      body: Column(
        children: [
          // Search field.
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),
          // User list or "No user found" message.
          Expanded(
            child: filteredUsers.isEmpty
                ? Center(
              child: Text(
                "No user found",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                var user = filteredUsers[index];
                bool isExpanded = expandedUsers[index] ?? false;
                bool isFavorite = user['isFavorite'] ?? false;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row with avatar and favorite icon.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Text(
                                user["name"]
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                              ),
                              onPressed: () => _toggleFavorite(index),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(user["name"],
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        SizedBox(height: 5),
                        Text("Email: ${user["email"]}",
                            style: TextStyle(color: Colors.grey[700])),
                        Text("Mobile: ${user["mobile"] ?? 'Not Available'}",
                            style: TextStyle(color: Colors.grey[700])),
                        Text("DOB: ${user["dob"]}",
                            style: TextStyle(color: Colors.grey[700])),
                        if (isExpanded) ...[
                          SizedBox(height: 8),
                          Text("City: ${user['city'] ?? 'N/A'}",
                              style: TextStyle(color: Colors.grey[700])),
                          Text("Gender: ${user['gender'] ?? 'N/A'}",
                              style: TextStyle(color: Colors.grey[700])),
                          Text(
                              "Interests: ${user['hobbies']?.join(', ') ?? 'N/A'}",
                              style: TextStyle(color: Colors.grey[700])),
                        ],
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              child: Text(
                                isExpanded ? "View Less" : "View More",
                                style: TextStyle(color: Colors.blue),
                              ),
                              onPressed: () => _toggleExpanded(index),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: Colors.green),
                                  onPressed: () => _editUser(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteUser(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
