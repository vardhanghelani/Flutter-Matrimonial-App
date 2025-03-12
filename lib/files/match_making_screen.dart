import 'package:flutter/material.dart';
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
  bool _isLoading = true;
  String _matchCriteria = 'city'; // Default matching criteria

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _users = await _apiHelper.getUsers();
      _findMatches();
    } catch (e) {
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
    List<Map<String, dynamic>> males = _users.where((user) => user['gender'].toLowerCase() == 'male').toList();
    List<Map<String, dynamic>> females = _users.where((user) => user['gender'].toLowerCase() == 'female').toList();

    if (_matchCriteria == 'city') {
      setState(() {
        _matches = males.expand((male) {
          return females.where((female) => male['city'] == female['city']).map((female) {
            return {'male': male, 'female': female};
          });
        }).toList();
      });
    } else if (_matchCriteria == 'hobbies') {
      setState(() {
        _matches = males.expand((male) {
          List<String> maleHobbies = (male['hobbies'] as String).split(',').map((h) => h.trim().toLowerCase()).toList();
          return females.where((female) {
            List<String> femaleHobbies = (female['hobbies'] as String).split(',').map((h) => h.trim().toLowerCase()).toList();
            return maleHobbies.any((hobby) => femaleHobbies.contains(hobby));
          }).map((female) {
            return {'male': male, 'female': female};
          });
        }).toList();
      });
    }
  }

  void _changeCriteria(String criteria) {
    setState(() {
      _matchCriteria = criteria;
      _findMatches();
    });
  }

  void _viewProfile(Map<String, dynamic> user) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProfileScreen(user: user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Find Your Match'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh matches',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Match Criteria',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.location_city),
                        label: const Text('Same City'),
                        onPressed: () => _changeCriteria('city'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _matchCriteria == 'city'
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                          foregroundColor: _matchCriteria == 'city'
                              ? Colors.white
                              : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.interests),
                        label: const Text('Similar Hobbies'),
                        onPressed: () => _changeCriteria('hobbies'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _matchCriteria == 'hobbies'
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                          foregroundColor: _matchCriteria == 'hobbies'
                              ? Colors.white
                              : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Found ${_matches.length} matches',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_matches.isNotEmpty)
                  Text(
                    'Based on $_matchCriteria',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _matches.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No matches found based on $_matchCriteria',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _changeCriteria(
                        _matchCriteria == 'city' ? 'hobbies' : 'city'),
                    child: Text(
                        'Try ${_matchCriteria == 'city' ? 'Hobbies' : 'City'} matching instead'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _matches.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final match = _matches[index];
                final male = match['male'];
                final female = match['female'];

                if (male == null || female == null) {
                  return Container();
                }

                // Find common hobbies if using hobby matching
                List<String> commonHobbies = [];
                if (_matchCriteria == 'hobbies') {
                  List<String> maleHobbies = (male['hobbies'] as String)
                      .split(',')
                      .map((h) => h.trim().toLowerCase())
                      .toList();
                  List<String> femaleHobbies = (female['hobbies'] as String)
                      .split(',')
                      .map((h) => h.trim().toLowerCase())
                      .toList();
                  commonHobbies = maleHobbies
                      .where((hobby) => femaleHobbies.contains(hobby))
                      .toList();
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              _matchCriteria == 'city'
                                  ? 'Both from ${male['city']}'
                                  : 'Common interests: ${commonHobbies.isNotEmpty ? commonHobbies.join(", ") : "N/A"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _viewProfile(male),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Hero(
                                            tag: 'avatar-${male['id'] ?? index}-male',
                                            child: CircleAvatar(
                                              backgroundImage: male['avatar'] != null
                                                  ? NetworkImage(male['avatar'])
                                                  : null,
                                              radius: 48,
                                              backgroundColor: Colors.blue[100],
                                              child: male['avatar'] == null
                                                  ? const Icon(Icons.person, size: 48, color: Colors.blue)
                                                  : null,
                                            ),
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.blue,
                                            radius: 14,
                                            child: const Icon(Icons.male, color: Colors.white, size: 18),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        male['name'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            male['city'] ?? 'Unknown',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'View Profile',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: Colors.grey,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => _viewProfile(female),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Hero(
                                            tag: 'avatar-${female['id'] ?? index}-female',
                                            child: CircleAvatar(
                                              backgroundImage: female['avatar'] != null
                                                  ? NetworkImage(female['avatar'])
                                                  : null,
                                              radius: 48,
                                              backgroundColor: Colors.pink[100],
                                              child: female['avatar'] == null
                                                  ? const Icon(Icons.person, size: 48, color: Colors.pink)
                                                  : null,
                                            ),
                                          ),
                                          CircleAvatar(
                                            backgroundColor: Colors.pink,
                                            radius: 14,
                                            child: const Icon(Icons.female, color: Colors.white, size: 18),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        female['name'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            female['city'] ?? 'Unknown',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'View Profile',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
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
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.message),
                              label: const Text('Connect'),
                              onPressed: () {
                                // Connect logic
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Connect feature coming soon!')),
                                );
                              },
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.favorite_border),
                              label: const Text('Save Match'),
                              onPressed: () {
                                // Save match logic
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Match saved successfully!')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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

// Profile Screen
class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse hobbies into a list
    List<String> hobbies = [];
    if (user['hobbies'] != null) {
      hobbies = (user['hobbies'] as String).split(',').map((h) => h.trim()).toList();
    }

    bool isMale = user['gender']?.toLowerCase() == 'male';
    Color genderColor = isMale ? Colors.blue : Colors.pink;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(user['name'] ?? 'Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 24),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Hero(
                    tag: 'avatar-${user['id'] ?? 0}-${user['gender']?.toLowerCase()}',
                    child: CircleAvatar(
                      backgroundImage: user['avatar'] != null ? NetworkImage(user['avatar']) : null,
                      radius: 64,
                      backgroundColor: isMale ? Colors.blue[100] : Colors.pink[100],
                      child: user['avatar'] == null
                          ? Icon(
                        Icons.person,
                        size: 64,
                        color: genderColor,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isMale ? Icons.male : Icons.female,
                        color: genderColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user['gender'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16,
                          color: genderColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        user['city'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('About'),
                  Card(
                    margin: const EdgeInsets.only(bottom: 24, top: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        user['about'] ?? 'No information provided.',
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                  ),
                  _buildSectionTitle('Interests & Hobbies'),
                  Card(
                    margin: const EdgeInsets.only(bottom: 24, top: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: hobbies.isEmpty
                            ? [
                          Chip(
                            label: const Text('No hobbies listed'),
                            backgroundColor: Colors.grey[200],
                          )
                        ]
                            : hobbies.map((hobby) {
                          return Chip(
                            label: Text(hobby),
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            avatar: Icon(Icons.tag, size: 16, color: genderColor),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  _buildSectionTitle('Contact Information'),
                  Card(
                    margin: const EdgeInsets.only(bottom: 24, top: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: Text(user['email'] ?? 'Not provided'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Phone'),
                          subtitle: Text(user['phone'] ?? 'Not provided'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.message),
                      label: const Text('Send Message'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Messaging feature coming soon!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}