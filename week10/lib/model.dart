class Model {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String age;
  final String major;

  Model({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.age,
    required this.major,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      age: json['age']?.toString() ?? '',
      major: json['major'] ?? '',
    );
  }
}
