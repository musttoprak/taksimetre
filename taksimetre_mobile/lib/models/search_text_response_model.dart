class SearchTextResponseModel {
  final String? formattedAddress;
  final double? latitude;
  final double? longitude;
  bool isFirstForm = true;

  SearchTextResponseModel({required this.formattedAddress, required this.latitude, required this.longitude});

  factory SearchTextResponseModel.fromJson(Map<String, dynamic> json) {
    return SearchTextResponseModel(
      formattedAddress: json['formatted_address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}