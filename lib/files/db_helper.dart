import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';

class ApiHelper {
  static final ApiHelper _instance = ApiHelper._internal();
  factory ApiHelper() => _instance;
  ApiHelper._internal();

  final String baseUrl = 'https://67c9259a0acf98d07088ffee.mockapi.io/users';
  final ImagePicker _imagePicker = ImagePicker();

  // Pick image from gallery or camera
  Future<File?> pickImage({bool fromCamera = false}) async {
    final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Insert User
  // Insert User
  Future<http.Response> insertUser(Map<String, dynamic> user, {File? imageFile}) async {
    if (imageFile != null) {
      // Store the local path
      user['imagePath'] = imageFile.path;

      // Also upload to server if needed
      final imageUrl = await uploadImage(imageFile);
      if (imageUrl != null) {
        user['image'] = imageUrl;
      }
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user),
    );
    return response;
  }

  // Upload Image and return the URL
  Future<String?> uploadImage(File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload'),
    );

    var fileStream = http.ByteStream(imageFile.openRead());
    var fileLength = await imageFile.length();

    var multipartFile = http.MultipartFile(
      'image',
      fileStream,
      fileLength,
      filename: basename(imageFile.path),
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(multipartFile);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['imageUrl'];
    } else {
      return null;
    }
  }

  // Update User with Image
  Future<http.Response> updateUser(String id, Map<String, dynamic> user, {File? imageFile}) async {
    if (imageFile != null) {
      // Store the local path
      user['imagePath'] = imageFile.path;

      // Also upload to server if needed
      final imageUrl = await uploadImage(imageFile);
      if (imageUrl != null) {
        user['image'] = imageUrl;
      }
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user),
    );
    return response;
  }

  // Get image from path
  File? getImageFromPath(String? path) {
    if (path == null) return null;
    final file = File(path);
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  // Get User by ID
  Future<Map<String, dynamic>?> getUserById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  // Get User by Email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      print("Fetching user with email: $email"); // Debug log
      final response = await http.get(Uri.parse('$baseUrl?email=$email'));
      print("Response status code: ${response.statusCode}"); // Debug log
      print("Response body: ${response.body}"); // Debug log

      if (response.statusCode == 200) {
        List users = json.decode(response.body);
        print("Decoded users: $users"); // Debug log
        print("Users length: ${users.length}"); // Debug log
        return users.isNotEmpty ? users.first : null;
      }
      return null;
    } catch (e) {
      print("Error in getUserByEmail: $e"); // Debug log
      return null;
    }
  }

  // Get All Users
  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  // Delete User
  Future<http.Response> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response;
  }

  // Toggle Favorite Status
  Future<http.Response> toggleFavorite(String id, bool isFavorite) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isFavorite': isFavorite ? 1 : 0}),
    );
    return response;
  }

  // Get Favorite Users
  Future<List<Map<String, dynamic>>> getFavoriteUsers() async {
    final response = await http.get(Uri.parse('$baseUrl?isFavorite=1'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }
}
