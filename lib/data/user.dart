class User {
  final String email;
  final String password;
  final String? name; 

  User({required this.email, required this.password, this.name});

  Map<String, String> toMap() {
    return {
      'email': email,
      'password': password,
      'name': name ?? '',
    };
  }

  factory User.fromMap(Map<String, String> map) {
    return User(
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      name: map['name'],
    );
  }
}
