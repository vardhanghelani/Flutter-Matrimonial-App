import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert'; // For JSON debugging

// Import your ApiHelper
import 'db_helper.dart';

class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({Key? key}) : super(key: key);

  @override
  _MatchmakingScreenState createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  final ApiHelper _apiHelper = ApiHelper();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _matches = [];
  List<Map<String, dynamic>> _filteredUsers = []; // For debugging
  bool _isLoading = true;
  String _matchCriteria = 'city'; // Default matching criteria
  String? _currentUserGender;
  Map<String, dynamic>? _currentUser;
  bool _debugMode = true; // Enable debugging
  String _debugInfo = ''; // Store debug information

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Helper function to add to debug logs
  void _addDebugInfo(String info) {
    if (_debugMode) {
      setState(() {
        _debugInfo = info + '\n' + _debugInfo;
        // Limit debug info length
        if (_debugInfo.length > 5000) {
          _debugInfo = _debugInfo.substring(0, 5000);
        }
      });
      print(info);
    }
  }

  // Helper function to dump object details
  String _dumpObject(dynamic obj) {
    try {
      if (obj is Map) {
        return json.encode(obj);
      } else {
        return obj.toString();
      }
    } catch (e) {
      return "Error dumping object: $e";
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _debugInfo = '';
    });

    try {
      _users = await _apiHelper.getUsers();

      _addDebugInfo('**** DATA LOADED ****');
      _addDebugInfo('Loaded ${_users.length} users');

      // Data validation check
      int maleCount = 0;
      int femaleCount = 0;
      Map<String, List<String>> cityGenderMap = {};

      if (_users.isEmpty) {
        _addDebugInfo('WARNING: No users found in the database!');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Debug all users first
      for (var user in _users) {
        _addDebugInfo('User Data: ${_dumpObject(user)}');
      }

      for (var user in _users) {
        String userId = user['id']?.toString() ?? 'unknown';
        String gender = (user['gender'] ?? '').toString().toLowerCase().trim();
        String city = (user['city'] ?? '').toString().toLowerCase().trim();

        // Count genders
        if (gender == 'male') maleCount++;
        if (gender == 'female') femaleCount++;

        // Map cities to genders
        if (city.isNotEmpty) {
          if (!cityGenderMap.containsKey(city)) {
            cityGenderMap[city] = [];
          }
          cityGenderMap[city]?.add(gender);
        }

        _addDebugInfo('User $userId: Gender="$gender", City="$city"');
      }

      // Report city/gender distribution
      _addDebugInfo('Gender distribution: $maleCount males, $femaleCount females');

      for (var city in cityGenderMap.keys) {
        List<String> genders = cityGenderMap[city] ?? [];
        bool hasMale = genders.contains('male');
        bool hasFemale = genders.contains('female');

        if (hasMale && hasFemale) {
          _addDebugInfo('City "$city" has both males and females');
        } else if (hasMale) {
          _addDebugInfo('City "$city" has only males');
        } else if (hasFemale) {
          _addDebugInfo('City "$city" has only females');
        }
      }

      // Get current user - try to find any user ID since we need one for testing
      // In a real app, this would come from authentication
      String currentUserId;

      // Try to find a user ID from the loaded users
      if (_users.isNotEmpty && _users[0]['id'] != null) {
        currentUserId = _users[0]['id'].toString();
        _addDebugInfo('Using first available user ID: $currentUserId');
      } else {
        // Fallback to hardcoded ID if needed
        currentUserId = '16'; // Updated to match the sample data
        _addDebugInfo('Falling back to hardcoded ID: $currentUserId');
      }

      _currentUser = await _apiHelper.getUserById(currentUserId);

      if (_currentUser != null) {
        _addDebugInfo('Current User Data: ${_dumpObject(_currentUser)}');
        _currentUserGender = (_currentUser!['gender'] ?? '').toString().toLowerCase().trim();
        String currentUserCity = (_currentUser!['city'] ?? '').toString().toLowerCase().trim();

        _addDebugInfo('Current User: ID=${_currentUser!['id']}, Gender="$_currentUserGender", City="$currentUserCity"');

        // Check if there are potential matches
        if (_currentUserGender == 'male') {
          List<String> cities = cityGenderMap.keys
              .where((city) => cityGenderMap[city]?.contains('female') ?? false)
              .toList();
          _addDebugInfo('Cities with females (potential matches): ${cities.join(", ")}');

          if (currentUserCity.isNotEmpty) {
            bool cityHasFemales = cityGenderMap[currentUserCity]?.contains('female') ?? false;
            _addDebugInfo('Current user\'s city "$currentUserCity" has females: $cityHasFemales');
          }
        } else if (_currentUserGender == 'female') {
          List<String> cities = cityGenderMap.keys
              .where((city) => cityGenderMap[city]?.contains('male') ?? false)
              .toList();
          _addDebugInfo('Cities with males (potential matches): ${cities.join(", ")}');

          if (currentUserCity.isNotEmpty) {
            bool cityHasMales = cityGenderMap[currentUserCity]?.contains('male') ?? false;
            _addDebugInfo('Current user\'s city "$currentUserCity" has males: $cityHasMales');
          }
        } else {
          _addDebugInfo('WARNING: Current user has invalid gender: "$_currentUserGender"');
        }

        _findMatches();
      } else {
        _addDebugInfo('Error: Current user not found with ID: $currentUserId');
        _addDebugInfo('Available user IDs: ${_users.map((u) => u['id']).join(', ')}');
      }
    } catch (e) {
      _addDebugInfo('Error loading users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _findMatches() {
    if (_currentUser == null) {
      _addDebugInfo('Cannot find matches: Current user is null');
      return;
    }

    if (_currentUserGender == null || _currentUserGender!.isEmpty) {
      _addDebugInfo('Cannot find matches: Current user gender is null/empty');
      return;
    }

    // Determine opposite gender
    String oppositeGender = _currentUserGender == 'male' ? 'female' : 'male';
    _addDebugInfo('Finding matches for $_currentUserGender looking for $oppositeGender');
    _addDebugInfo('Match criteria: $_matchCriteria');

    // Make copy of all users for filtering and debugging
    _filteredUsers = List.from(_users);

    // Step 1: Filter out current user
    var beforeUserFilterCount = _filteredUsers.length;
    _filteredUsers.removeWhere((user) => user['id'].toString() == _currentUser!['id'].toString());
    _addDebugInfo('After removing current user: ${_filteredUsers.length} users left (removed ${beforeUserFilterCount - _filteredUsers.length})');

    if (_filteredUsers.isEmpty) {
      _addDebugInfo('WARNING: No users left after removing current user');
      setState(() {
        _matches = [];
      });
      return;
    }

    // Step 2: Filter by gender
    var beforeGenderCount = _filteredUsers.length;
    _filteredUsers = _filteredUsers.where((user) {
      String userGender = (user['gender'] ?? '').toString().toLowerCase().trim();
      bool isOppositeGender = userGender == oppositeGender;

      // Debug individual gender checks
      String userId = user['id']?.toString() ?? 'unknown';
      _addDebugInfo('User $userId gender check: "$userGender" == "$oppositeGender" = $isOppositeGender');

      return isOppositeGender;
    }).toList();

    _addDebugInfo('After gender filter: ${_filteredUsers.length} users left (removed ${beforeGenderCount - _filteredUsers.length})');

    if (_filteredUsers.isEmpty) {
      _addDebugInfo('WARNING: No users of opposite gender found');
      setState(() {
        _matches = [];
      });
      return;
    }

    // Step 3: Apply matching criteria
    if (_matchCriteria == 'city') {
      final currentUserCity = (_currentUser!['city'] ?? '').toString().toLowerCase().trim();

      if (currentUserCity.isEmpty) {
        _addDebugInfo('WARNING: Current user has no city defined!');
        setState(() {
          _matches = [];
        });
        return;
      }

      var beforeCityCount = _filteredUsers.length;
      _filteredUsers = _filteredUsers.where((user) {
        final userCity = (user['city'] ?? '').toString().toLowerCase().trim();

        if (userCity.isEmpty) {
          _addDebugInfo('WARNING: User ${user['id']} has no city defined!');
          return false;
        }

        bool sameCity = userCity == currentUserCity;

        String userId = user['id']?.toString() ?? 'unknown';
        _addDebugInfo('City comparison for User $userId: "$userCity" == "$currentUserCity" = $sameCity');

        return sameCity;
      }).toList();

      _addDebugInfo('After city filter: ${_filteredUsers.length} users left (removed ${beforeCityCount - _filteredUsers.length})');
    } else if (_matchCriteria == 'hobbies') {
      List<String> currentUserHobbies = [];
      try {
        if (_currentUser!['hobbies'] is String) {
          // Handle case where hobbies is a comma-separated string
          currentUserHobbies = (_currentUser!['hobbies'] as String).split(',')
              .map((h) => h.trim().toLowerCase())
              .where((h) => h.isNotEmpty)
              .toList();
        } else if (_currentUser!['hobbies'] is List) {
          // Handle case where hobbies is already a list
          currentUserHobbies = List<String>.from(_currentUser!['hobbies'])
              .map((h) => h.toString().trim().toLowerCase())
              .where((h) => h.isNotEmpty)
              .toList();
        }
      } catch (e) {
        _addDebugInfo('Error getting current user hobbies: $e');
      }

      if (currentUserHobbies.isEmpty) {
        _addDebugInfo('WARNING: Current user has no hobbies defined!');
      }

      _addDebugInfo('Current user hobbies: ${currentUserHobbies.join(", ")}');

      var beforeHobbiesCount = _filteredUsers.length;
      _filteredUsers = _filteredUsers.where((user) {
        List<String> userHobbies = [];
        try {
          if (user['hobbies'] is String) {
            // Handle case where hobbies is a comma-separated string
            userHobbies = (user['hobbies'] as String).split(',')
                .map((h) => h.trim().toLowerCase())
                .where((h) => h.isNotEmpty)
                .toList();
          } else if (user['hobbies'] is List) {
            // Handle case where hobbies is already a list
            userHobbies = List<String>.from(user['hobbies'])
                .map((h) => h.toString().trim().toLowerCase())
                .where((h) => h.isNotEmpty)
                .toList();
          }
        } catch (e) {
          _addDebugInfo('Error getting user ${user['id']} hobbies: $e');
          return false;
        }

        if (userHobbies.isEmpty) {
          _addDebugInfo('User ${user['id']} has no hobbies defined');
          return false;
        }

        _addDebugInfo('User ${user['id']} hobbies: ${userHobbies.join(", ")}');

        // Find common hobbies
        var commonHobbies = userHobbies.where((hobby) =>
            currentUserHobbies.contains(hobby)).toList();
        bool hasCommonHobbies = commonHobbies.isNotEmpty;

        _addDebugInfo('Hobby comparison for user ${user['id']}: Common hobbies: ${commonHobbies.join(", ")} = $hasCommonHobbies');

        return hasCommonHobbies;
      }).toList();

      _addDebugInfo('After hobbies filter: ${_filteredUsers.length} users left (removed ${beforeHobbiesCount - _filteredUsers.length})');
    }

    // Final matched users
    _matches = _filteredUsers;
    _addDebugInfo('Final matches: ${_matches.length}');

    for (var match in _matches) {
      String matchId = match['id']?.toString() ?? 'unknown';
      String matchName = match['name'] ?? 'Unknown';
      String matchCity = match['city'] ?? 'Unknown';
      String matchGender = match['gender'] ?? 'Unknown';

      _addDebugInfo('Match: ID=$matchId, Name=$matchName, City=$matchCity, Gender=$matchGender');
    }

    // Force update UI
    setState(() {});
  }

  void _changeCriteria(String criteria) {
    setState(() {
      _matchCriteria = criteria;
      _debugInfo = '';
      _addDebugInfo('Changed criteria to: $criteria');
      _findMatches();
    });
  }

  void _toggleDebugMode() {
    setState(() {
      _debugMode = !_debugMode;
      _addDebugInfo('Debug mode: $_debugMode');
    });
  }

  void _forceMatch() {
    if (_currentUser == null || _users.isEmpty) {
      _addDebugInfo('Cannot force match: Current user is null or no users available');
      return;
    }

    if (_currentUserGender == null || _currentUserGender!.isEmpty) {
      _addDebugInfo('Cannot force match: Current user gender is null/empty');
      return;
    }

    _addDebugInfo('Forcing matches - bypassing city/hobby restrictions');

    String oppositeGender = _currentUserGender == 'male' ? 'female' : 'male';
    String currentUserId = _currentUser!['id'].toString();

    // Just match with all users of opposite gender
    _matches = _users.where((user) {
      String userGender = (user['gender'] ?? '').toString().toLowerCase().trim();
      String userId = user['id'].toString();
      bool isMatch = userId != currentUserId && userGender == oppositeGender;

      if (isMatch) {
        _addDebugInfo('Forced match found: User $userId, Gender="$userGender"');
      }

      return isMatch;
    }).toList();

    _addDebugInfo('Forced matching found ${_matches.length} users of opposite gender');

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Match'),
        actions: [
          IconButton(
            icon: Icon(_debugMode ? Icons.bug_report : Icons.bug_report_outlined),
            tooltip: 'Toggle Debug Mode',
            onPressed: _toggleDebugMode,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Current user info (helpful for debugging)
          if (_debugMode && _currentUser != null)
            Container(
              color: Colors.amber[100],
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current User: ${_currentUser!['name'] ?? 'Unknown'} (ID: ${_currentUser!['id']})'),
                  Text('Gender: $_currentUserGender, City: ${_currentUser!['city'] ?? 'Unknown'}'),
                  Text('Hobbies: ${_getHobbiesString(_currentUser!)}'),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _forceMatch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('Force Match (Ignore Filters)', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Match criteria selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Match Based On:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _changeCriteria('city'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _matchCriteria == 'city'
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                        ),
                        child: Text(
                          'Same City',
                          style: TextStyle(
                            color: _matchCriteria == 'city'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _changeCriteria('hobbies'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _matchCriteria == 'hobbies'
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                        ),
                        child: Text(
                          'Similar Hobbies',
                          style: TextStyle(
                            color: _matchCriteria == 'hobbies'
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Match count display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Found ${_matches.length} matches',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_debugMode)
                  Text(
                    'Total users: ${_users.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
              ],
            ),
          ),

          // Match results
          Expanded(
            child: _matches.isEmpty
                ? Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sentiment_dissatisfied, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'No matches found based on $_matchCriteria',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                // Debug logs section
                if (_debugMode)
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Debug Logs:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Divider(),
                            Text(
                              _debugInfo,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            )
                : Column(
              children: [
                Expanded(
                  flex: _debugMode ? 2 : 1,
                  child: ListView.builder(
                    itemCount: _matches.length,
                    itemBuilder: (context, index) {
                      final match = _matches[index];

                      // Calculate match percentage based on shared hobbies
                      List<String> currentUserHobbies = _getHobbiesList(_currentUser!);
                      List<String> matchHobbies = _getHobbiesList(match);

                      int sharedHobbies = matchHobbies
                          .where((hobby) => currentUserHobbies.contains(hobby))
                          .length;

                      int totalUniqueHobbies = {...matchHobbies, ...currentUserHobbies}.length;
                      double matchPercentage = totalUniqueHobbies > 0
                          ? (sharedHobbies / totalUniqueHobbies) * 100
                          : 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: _getImageProvider(match),
                            radius: 30,
                          ),
                          title: Text(
                            '${match['name'] ?? 'Unknown'}, ${match['age'] ?? _calculateAge(match['dob'])}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('City: ${match['city'] ?? 'Unknown'}'),
                              if (_debugMode)
                                Text('Gender: ${match['gender'] ?? 'Unknown'} (ID: ${match['id']})',
                                    style: const TextStyle(fontSize: 12, color: Colors.red)),
                              const SizedBox(height: 2),
                              if (matchHobbies.isNotEmpty)
                                Wrap(
                                  spacing: 4,
                                  children: matchHobbies
                                      .map((hobby) => Chip(
                                    label: Text(hobby),
                                    backgroundColor: currentUserHobbies.contains(hobby)
                                        ? Colors.green[100]
                                        : Colors.grey[200],
                                    labelStyle: TextStyle(
                                      color: currentUserHobbies.contains(hobby)
                                          ? Colors.green[800]
                                          : Colors.black87,
                                      fontSize: 12,
                                    ),
                                    padding: const EdgeInsets.all(0),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ))
                                      .toList(),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: matchPercentage / 100,
                                backgroundColor: Colors.grey[300],
                                color: Colors.red,
                                strokeWidth: 6,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${matchPercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigate to user profile or start chat
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Viewing ${match['name'] ?? "Unknown user"}')),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Debug logs section
                if (_debugMode)
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Debug Logs:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Divider(),
                            Text(
                              _debugInfo,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get image provider based on available data
  ImageProvider _getImageProvider(Map<String, dynamic> user) {
    if (user['imagePath'] != null && user['imagePath'].toString().isNotEmpty) {
      return FileImage(File(user['imagePath']));
    } else if (user['avatar'] != null && user['avatar'].toString().isNotEmpty) {
      return NetworkImage(user['avatar']);
    } else if (user['image'] != null && user['image'].toString().isNotEmpty) {
      return NetworkImage(user['image']);
    } else if (user['photo'] != null && user['photo'].toString().isNotEmpty) {
      if (user['photo'].toString().startsWith('http')) {
        return NetworkImage(user['photo']);
      } else {
        return FileImage(File(user['photo']));
      }
    } else {
      return const AssetImage('assets/default_avatar.png');
    }
  }

  // Helper method to get hobbies as a formatted string
  String _getHobbiesString(Map<String, dynamic> user) {
    List<String> hobbies = _getHobbiesList(user);
    return hobbies.isEmpty ? 'None' : hobbies.join(", ");
  }

  // Helper method to get hobbies as a list
  List<String> _getHobbiesList(Map<String, dynamic> user) {
    try {
      if (user['hobbies'] is String) {
        return (user['hobbies'] as String).split(',')
            .map((h) => h.trim())
            .where((h) => h.isNotEmpty)
            .toList();
      } else if (user['hobbies'] is List) {
        return List<String>.from(user['hobbies'])
            .map((h) => h.toString().trim())
            .where((h) => h.isNotEmpty)
            .toList();
      }
    } catch (e) {
      _addDebugInfo('Error processing hobbies for user ${user['id']}: $e');
    }
    return [];
  }

  // Helper method to calculate age from DOB
  String? _calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return null;

    try {
      final birthDate = DateTime.parse(dob);
      final currentDate = DateTime.now();
      int age = currentDate.year - birthDate.year;

      // Adjust age if birthday hasn't occurred yet this year
      if (currentDate.month < birthDate.month ||
          (currentDate.month == birthDate.month &&
              currentDate.day < birthDate.day)) {
        age--;
      }

      return age.toString();
    } catch (e) {
      return null;
    }
  }
}