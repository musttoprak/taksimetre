class UserResponseModel {
  final String id;
  final String name;
  final String password;
  final bool active;

  UserResponseModel({
    required this.id,
    required this.name,
    required this.password,
    required this.active,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      id: json['id'],
      name: json['name'],
      password: json['password'],
      active: json['active'] == '1',
    );
  }
}