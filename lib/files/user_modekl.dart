class User {
  String id;
  String name;
  String email;
  String phone;
  String gender;
  List<String> hobbies;
  bool isFavorite;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.hobbies,
    required this.isFavorite,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      hobbies: List<String>.from(json['hobbies'].split(',')),
      isFavorite: json['isFavorite'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'hobbies': hobbies.join(','),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }
}
