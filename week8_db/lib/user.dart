class User {
  final int? id; // User's ID (nullable to handle new users)
  final String username; // User's username
  final String email; // User's email

  // Constructor
  User({this.id, required this.username, required this.email});

  // Convert User object to Map (for database insertion)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id is nullable for new users (can be null)
      'username': username,
      'email': email,
    };
  }

  // Create User object from Map (for database queries)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'], // 'id' can be null if not set yet
      username: map['username'],
      email: map['email'],
    );
  }
}
