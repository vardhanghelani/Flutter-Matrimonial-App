import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'dart:io';
import 'EditUserScreen.dart';
import 'package:intl/intl.dart';

class UserListScreen extends StatefulWidget {
  final String loggedInUserEmail;

  UserListScreen({required this.loggedInUserEmail});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ApiHelper apiHelper = ApiHelper();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  // Track which user is having their favorite status updated
  String? updatingFavoriteForUserId;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);

    try {
      final fetchedUsers = await apiHelper.getUsers();
      setState(() {
        users = fetchedUsers.where((user) => user['email'] != widget.loggedInUserEmail).toList();
        _filterUsers();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Error loading users: $e", Colors.red);
    }
  }

  void _toggleFavorite(String id, bool currentStatus) async {
    // Set the updating state for this specific user
    setState(() {
      updatingFavoriteForUserId = id;
    });

    try {
      final newStatus = currentStatus ? 0 : 1;
      await apiHelper.updateUser(id, {'isFavorite': newStatus});

      setState(() {
        for (int i = 0; i < users.length; i++) {
          if (users[i]['id'] == id) {
            users[i]['isFavorite'] = newStatus;
            break;
          }
        }
        _filterUsers();
        // Clear the updating state
        updatingFavoriteForUserId = null;
      });

      _showSnackBar(
          newStatus == 1 ? "Added to favorites" : "Removed from favorites",
          newStatus == 1 ? Colors.green : Colors.blue
      );
    } catch (e) {
      setState(() {
        // Clear the updating state in case of error too
        updatingFavoriteForUserId = null;
      });
      _showSnackBar("Failed to update favorite status", Colors.red);
    }
  }

  void _filterUsers() {
    filteredUsers = List.from(users);

    if (isSearching && searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      filteredUsers = filteredUsers.where((user) {
        final name = user['name']?.toString().toLowerCase() ?? '';
        final email = user['email']?.toString().toLowerCase() ?? '';
        final city = user['city']?.toString().toLowerCase() ?? '';
        return name.contains(query) || email.contains(query) || city.contains(query);
      }).toList();
    }
  }

  void _editUser(String id, Map<String, dynamic> updatedUser) async {
    setState(() => isLoading = true);

    try {
      await apiHelper.updateUser(id, updatedUser);

      setState(() {
        for (int i = 0; i < users.length; i++) {
          if (users[i]['id'] == id) {
            users[i] = {...users[i], ...updatedUser};
            break;
          }
        }
        _filterUsers();
        isLoading = false;
      });

      _showSnackBar("User updated successfully", Colors.green);
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Failed to update user", Colors.red);
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
                setState(() => isLoading = true);

                try {
                  await apiHelper.deleteUser(id);
                  _loadUsers();
                  _showSnackBar("User deleted successfully", Colors.green);
                } catch (e) {
                  setState(() => isLoading = false);
                  _showSnackBar("Failed to delete user", Colors.red);
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

  int? _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return null;

    try {
      DateTime birthDate;

      // Try different date formats
      List<String> parts = dob.split('/');
      if (parts.length == 3) {
        // DD/MM/YYYY format
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        birthDate = DateTime(year, month, day);
      } else {
        // Try standard formats
        try {
          birthDate = DateFormat("yyyy-MM-dd").parse(dob);
        } catch (_) {
          birthDate = DateTime.parse(dob);
        }
      }

      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return age > 0 ? age : null;
    } catch (e) {
      return null;
    }
  }

  void _toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        _filterUsers();
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

    // Fallback to UI Avatars API
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

    // Format DOB if available
    String formattedDob = 'N/A';
    if (user['dob'] != null && user['dob'].toString().isNotEmpty) {
      try {
        DateTime birthDate = DateFormat("yyyy-MM-dd").parse(user['dob']);
        formattedDob = DateFormat("MMMM d, yyyy").format(birthDate);
      } catch (e) {
        formattedDob = user['dob'];
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 10),

                  // User details in grid format
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              Icons.location_city,
                              "City",
                              user['city'] ?? 'N/A',
                            ),
                          ),
                          Expanded(
                            child: _buildDetailItem(
                              Icons.wc,
                              "Gender",
                              user['gender'] ?? 'N/A',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              Icons.phone,
                              "Mobile",
                              user['mobile'] ?? 'N/A',
                            ),
                          ),
                          Expanded(
                            child: _buildDetailItem(
                              Icons.cake,
                              "Date of Birth",
                              formattedDob,
                            ),
                          ),
                        ],
                      ),
                    ],
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
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Card(
      elevation: 1,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.indigo),
                SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
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

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent[400],
        foregroundColor: Colors.white,
        elevation: 0,
        title: isSearching
            ? TextField(
          controller: searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search users...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _filterUsers();
            });
          },
          autofocus: true,
        )
            : Text("Favorite Users", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurpleAccent[100]!, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(color: Colors.deepPurpleAccent[400]),
        )
            : filteredUsers.isEmpty
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
            Icons.people_outline,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            isSearching ? "No matching users found" : "No users available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            isSearching ? "Try a different search term" : "Users will appear here when added",
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
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        final int? age = _calculateAge(user['dob']);
        final bool isFavorite = user['isFavorite'] == 1;
        final bool isUpdatingFavorite = updatingFavoriteForUserId == user['id'];

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
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  // User Avatar
                  Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _getUserImage(user, 60),
                    ),
                  ),

                  // User Info - Only Name, Age and City visible
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Age row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user['name'],
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
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
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),

                        // Email
                        Text(
                          user['email'],
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),

                        // City
                        if (user['city'] != null && user['city'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Text(
                                  user['city'],
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Column(
                    children: [
                      // Favorite button with loading indicator
                      isUpdatingFavorite
                          ? Container(
                        width: 24,
                        height: 24,
                        margin: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                        ),
                      )
                          : IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(user['id'], isFavorite),
                      ),
                      // More options
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