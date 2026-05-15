class User {
  final String email;
  final String name;
  final int age;
  final String gender;

  final String? skinType;
  final String? sunExposure;
  final String? smokingStatus;

  final bool isComplete;
  final String role;

  User({
    required this.email,
    required this.name,
    required this.age,
    required this.gender,
    this.skinType,
    this.sunExposure,
    this.smokingStatus,
    required this.isComplete,
    required this.role,
  });
}

class UserModel extends User {
  UserModel({
    required super.email,
    required super.name,
    required super.age,
    required super.gender,
    super.skinType,
    super.sunExposure,
    super.smokingStatus,
    required super.isComplete,
    required super.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      skinType: map['skinType'],
      sunExposure: map['sunExposure'],
      smokingStatus: map['smokingStatus'],
      isComplete: map['isComplete'] ?? false,
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'skinType': skinType,
      'sunExposure': sunExposure,
      'smokingStatus': smokingStatus,
      'isComplete': isComplete,
      'role': role,
    };
  }
}