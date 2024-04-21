class FeeTableResponseModel {
  final String id;
  final String name;
  final String value;

  FeeTableResponseModel({
    required this.id,
    required this.name,
    required this.value,
  });

  factory FeeTableResponseModel.fromJson(Map<String, dynamic> json) {
    return FeeTableResponseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }
}
